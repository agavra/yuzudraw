import Foundation

enum MCPToolError: LocalizedError {
    case missingArgument(String)
    case diagramNotFound(String)
    case dslParseError(String)
    case unknownTool(String)

    var errorDescription: String? {
        switch self {
        case .missingArgument(let name): "Missing required argument: \(name)"
        case .diagramNotFound(let name): "No open diagram named '\(name)'"
        case .dslParseError(let detail): "DSL parse error: \(detail)"
        case .unknownTool(let name): "Unknown tool: \(name)"
        }
    }
}

@MainActor
final class MCPTools {
    private weak var workspace: WorkspaceViewModel?

    init(workspace: WorkspaceViewModel) {
        self.workspace = workspace
    }

    func call(tool: String, arguments: [String: Any]) async throws -> String {
        switch tool {
        case "create_diagram":
            return try createDiagram(arguments)
        case "update_diagram":
            return try updateDiagram(arguments)
        case "get_diagram":
            return try getDiagram(arguments)
        case "list_diagrams":
            return listDiagrams()
        case "render_ascii":
            return try renderASCII(arguments)
        default:
            throw MCPToolError.unknownTool(tool)
        }
    }

    // MARK: - Tool implementations

    private func createDiagram(_ args: [String: Any]) throws -> String {
        guard let workspace else { return "YuzuDraw is not available" }
        guard let name = args["name"] as? String else {
            throw MCPToolError.missingArgument("name")
        }
        guard let dsl = args["dsl"] as? String else {
            throw MCPToolError.missingArgument("dsl")
        }

        let document = try parseDSL(dsl)

        // Create a new tab
        workspace.newProject()

        guard let tabID = workspace.activeTabID,
            let tabIndex = workspace.tabs.firstIndex(where: { $0.id == tabID })
        else {
            return "Failed to create tab"
        }

        // Rename the tab
        workspace.tabs[tabIndex].metadata.name = name
        workspace.tabs[tabIndex].isStartPage = false

        // Set the document content
        if let editor = workspace.editors[tabID] {
            editor.document = document
            editor.rerender()
            let ascii = renderDocument(document)
            return "Diagram '\(name)' created.\n\n```\n\(ascii)\n```"
        }

        return "Diagram '\(name)' created but editor not available."
    }

    private func updateDiagram(_ args: [String: Any]) throws -> String {
        guard let workspace else { return "YuzuDraw is not available" }
        guard let name = args["name"] as? String else {
            throw MCPToolError.missingArgument("name")
        }
        guard let dsl = args["dsl"] as? String else {
            throw MCPToolError.missingArgument("dsl")
        }

        let document = try parseDSL(dsl)

        guard let (tabID, _) = findTab(named: name) else {
            throw MCPToolError.diagramNotFound(name)
        }

        if let editor = workspace.editors[tabID] {
            editor.recordSnapshot()
            editor.document = document
            editor.rerender()
            let ascii = renderDocument(document)
            return "Diagram '\(name)' updated.\n\n```\n\(ascii)\n```"
        }

        return "Diagram '\(name)' found but editor not available."
    }

    private func getDiagram(_ args: [String: Any]) throws -> String {
        guard let workspace else { return "YuzuDraw is not available" }
        guard let name = args["name"] as? String else {
            throw MCPToolError.missingArgument("name")
        }

        guard let (tabID, _) = findTab(named: name) else {
            throw MCPToolError.diagramNotFound(name)
        }

        guard let editor = workspace.editors[tabID] else {
            return "Diagram '\(name)' found but editor not available."
        }

        let dsl = DSLSerializer.serialize(editor.document)
        let ascii = renderDocument(editor.document)

        return "DSL:\n```\n\(dsl)\n```\n\nASCII:\n```\n\(ascii)\n```"
    }

    private func listDiagrams() -> String {
        guard let workspace else { return "YuzuDraw is not available" }

        let diagrams = workspace.tabs.filter { !$0.isStartPage }
        if diagrams.isEmpty {
            return "No diagrams open."
        }

        let names = diagrams.map { tab in
            let active = tab.id == workspace.activeTabID ? " (active)" : ""
            let dirty = tab.hasUnsavedChanges ? " *" : ""
            return "- \(tab.metadata.name)\(active)\(dirty)"
        }

        return "Open diagrams:\n\(names.joined(separator: "\n"))"
    }

    private func renderASCII(_ args: [String: Any]) throws -> String {
        guard let dsl = args["dsl"] as? String else {
            throw MCPToolError.missingArgument("dsl")
        }

        let document = try parseDSL(dsl)
        return renderDocument(document)
    }

    // MARK: - Helpers

    private func parseDSL(_ dsl: String) throws -> Document {
        do {
            return try DSLParser.parse(dsl)
        } catch {
            throw MCPToolError.dslParseError("\(error)")
        }
    }

    private func renderDocument(_ document: Document) -> String {
        // Compute tight bounding box and render into a fitted canvas
        guard let bbox = document.boundingBox() else {
            return "(empty diagram)"
        }

        let width = bbox.maxColumn + 2
        let height = bbox.maxRow + 2
        var canvas = Canvas(
            columns: max(width, 1),
            rows: max(height, 1)
        )
        document.render(into: &canvas)

        // Trim trailing whitespace from each line
        let lines = canvas.render().split(separator: "\n", omittingEmptySubsequences: false)
        let trimmed = lines.map { line in
            var s = String(line)
            while s.last == " " { s.removeLast() }
            return s
        }

        // Remove trailing empty lines
        var result = trimmed
        while result.last?.isEmpty == true {
            result.removeLast()
        }

        return result.joined(separator: "\n")
    }

    private func findTab(named name: String) -> (UUID, Int)? {
        guard let workspace else { return nil }
        guard let index = workspace.tabs.firstIndex(where: {
            $0.metadata.name == name && !$0.isStartPage
        }) else { return nil }
        return (workspace.tabs[index].id, index)
    }
}
