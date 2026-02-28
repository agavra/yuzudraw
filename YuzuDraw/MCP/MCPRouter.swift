import Foundation

enum MCPRouterResult: Sendable {
    case response(Data, isInitialize: Bool)
    case notification
}

@MainActor
final class MCPRouter {
    private let tools: MCPTools

    init(workspace: WorkspaceViewModel) {
        self.tools = MCPTools(workspace: workspace)
    }

    func handleRequest(_ data: Data) async -> MCPRouterResult {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return .response(
                errorResponse(id: nil, code: -32700, message: "Parse error"),
                isInitialize: false)
        }

        let id = json["id"]  // Can be Int, String, or null — absent for notifications
        let method = json["method"] as? String ?? ""
        let params = json["params"] as? [String: Any] ?? [:]

        // Notifications have no "id" field
        let isNotification = json["id"] == nil && !method.isEmpty

        switch method {
        case "initialize":
            let result = initializeResult()
            return .response(successResponse(id: id, result: result), isInitialize: true)

        case "notifications/initialized", "notifications/cancelled":
            return .notification

        case "tools/list":
            let result = toolsListResult()
            return .response(successResponse(id: id, result: result), isInitialize: false)

        case "tools/call":
            let result = await toolsCallResult(params: params)
            return .response(successResponse(id: id, result: result), isInitialize: false)

        default:
            if isNotification {
                return .notification
            }
            return .response(
                errorResponse(id: id, code: -32601, message: "Method not found: \(method)"),
                isInitialize: false)
        }
    }

    // MARK: - MCP Protocol Methods

    private func initializeResult() -> [String: Any] {
        [
            "protocolVersion": "2024-11-05",
            "capabilities": [
                "tools": [:] as [String: Any]
            ] as [String: Any],
            "serverInfo": [
                "name": "yuzudraw",
                "version": "1.0.0",
            ] as [String: Any],
        ]
    }

    private func toolsListResult() -> [String: Any] {
        [
            "tools": [
                toolSchema(
                    name: "create_diagram",
                    description:
                        "Create a new diagram tab in YuzuDraw from DSL text. Returns the ASCII render.",
                    properties: [
                        "name": [
                            "type": "string",
                            "description": "Name for the diagram tab",
                        ],
                        "dsl": [
                            "type": "string",
                            "description": "YuzuDraw DSL text defining the diagram",
                        ],
                    ],
                    required: ["name", "dsl"]
                ),
                toolSchema(
                    name: "update_diagram",
                    description:
                        "Update an existing diagram tab with new DSL content. Returns the ASCII render.",
                    properties: [
                        "name": [
                            "type": "string",
                            "description": "Name of the diagram tab to update",
                        ],
                        "dsl": [
                            "type": "string",
                            "description": "New YuzuDraw DSL text",
                        ],
                    ],
                    required: ["name", "dsl"]
                ),
                toolSchema(
                    name: "get_diagram",
                    description:
                        "Get the DSL and ASCII render of an existing diagram. Reads back user edits.",
                    properties: [
                        "name": [
                            "type": "string",
                            "description": "Name of the diagram tab to read",
                        ]
                    ],
                    required: ["name"]
                ),
                toolSchema(
                    name: "list_diagrams",
                    description: "List all open diagram tabs in YuzuDraw.",
                    properties: [:],
                    required: []
                ),
                toolSchema(
                    name: "render_ascii",
                    description:
                        "Render DSL to ASCII text without creating or saving a diagram. Useful for preview.",
                    properties: [
                        "dsl": [
                            "type": "string",
                            "description": "YuzuDraw DSL text to render",
                        ]
                    ],
                    required: ["dsl"]
                ),
            ]
        ]
    }

    private func toolSchema(
        name: String,
        description: String,
        properties: [String: [String: String]],
        required: [String]
    ) -> [String: Any] {
        [
            "name": name,
            "description": description,
            "inputSchema": [
                "type": "object",
                "properties": properties,
                "required": required,
            ] as [String: Any],
        ]
    }

    private func toolsCallResult(params: [String: Any]) async -> [String: Any] {
        let toolName = params["name"] as? String ?? ""
        let args = params["arguments"] as? [String: Any] ?? [:]

        do {
            let text = try await tools.call(tool: toolName, arguments: args)
            return [
                "content": [
                    ["type": "text", "text": text] as [String: Any]
                ]
            ]
        } catch {
            return [
                "content": [
                    [
                        "type": "text",
                        "text": "Error: \(error.localizedDescription)",
                    ] as [String: Any]
                ],
                "isError": true,
            ]
        }
    }

    // MARK: - JSON-RPC response builders

    private func successResponse(id: Any?, result: Any) -> Data {
        var response: [String: Any] = [
            "jsonrpc": "2.0",
            "result": result,
        ]
        if let id {
            response["id"] = id
        }
        return (try? JSONSerialization.data(withJSONObject: response)) ?? Data()
    }

    private func errorResponse(id: Any?, code: Int, message: String) -> Data {
        var response: [String: Any] = [
            "jsonrpc": "2.0",
            "error": [
                "code": code,
                "message": message,
            ] as [String: Any],
        ]
        if let id {
            response["id"] = id
        }
        return (try? JSONSerialization.data(withJSONObject: response)) ?? Data()
    }
}
