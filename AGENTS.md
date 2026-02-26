# AsciiAI

A macOS app for drawing ASCII diagrams (Monodraw/Figma-like).

## Build & Test

```bash
# Generate Xcode project (after modifying project.yml)
xcodegen generate

# Build
xcodebuild -project AsciiAI.xcodeproj -scheme AsciiAI -configuration Debug build

# Run tests
xcodebuild -project AsciiAI.xcodeproj -scheme AsciiAITests -configuration Debug test
```

## Project Structure

- `project.yml` — XcodeGen spec (source of truth for the Xcode project)
- `AsciiAI/App/` — App entry point
- `AsciiAI/Models/` — Data models (Canvas, Geometry, Shapes, Layers, Document)
- `AsciiAI/Views/` — SwiftUI views (ContentView, CanvasView, ToolbarView, LayerPanel, InspectorPanel)
- `AsciiAI/ViewModels/` — Observable view models (EditorViewModel)
- `AsciiAI/Tools/` — Drawing tool system (Tool protocol, SelectionTool, BoxTool, ArrowTool, TextTool)
- `AsciiAI/Serialization/` — Document persistence (JSON via DocumentCodable, DSL via DSLSerializer/DSLParser)
- `AsciiAI/Resources/` — Assets, Info.plist, entitlements
- `AsciiAITests/` — Unit tests

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
- `BoxTool` and `ArrowTool` expose `previewShape()` for rubber-band rendering during drag

### Shape Model

- `AnyShape` is a type-erased enum (`.box`, `.arrow`, `.text`) — not a protocol, for easy `Codable`/`Equatable`
- Each shape has `render(into: &Canvas)`, `contains(point:)`, and `boundingRect`
- `BoxShape` supports 4 border styles (single/double/rounded/heavy) via `BorderStyle` enum mapping to Unicode box-drawing chars
- `ArrowShape` generates L-shaped orthogonal paths (horizontal-first) with directional arrowheads (▶◀▲▼)

### Serialization

Two-tier serialization designed for AI agent interaction:
- **JSON**: automatic via `Codable`, uses `"type"` discriminator key in `AnyShape`
- **DSL**: concise line-oriented format (`box "Server" at 5,3 size 20x5 style single`)

### UI Layout

3-panel HSplitView: LayerPanel (left sidebar) | CanvasView (center) | InspectorPanel (right sidebar), with ToolbarView on top.

## Conventions

- Architecture: MVVM with `@Observable` view models
- UI: SwiftUI, targeting macOS 14+
- Swift version: 6.0 with strict concurrency
- Tests: Swift Testing framework (`import Testing`), use given/when/then pattern, name tests `should_xyz`
- Regenerate `AsciiAI.xcodeproj` with `xcodegen generate` after changing `project.yml` — the `.xcodeproj` is gitignored
- New files are auto-discovered by XcodeGen from directory structure (no need to edit `project.yml` for new Swift files)
- Tool classes use `@unchecked Sendable` since they're only accessed from `@MainActor` EditorViewModel
