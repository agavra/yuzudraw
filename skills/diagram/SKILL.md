---
name: diagram
description: Create and edit ASCII diagrams in YuzuDraw
user_invocable: true
---

# /diagram — Create ASCII Diagrams in YuzuDraw

When the user invokes `/diagram <description>`, create a diagram using the YuzuDraw MCP server.

## Workflow

1. Parse the user's description to determine what kind of diagram to create
2. Write YuzuDraw DSL text following the syntax reference below
3. Call the `create_diagram` MCP tool with a name and the DSL
4. The diagram appears live in the YuzuDraw app and the ASCII render is returned

For updates, use `update_diagram`. To read back user edits, use `get_diagram`.

## DSL Syntax Reference

### Layer header
```
layer "Layer Name" visible|hidden [locked]
```

### Box
```
box "Label" at col,row size WxH [style single|double|rounded|heavy] [fill transparent|solid] [border visible|hidden]
```

Optional box properties (append after the basics):
- `style single|double|rounded|heavy` — border stroke style
- `fill transparent|solid [char "x"]` — fill mode; solid can specify fill character
- `border visible|hidden` — show/hide border
- `borders top,bottom,left,right` — selective border sides
- `line dashed dash N gap N` — dashed border
- `halign left|center|right` — text horizontal alignment (default: center)
- `valign top|middle|bottom` — text vertical alignment (default: middle)
- `textOnBorder true|false` — allow text to render on border
- `padding L,R,T,B` — text padding (left,right,top,bottom)
- `shadow light|medium|dark|full x N y N` — drop shadow
- `borderColor #RRGGBB` — border color
- `fillColor #RRGGBB` — fill color
- `textColor #RRGGBB` — text color

### Arrow

**Always use named attachments** to connect arrows to boxes. This ensures arrows are properly attached and will follow boxes when they move:

```
arrow from "BoxLabel".side to "BoxLabel".side [style single|double|heavy] [label "text"]
```

Where `side` is one of: `left`, `right`, `top`, `bottom`.

The arrow automatically computes the correct coordinates from the box's edge center point:
- `.left` — center of the left edge
- `.right` — center of the right edge
- `.top` — center of the top edge
- `.bottom` — center of the bottom edge

Raw coordinate syntax is also supported but should be avoided when connecting to boxes:
```
arrow from col,row to col,row [style single|double|heavy] [label "text"]
```

Optional arrow properties:
- `strokeColor #RRGGBB`
- `labelColor #RRGGBB`

### Text
```
text "content" at col,row [textColor #RRGGBB]
```
Use `\n` for newlines in text content.

### Pencil (freeform characters)
```
pencil at col,row cells [col,row,"char";col,row,"char",#color;...]
```

### Groups
```
layer "Layer 1" visible
  group "Group Name"
    box "A" at 0,0 size 10x3 style single fill transparent
    box "B" at 14,0 size 10x3 style single fill transparent
```
Groups use indent-based nesting (2-space indent per level).

## Layout Heuristics

### Box sizing
- Width = `max(label.length + 4, 10)` (minimum 10 for readability)
- Height = 3 for single-line labels, add 1 per extra line
- For multi-word labels, consider wrapping: width = longest_word + 4

### Spacing
- Horizontal gap between boxes: 4 characters minimum (arrows need space)
- Vertical gap between boxes: 2 rows minimum
- Named attachments auto-compute arrow coordinates, so you only need to position boxes

### Common patterns

**Horizontal flow (3 boxes with arrows):**
```
layer "Diagram" visible
  box "Input" at 0,0 size 12x3 style single fill transparent
  box "Process" at 16,0 size 12x3 style single fill transparent
  box "Output" at 32,0 size 12x3 style single fill transparent
  arrow from "Input".right to "Process".left style single
  arrow from "Process".right to "Output".left style single
```

**Vertical stack:**
```
layer "Diagram" visible
  box "Top" at 5,0 size 12x3 style single fill transparent
  box "Middle" at 5,5 size 12x3 style single fill transparent
  box "Bottom" at 5,10 size 12x3 style single fill transparent
  arrow from "Top".bottom to "Middle".top style single
  arrow from "Middle".bottom to "Bottom".top style single
```

**Architecture diagram:**
```
layer "Diagram" visible
  box "Frontend" at 0,0 size 14x3 style rounded fill transparent
  box "API" at 0,5 size 14x3 style single fill transparent
  box "Database" at 0,10 size 14x3 style double fill transparent
  arrow from "Frontend".bottom to "API".top style single label "HTTP"
  arrow from "API".bottom to "Database".top style single label "SQL"
```

**Bidirectional / complex connections:**
```
layer "Diagram" visible
  box "Client" at 0,0 size 12x3 style rounded fill transparent
  box "Server" at 20,0 size 12x3 style single fill transparent
  box "Cache" at 20,5 size 12x3 style single fill transparent
  arrow from "Client".right to "Server".left style single label "request"
  arrow from "Server".bottom to "Cache".top style single label "read"
```

## Tips
- **Always use named attachments** (`"BoxLabel".side`) for arrows connecting to boxes — never manually compute arrow coordinates
- Boxes must be defined before arrows that reference them in the DSL
- Use `render_ascii` to preview before creating (doesn't save)
- Use `list_diagrams` to see what's open
- Use `get_diagram` to read back user edits before updating
- Keep diagrams simple — ASCII art has limited resolution
- Prefer `style rounded` for UI components, `style double` for databases/storage, `style single` for general boxes
