# YuzuDraw — Claude Code Instructions

## Build & Run
- **Generate Xcode project:** `xcodegen generate` (run after adding/removing .swift files)
- **Build:** `xcodebuild -scheme YuzuDraw -destination 'platform=macOS' build`
- **Test:** `xcodebuild -scheme YuzuDraw -destination 'platform=macOS' test`
- Swift 6 strict concurrency is enabled; all warnings are errors

## Architecture
- macOS ASCII diagram editor built with SwiftUI (Swift 6, macOS 14+)
- `@Observable @MainActor` for view models
- `Codable, Equatable, Sendable` for model types
- DSL text format for `.yuzudraw` files (see `DSLParser.swift`, `DSLSerializer.swift`)

## MCP Server (YuzuDraw/MCP/)
YuzuDraw embeds an MCP (Model Context Protocol) server that runs on `localhost:7842`. This allows Claude Code to create and edit diagrams in the running app.

### Files
- `MCPServer.swift` — NWListener-based HTTP server, handles POST /mcp
- `MCPRouter.swift` — JSON-RPC 2.0 protocol (initialize, tools/list, tools/call)
- `MCPTools.swift` — Tool implementations (create_diagram, update_diagram, get_diagram, list_diagrams, render_ascii)

### Important conventions
- The MCP server runs on the main actor; NWListener callbacks dispatch to `@MainActor` via `Task`
- Port file written to `~/.yuzudraw/mcp-port` on startup
- All document mutations go through `WorkspaceViewModel` and `EditorViewModel`
- Network entitlements (`com.apple.security.network.server/client`) are in `YuzuDraw/Resources/YuzuDraw.entitlements` — the `entitlements` section was removed from `project.yml` so xcodegen doesn't overwrite this file

### Keeping MCP and skill in sync
When modifying any of the following, **you must also update the corresponding components**:

| Change | Also update |
|--------|-------------|
| DSL syntax (parser/serializer) | `skills/diagram/SKILL.md` DSL reference section |
| MCP tool signatures or behavior | `skills/diagram/SKILL.md` and `skills/bar-chart/SKILL.md` workflow sections |
| MCP tool names or arguments | `MCPRouter.swift` tool schemas + `MCPTools.swift` handlers |
| New shape types or properties | `DSLParser.swift`, `DSLSerializer.swift`, `skills/diagram/SKILL.md`, and `skills/bar-chart/SKILL.md` |
| Port or endpoint changes | `.mcp.json` and `MCPServer.swift` |

## Claude Code Skills (`skills/`)

### `/diagram` (`skills/diagram/SKILL.md`)
General-purpose diagramming skill for flowcharts, architecture diagrams, and other box-and-arrow layouts. Contains DSL syntax reference, layout heuristics, and common patterns.

### `/bar-chart` (`skills/bar-chart/SKILL.md`)
Specialized skill for horizontal bar charts (simple, stacked, multi-section with legends). Contains bar chart layout variables, bar styles, and examples.

To install skills for Claude Code, copy them:
```sh
mkdir -p ~/.claude/skills/diagram ~/.claude/skills/bar-chart
cp skills/diagram/SKILL.md ~/.claude/skills/diagram/SKILL.md
cp skills/bar-chart/SKILL.md ~/.claude/skills/bar-chart/SKILL.md
```

## MCP Configuration
The `.mcp.json` at the repo root configures Claude Code to connect to YuzuDraw's MCP server:
```json
{
  "mcpServers": {
    "yuzudraw": {
      "type": "http",
      "url": "http://localhost:7842/mcp"
    }
  }
}
```
YuzuDraw must be running for the MCP connection to work.

### MCP Transport
The server implements MCP Streamable HTTP transport:
- Single endpoint: `POST /mcp` for all JSON-RPC messages
- Session management via `Mcp-Session-Id` header (assigned on `initialize`)
- `DELETE /mcp` to terminate sessions
- Notifications return `202 Accepted` (no body)
- Requests return `200 OK` with `application/json` body
