# YuzuDraw — Claude Code Instructions

## Build & Run
- **Generate Xcode project:** `xcodegen generate` (run after adding/removing .swift files)
- **Build app:** `xcodebuild -scheme YuzuDraw -destination 'platform=macOS' build`
- **Build CLI:** `xcodebuild -project YuzuDraw.xcodeproj -scheme YuzuDrawCLI -configuration Debug build`
- **Test:** `xcodebuild -scheme YuzuDraw -destination 'platform=macOS' test`
- Swift 6 strict concurrency is enabled; all warnings are errors

## Architecture
- macOS ASCII diagram editor built with SwiftUI (Swift 6, macOS 14+)
- `@Observable @MainActor` for view models
- `Codable, Equatable, Sendable` for model types
- DSL text format for `.yuzudraw` files (see `DSLParser.swift`, `DSLSerializer.swift`)
- Shared automation layer in `YuzuDraw/Automation/DiagramAutomationService.swift`

## CLI Automation

YuzuDraw uses a CLI instead of MCP. The CLI wraps the shared automation service and edits `.yuzudraw` files directly.

### Files
- `YuzuDrawCLI/main.swift` — command parsing and command execution
- `YuzuDraw/Automation/DiagramAutomationService.swift` — create/update/get/list/render behavior
- `scripts/yuzudraw-cli.sh` — helper that finds (or builds) the latest `YuzuDrawCLI` binary

### Commands
- `create-diagram --name <name> [--project <path>] (--dsl-file <path> | --dsl-stdin)`
- `update-diagram --name <name> [--project <path>] (--dsl-file <path> | --dsl-stdin)`
- `get-diagram --name <name> [--project <path>] [--format dsl|ascii|both]`
- `list-diagrams [--workspace-dir <path>]`
- `render-ascii (--dsl-file <path> | --dsl-stdin)`

### Keeping CLI and skill docs in sync
When modifying any of the following, also update the corresponding components:

| Change | Also update |
|--------|-------------|
| DSL syntax (parser/serializer) | `skills/draw/SKILL.md` and relevant reference files |
| CLI command names, arguments, or behavior | `skills/draw/SKILL.md` and `skills/draw/references/flow.md` |
| New shape types or properties | `DSLParser.swift`, `DSLSerializer.swift`, `skills/draw/references/components.md` |

## Claude Code Skills (`skills/`)

### `/draw` (`skills/draw/SKILL.md`)
Unified drawing skill for all diagram types: architecture diagrams, component diagrams, flowcharts, bar charts, and ASCII art. Contains references for each diagram family in `skills/draw/references/`.

To install skills for Claude Code, copy them:
```sh
mkdir -p ~/.claude/skills/draw/references
cp skills/draw/SKILL.md ~/.claude/skills/draw/SKILL.md
cp skills/draw/references/*.md ~/.claude/skills/draw/references/
```
