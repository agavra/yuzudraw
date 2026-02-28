import Foundation
import Network

@MainActor
final class MCPServer {
    private var listener: NWListener?
    private let port: UInt16
    private let router: MCPRouter
    private var sessionID: String?

    init(workspace: WorkspaceViewModel, port: UInt16 = 7842) {
        self.port = port
        self.router = MCPRouter(workspace: workspace)
    }

    func start() {
        let params = NWParameters.tcp
        params.allowLocalEndpointReuse = true

        guard let nwPort = NWEndpoint.Port(rawValue: port) else {
            print("[MCP] Invalid port: \(port)")
            return
        }

        do {
            listener = try NWListener(using: params, on: nwPort)
        } catch {
            print("[MCP] Failed to create listener: \(error)")
            return
        }

        listener?.newConnectionHandler = { [weak self] connection in
            Task { @MainActor in
                self?.handleConnection(connection)
            }
        }

        listener?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("[MCP] Server listening on localhost:\(nwPort)")
                Self.writePortFile(nwPort.rawValue)
            case .failed(let error):
                print("[MCP] Server failed: \(error)")
            case .cancelled:
                print("[MCP] Server cancelled")
            default:
                break
            }
        }

        listener?.start(queue: .main)
    }

    func stop() {
        listener?.cancel()
        listener = nil
        Self.removePortFile()
    }

    // MARK: - Connection handling

    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: .main)
        receiveHTTPRequest(on: connection, accumulated: Data())
    }

    private func receiveHTTPRequest(on connection: NWConnection, accumulated: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) {
            [weak self] content, _, isComplete, error in
            Task { @MainActor in
                guard let self else { return }

                if let error {
                    print("[MCP] Receive error: \(error)")
                    connection.cancel()
                    return
                }

                var data = accumulated
                if let content {
                    data.append(content)
                }

                if let request = self.parseHTTPRequest(data) {
                    await self.handleHTTPRequest(request, on: connection)
                } else if isComplete {
                    self.sendHTTPResponse(
                        statusCode: 400, body: "Bad Request".data(using: .utf8)!,
                        on: connection)
                } else {
                    self.receiveHTTPRequest(on: connection, accumulated: data)
                }
            }
        }
    }

    // MARK: - HTTP parsing

    private struct HTTPRequest {
        let method: String
        let path: String
        let headers: [String: String]
        let body: Data
    }

    private func parseHTTPRequest(_ data: Data) -> HTTPRequest? {
        let separator = Data([0x0D, 0x0A, 0x0D, 0x0A])  // \r\n\r\n
        guard let separatorRange = data.range(of: separator) else { return nil }

        guard
            let headerString = String(
                data: data[data.startIndex..<separatorRange.lowerBound], encoding: .utf8)
        else { return nil }

        let headerLines = headerString.components(separatedBy: "\r\n")
        guard let requestLine = headerLines.first else { return nil }

        let requestParts = requestLine.split(separator: " ", maxSplits: 2)
        guard requestParts.count >= 2 else { return nil }

        let method = String(requestParts[0])
        let path = String(requestParts[1])

        var headers: [String: String] = [:]
        for line in headerLines.dropFirst() {
            if let colonIndex = line.firstIndex(of: ":") {
                let name = String(line[line.startIndex..<colonIndex])
                    .trimmingCharacters(in: .whitespaces)
                    .lowercased()
                let value = String(line[line.index(after: colonIndex)...])
                    .trimmingCharacters(in: .whitespaces)
                headers[name] = value
            }
        }

        let bodyStart = separatorRange.upperBound
        let contentLength = headers["content-length"].flatMap(Int.init) ?? 0

        let availableBody = data[bodyStart...]
        guard availableBody.count >= contentLength else { return nil }

        let body = Data(availableBody.prefix(contentLength))
        return HTTPRequest(method: method, path: path, headers: headers, body: body)
    }

    // MARK: - Request handling

    private func handleHTTPRequest(_ request: HTTPRequest, on connection: NWConnection) async {
        // CORS preflight
        if request.method == "OPTIONS" {
            sendHTTPResponse(statusCode: 204, body: Data(), on: connection, extraHeaders: corsHeaders())
            return
        }

        // DELETE = session termination
        if request.method == "DELETE", request.path == "/mcp" {
            sessionID = nil
            sendHTTPResponse(statusCode: 200, body: Data(), on: connection)
            return
        }

        guard request.method == "POST", request.path == "/mcp" else {
            sendHTTPResponse(
                statusCode: 404, body: "Not Found".data(using: .utf8)!, on: connection)
            return
        }

        let routerResult = await router.handleRequest(request.body)

        var extraHeaders = corsHeaders()

        switch routerResult {
        case .response(let body, let isInitialize):
            if isInitialize {
                let newSession = UUID().uuidString
                sessionID = newSession
                extraHeaders["Mcp-Session-Id"] = newSession
            } else if let sid = sessionID {
                extraHeaders["Mcp-Session-Id"] = sid
            }
            sendHTTPResponse(
                statusCode: 200, body: body, on: connection, extraHeaders: extraHeaders)

        case .notification:
            if let sid = sessionID {
                extraHeaders["Mcp-Session-Id"] = sid
            }
            sendHTTPResponse(
                statusCode: 202, body: Data(), on: connection, extraHeaders: extraHeaders)
        }
    }

    private func corsHeaders() -> [String: String] {
        [
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type, Mcp-Session-Id",
            "Access-Control-Allow-Methods": "POST, DELETE, OPTIONS",
            "Access-Control-Expose-Headers": "Mcp-Session-Id",
        ]
    }

    private func sendHTTPResponse(
        statusCode: Int,
        body: Data,
        on connection: NWConnection,
        extraHeaders: [String: String] = [:]
    ) {
        let contentType = body.isEmpty ? nil : "application/json"
        var headerLines = [
            "HTTP/1.1 \(statusCode) \(Self.statusText(statusCode))"
        ]

        if let contentType {
            headerLines.append("Content-Type: \(contentType)")
        }
        headerLines.append("Content-Length: \(body.count)")
        headerLines.append("Connection: close")

        for (key, value) in extraHeaders.sorted(by: { $0.key < $1.key }) {
            headerLines.append("\(key): \(value)")
        }

        let header = headerLines.joined(separator: "\r\n") + "\r\n\r\n"
        var responseData = header.data(using: .utf8)!
        responseData.append(body)

        connection.send(
            content: responseData,
            completion: .contentProcessed { _ in
                connection.cancel()
            })
    }

    // MARK: - Port file

    private nonisolated static var portFilePath: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".yuzudraw/mcp-port")
    }

    private nonisolated static func writePortFile(_ port: UInt16) {
        let dir = portFilePath.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try? String(port).write(to: portFilePath, atomically: true, encoding: .utf8)
    }

    private nonisolated static func removePortFile() {
        try? FileManager.default.removeItem(at: portFilePath)
    }

    private nonisolated static func statusText(_ code: Int) -> String {
        switch code {
        case 200: "OK"
        case 202: "Accepted"
        case 204: "No Content"
        case 400: "Bad Request"
        case 404: "Not Found"
        case 500: "Internal Server Error"
        default: "Unknown"
        }
    }
}
