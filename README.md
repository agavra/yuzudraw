<p align="center">
  <img src="yuzudraw-gh-banner.png" alt="YuzuDraw" />
</p>

<p align="center">
  <b>A native macOS editor for creating ASCII diagrams.</b><br/>
  Draw boxes, arrows, and text on a character grid — export as plain text.<br/>
  <a href="https://www.yuzudraw.com">www.yuzudraw.com</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS_14%2B-blue" alt="macOS 14+" />
  <img src="https://img.shields.io/badge/swift-6.0-orange" alt="Swift 6" />
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="License" /></a>
</p>

---

## Why YuzuDraw?

ASCII diagrams live in code comments, markdown docs, and terminal output — but creating them by hand is tedious. YuzuDraw gives you a real diagram editor that outputs plain text. Draw with your mouse, export as characters.

It also ships with a built-in **MCP server**, so Claude Code (or any MCP client) can create and edit diagrams programmatically.

## Download

Grab the latest `.dmg` from the [Releases](../../releases) page — universal binary for Apple Silicon and Intel.

Or build from source (see [below](#building-from-source)).

## Features

### Drawing tools
- **Rectangles** with configurable borders (single, double, rounded, heavy), fill patterns, dashed lines, and drop shadows
- **Arrows** with orthogonal routing, smart bend directions, and 8 head styles (filled, open, dot, diamond, and more)
- **Text** — free-form labels placed anywhere on the canvas
- **Pencil** — pixel-level freeform drawing, one character at a time

### Editing
- **Arrow attachments** — arrows snap to rectangle sides and follow them when you move shapes
- **Inspector panel** — fine-tune position, size, text alignment, padding, border styles, fill, shadows, and colors
- **Inline text editing** — double-click any shape to edit its label
- **Undo / Redo** — full history for every change

### Organization
- **Layers** — visibility and lock toggles, drag-and-drop reorder
- **Groups** — nest shapes hierarchically with Cmd+G
- **Multi-tab workspace** — work on multiple diagrams side-by-side with auto-save

### AI integration (MCP)
YuzuDraw embeds an [MCP](https://modelcontextprotocol.io) server on `localhost:7842`. Claude Code can:
- **Create diagrams** from a text description via `/diagram`
- **Read back** your manual edits
- **Update** existing diagrams in-place
- **Preview** ASCII output without saving

See [Claude Code integration](#claude-code-integration) for setup.

## DSL format

Diagrams can be authored in a human-readable DSL:

```
layer "Default" visible
  rectangle "Client" at 2,2 size 16x5 style rounded
  rectangle "Server" at 28,2 size 16x5 style rounded
  arrow from "Client".right to "Server".left label "request"
  arrow from "Server".left to "Client".right label "response"
```

Produces:

```
  ╭──────────────╮          ╭──────────────╮
  │              │ request  │              │
  │    Client    │─────────>│    Server    │
  │              │<─────────│              │
  │              │ response │              │
  ╰──────────────╯          ╰──────────────╯
```

The DSL supports all shape types, properties, layers, groups, and colors. See [`skills/diagram/SKILL.md`](skills/diagram/SKILL.md) for the full syntax reference.

## Keyboard shortcuts

| Shortcut | Action |
|---|---|
| **V** / **R** / **L** / **T** / **P** / **H** | Selection / Rectangle / Arrow / Text / Pencil / Hand tool |
| **Cmd+N** | New project |
| **Cmd+O** | Open project |
| **Cmd+S** | Save |
| **Cmd+Shift+S** | Save as |
| **Cmd+W** | Close tab |
| **Cmd+G** | Group selected shapes |
| **Cmd+A** | Select all |
| **Delete** | Delete selected |
| **Arrow keys** | Nudge selected shapes |
| **Escape** | Deselect all |
| **Double-click** | Edit shape text inline |

## Claude Code integration

1. **Install the skill** (one-time):
   ```bash
   mkdir -p ~/.claude/skills/diagram
   ln -sf "$(pwd)/skills/diagram/SKILL.md" ~/.claude/skills/diagram/SKILL.md
   ```

2. **Copy the MCP config** — the repo includes `.mcp.json`, which Claude Code picks up automatically when you run it from the project root.

3. **Launch YuzuDraw**, then use `/diagram` in Claude Code:
   ```
   /diagram a 3-tier web architecture with load balancer, app servers, and database
   ```

The MCP server exposes five tools: `create_diagram`, `update_diagram`, `get_diagram`, `list_diagrams`, and `render_ascii`.

## Building from source

**Requirements:** macOS 14+, Xcode 16+, [XcodeGen](https://github.com/yonaskolb/XcodeGen)

```bash
# Generate the Xcode project
xcodegen generate

# Build
xcodebuild -scheme YuzuDraw -destination 'platform=macOS' build

# Run tests
xcodebuild -scheme YuzuDraw -destination 'platform=macOS' test
```

Or open `YuzuDraw.xcodeproj` in Xcode and hit Run.

## Architecture

MVVM with Swift 6 strict concurrency. The rendering pipeline:

```
Document (shapes, layers) → RenderEngine → Canvas (2D char grid) → SwiftUI Text
```

The canvas is a character buffer — shapes are always the source of truth and the full grid is re-rendered on each mutation.

```
YuzuDraw/
├── App/             # Entry point and menu commands
├── Models/          # Document, shapes, geometry, canvas grid
├── ViewModels/      # EditorViewModel, WorkspaceViewModel
├── Views/           # SwiftUI views (canvas, panels, toolbar)
├── Tools/           # Stateless drawing tools returning ToolActions
├── Serialization/   # JSON codable, DSL parser/serializer
├── MCP/             # Embedded MCP server for AI integration
└── Resources/       # Assets, entitlements, Info.plist
```

## Support YuzuDraw

YuzuDraw is free and open source. If you find it useful, please consider [sponsoring the project](https://github.com/sponsors/agavra) — it helps cover the Apple Developer license and keeps development going.

## License

[MIT](LICENSE)

Copyright &copy; 2026 Almog Gavra
