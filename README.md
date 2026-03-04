<p align="center">
  <img src="yuzudraw-gh-banner.png" alt="YuzuDraw" />
</p>

<p align="center">
  A macOS ASCII diagram editor built with SwiftUI.<br/>
  Create boxes, arrows, and text shapes on a grid-based canvas and export them as plain-text diagrams.
</p>

## Features

- **Shape types** — Rectangles (with configurable border styles, fill, shadows), arrows (with orthogonal routing and attachment points), and free-form text
- **Drawing tools** — Selection, rectangle, arrow, and text tools with rubber-band preview and inline editing
- **Arrow attachments** — Arrows snap to rectangle sides and automatically re-route when rectangles move
- **Layers & grouping** — Hierarchical layer panel with visibility/lock toggles, drag-and-drop reorder, and shape grouping (Cmd+G)
- **Multi-project workspace** — Tabbed interface with a welcome screen, recent projects list, and auto-save
- **Inspector panel** — Edit shape properties including position, size, text alignment, border style, fill, and shadow
- **Grid with rulers** — Column and row rulers for precise positioning on a monospaced character grid
- **Serialization** — JSON-based `.yuzudraw` file format saved to `~/Documents/YuzuDraw/`, plus a human-readable DSL format

## Requirements

- macOS 14.0+
- Xcode 16.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

## Getting Started

```bash
# Generate the Xcode project
xcodegen generate

# Build
xcodebuild -scheme YuzuDraw -destination 'platform=macOS' build

# Run tests
xcodebuild -scheme YuzuDraw -destination 'platform=macOS' test
```

Or open the generated `YuzuDraw.xcodeproj` in Xcode and run from there.

## Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| Cmd+N | New project |
| Cmd+O | Open project |
| Cmd+S | Save |
| Cmd+Shift+S | Save as |
| Cmd+W | Close tab |
| Cmd+G | Group selected shapes |
| Delete | Delete selected shapes |
| Arrow keys | Move selected shapes |
| Escape | Deselect all |
| Double-click | Edit shape text inline |

## Architecture

The app follows an MVVM pattern using Swift 6 strict concurrency (`@Observable @MainActor` view models, `Codable + Sendable` models).

```
YuzuDraw/
├── App/             # Entry point and menu commands
├── Models/          # Document, shapes, geometry, canvas grid
├── ViewModels/      # EditorViewModel, WorkspaceViewModel
├── Views/           # SwiftUI views (canvas, panels, toolbar)
├── Tools/           # Stateless drawing tools returning ToolActions
├── Serialization/   # JSON codable, DSL format, file I/O
└── Resources/       # Assets, entitlements, Info.plist
```

Rendering works as a pipeline: **Document → RenderEngine → Canvas (2D char grid) → SwiftUI Text**. The canvas is a plain character buffer; shapes are always the source of truth and the full canvas is re-rendered on each mutation.

See [AGENTS.md](AGENTS.md) for detailed architectural documentation.
