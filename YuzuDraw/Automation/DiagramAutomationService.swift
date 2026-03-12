import Foundation

enum DiagramAutomationError: LocalizedError {
    case missingArgument(String)
    case diagramNotFound(String)
    case diagramAlreadyExists(URL)
    case dslParseError(String)
    case invalidPath(String)

    var errorDescription: String? {
        switch self {
        case .missingArgument(let name):
            "Missing required argument: \(name)"
        case .diagramNotFound(let name):
            "Diagram not found: \(name)"
        case .diagramAlreadyExists(let url):
            "Diagram already exists at \(url.path)"
        case .dslParseError(let detail):
            "DSL parse error: \(detail)"
        case .invalidPath(let path):
            "Invalid path: \(path)"
        }
    }
}

struct DiagramAutomationService {
    func createDiagram(name: String, dsl: String, outputURL: URL?) throws -> (url: URL, ascii: String) {
        let document = try parseDSL(dsl)
        let destinationURL = try resolveCreateURL(name: name, outputURL: outputURL)
        if ProjectFileManager.fileExists(at: destinationURL) {
            throw DiagramAutomationError.diagramAlreadyExists(destinationURL)
        }
        try ProjectFileManager.save(document: document, to: destinationURL)
        return (destinationURL, renderDocument(document))
    }

    func updateDiagram(name: String, dsl: String, projectURL: URL?) throws -> (url: URL, ascii: String) {
        let document = try parseDSL(dsl)
        let targetURL = try resolveExistingDiagramURL(name: name, projectURL: projectURL)
        try ProjectFileManager.save(document: document, to: targetURL)
        return (targetURL, renderDocument(document))
    }

    func getDiagram(name: String, projectURL: URL?) throws -> (url: URL, dsl: String, ascii: String) {
        let targetURL = try resolveExistingDiagramURL(name: name, projectURL: projectURL)
        let document = try ProjectFileManager.load(from: targetURL)
        let dsl = DSLSerializer.serialize(document)
        return (targetURL, dsl, renderDocument(document))
    }

    func listDiagrams(in directory: URL?) throws -> [URL] {
        let searchDirectory = directory ?? ProjectFileManager.projectsDirectory
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: searchDirectory.path, isDirectory: &isDirectory) else {
            return []
        }
        guard isDirectory.boolValue else {
            throw DiagramAutomationError.invalidPath(searchDirectory.path)
        }

        let contents = try FileManager.default.contentsOfDirectory(
            at: searchDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )

        return contents
            .filter { $0.pathExtension == ProjectFileManager.fileExtension }
            .sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
    }

    func renderASCII(from dsl: String) throws -> String {
        let document = try parseDSL(dsl)
        return renderDocument(document)
    }

    private func resolveCreateURL(name: String, outputURL: URL?) throws -> URL {
        if let outputURL {
            return outputURL
        }
        return try ProjectFileManager.newFileURL(name: name)
    }

    private func resolveExistingDiagramURL(name: String, projectURL: URL?) throws -> URL {
        if let projectURL {
            guard ProjectFileManager.fileExists(at: projectURL) else {
                throw DiagramAutomationError.diagramNotFound(projectURL.path)
            }
            return projectURL
        }

        let inferredURL = try ProjectFileManager.newFileURL(name: name)
        guard ProjectFileManager.fileExists(at: inferredURL) else {
            throw DiagramAutomationError.diagramNotFound(name)
        }
        return inferredURL
    }

    private func parseDSL(_ dsl: String) throws -> Document {
        do {
            return try DSLParser.parse(dsl)
        } catch {
            throw DiagramAutomationError.dslParseError("\(error)")
        }
    }

    private func renderDocument(_ document: Document) -> String {
        guard let boundingBox = document.boundingBox() else {
            return "(empty diagram)"
        }

        let width = boundingBox.maxColumn + 2
        let height = boundingBox.maxRow + 2
        var canvas = Canvas(columns: max(width, 1), rows: max(height, 1))
        document.render(into: &canvas)

        let lines = canvas.render().split(separator: "\n", omittingEmptySubsequences: false)
        let trimmedLines = lines.map { line in
            var value = String(line)
            while value.last == " " {
                value.removeLast()
            }
            return value
        }

        var output = trimmedLines
        while output.last?.isEmpty == true {
            output.removeLast()
        }
        return output.joined(separator: "\n")
    }
}
