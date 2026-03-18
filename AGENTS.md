# YuzuDraw

A macOS app for drawing ASCII diagrams (Monodraw/Figma-like).

## Build & Test

```bash
# Generate Xcode project (after modifying project.yml)
xcodegen generate

# Build (warnings are treated as errors via project.yml settings)
xcodebuild -scheme YuzuDraw -destination 'platform=macOS' build

# Run tests (UI smoke tests are excluded from the scheme; only unit tests run)
xcodebuild -scheme YuzuDraw -destination 'platform=macOS' test

# Build CLI
xcodebuild -project YuzuDraw.xcodeproj -scheme YuzuDrawCLI -configuration Debug build
```

## Project Structure

- `project.yml` — XcodeGen spec (source of truth for the Xcode project)
- `YuzuDraw/App/` — App entry point (`YuzuDrawApp` with `WorkspaceViewModel`)
- `YuzuDraw/Models/` — Data models (Canvas, Geometry, Shapes, Layers, Document, ProjectMetadata, ProjectTab, RecentProject)
- `YuzuDraw/Views/` — SwiftUI views (RootView, WelcomeView, TabBarContentView, ContentView, CanvasView, ToolbarView, LayerPanel, InspectorPanel)
- `YuzuDraw/ViewModels/` — Observable view models (WorkspaceViewModel, EditorViewModel)
- `YuzuDraw/Tools/` — Drawing tool system (Tool protocol, SelectionTool, RectangleTool, ArrowTool, TextTool)
- `YuzuDraw/Serialization/` — Document persistence (JSON via DocumentCodable, DSL via DSLSerializer/DSLParser, ProjectFileManager for file I/O)
- `YuzuDraw/Automation/` — Shared automation service for CLI workflows (`DiagramAutomationService`)
- `YuzuDrawCLI/` — CLI entrypoint and command handling
- `YuzuDraw/Resources/` — Assets, Info.plist, entitlements
- `YuzuDrawTests/` — Unit tests

## Architecture

### Rendering Pipeline

```
Document (shapes, layers, groups)  ← semantic model, source of truth
    │
    ▼
RenderEngine: iterate layers bottom→top, render visible shapes
    │
    ▼
Canvas (2D character grid)  ← "framebuffer", re-rendered on every mutation
    │
    ▼
CanvasView: displays Canvas.render() as monospaced Text
```

- `Canvas` is a dumb 2D character grid — shapes are the source of truth, not canvas cells
- `Document.render(into:)` clears canvas then renders all visible layers/shapes in order
- `EditorViewModel.rerender()` is called after every document mutation

### Tool System

- Tools conform to the `Tool` protocol with `mouseDown`/`mouseDragged`/`mouseUp` returning `ToolAction` enums
- `ToolAction` cases: `.addShape`, `.selectShape`, `.updateShape`, `.beginTextEdit`, `.none`
- Tools are stateful (track drag start point) but the ViewModel applies all actions to the document
- `RectangleTool` and `ArrowTool` expose `previewShape()` for rubber-band rendering during drag

### Shape Model

- `AnyShape` is a type-erased enum (`.rectangle`, `.arrow`, `.text`) — not a protocol, for easy `Codable`/`Equatable`
- Each shape has `render(into: &Canvas)`, `contains(point:)`, and `boundingRect`
- `RectangleShape` supports 4 border styles (single/double/rounded/heavy) via `BorderStyle` enum mapping to Unicode box-drawing chars
- `ArrowShape` generates L-shaped orthogonal paths (horizontal-first) with directional arrowheads (▶◀▲▼)

### Serialization

Two-tier serialization designed for AI agent interaction:
- **JSON**: automatic via `Codable`, uses `"type"` discriminator key in `AnyShape`
- **DSL**: concise line-oriented format (`rectangle "Server" at 5,3 size 20x5 style single`)

### Multi-Project / Workspace

```
YuzuDrawApp
  └── RootView
       ├── WelcomeView                 (when no tabs open — New/Open buttons, recent projects grid)
       └── TabBarContentView           (when tabs open)
            ├── Custom tab bar (36pt, aligned with traffic lights, hiddenTitleBar window style)
            └── ContentView(viewModel:, onDocumentChange:)
```

- `WorkspaceViewModel` (`@Observable @MainActor`) owns tab state and an `editors: [UUID: EditorViewModel]` dictionary — one `EditorViewModel` per open project
- Projects are saved as `.yuzudraw` JSON files in `~/Documents/YuzuDraw/` via `ProjectFileManager`
- Auto-save runs every 30s for dirty tabs; dirty tracking via `ContentView.onChange(of: viewModel.document)`
- Recent projects persisted in `UserDefaults`, filtered for existence on load
- Double-click a tab to rename (also renames the file on disk)

### UI Layout

3-panel HSplitView: LayerPanel (left sidebar) | CanvasView (center) | InspectorPanel (right sidebar), with ToolbarView on top.

### CanvasView Coordinate System

`CanvasView` uses a `ZStack` inside a `ScrollView` with ruler gutters (`rulerGutterLeft`, `rulerGutterTop`). All grid overlays and the canvas text are offset by the gutter amounts. Gesture and hover handlers subtract the gutter to convert from frame coordinates to grid-local coordinates, then divide by `charSize` to get a `GridPoint`.

**Critical**: The `.frame()` on the ZStack **must** use `alignment: .topLeading`. Default `.center` alignment shifts content by `gutterSize/2` pixels, causing hover/drag coordinates to be offset from visual positions (the offset grows with distance from origin).

**Cursor management**: All cursor changes are centralized in `handleCanvasHover` on the parent ZStack's `onContinuousHover`. Do NOT use `.onHover` on individual overlay elements positioned with `.offset()` — SwiftUI's `.offset()` moves the visual but not the hit-test area, so `.onHover` fires at the wrong position. Instead, detect proximity to handles in the parent hover handler and set cursors there.

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

## Conventions

- Architecture: MVVM with `@Observable` view models
- UI: SwiftUI, targeting macOS 14+
- Swift version: 6.0 with strict concurrency; warnings are treated as errors (`SWIFT_TREAT_WARNINGS_AS_ERRORS`, `GCC_TREAT_WARNINGS_AS_ERRORS` in `project.yml`)
- Tests: Swift Testing framework (`import Testing`), use given/when/then pattern, name tests `should_xyz`
- Regenerate `YuzuDraw.xcodeproj` with `xcodegen generate` after adding/removing Swift files or changing `project.yml` — the `.xcodeproj` is gitignored
- New Swift files are auto-discovered by XcodeGen from directory structure (no need to edit `project.yml`), but you **must** run `xcodegen generate` to pick them up
- Tool classes use `@unchecked Sendable` since they're only accessed from `@MainActor` EditorViewModel
