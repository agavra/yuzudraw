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

### Rectangle
```
rect "Label" [id NAME] [at POSITION] [size WxH] [PROPERTIES...]
```

Also accepts `rectangle` and `box` as aliases.

**Positioning** (pick one — prefer relative for simpler DSL):
- `at col,row` — absolute coordinates
- `at REF.SIDE+colOffset,rowOffset` — relative to another rect's edge
- `right-of REF [gap N]` — default gap 4
- `below REF [gap N]` — default gap 2
- `left-of REF [gap N]` — accounts for self width
- `above REF [gap N]` — accounts for self height
- Omitted → defaults to `0,0`

Where `REF` is a `"quoted label"` or unquoted `id`. Side is `right|bottom|left|top`.

**Auto-sizing** (when `size` is omitted):
- `width = max(longestLine + 4, 10)`, `height = lineCount + 2`

**Properties** (all optional, omit for defaults):
- `style single|double|rounded|heavy` — border stroke (default: single, omit)
- `fill solid char "x"` — fill mode (default: transparent, omit)
- `noborder` — hide border (default: visible, omit)
- `borders top,bottom,left,right` — selective border sides
- `line dashed dash N gap N` — dashed border
- `halign left|center|right` — text horizontal alignment (default: center, omit)
- `valign top|middle|bottom` — text vertical alignment (default: middle, omit)
- `textOnBorder` — bare flag, allow text on border (default: false, omit)
- `padding L,R,T,B` — text padding (default: 0,0,0,0, omit)
- `shadow light|medium|dark|full x N y N` — drop shadow
- `borderColor #RRGGBB` / `fillColor #RRGGBB` / `textColor #RRGGBB`
- `float` — disable border merging

### Element IDs
```
rect "Server" id srv1                  # named for reference
rect "Server" id srv2                  # disambiguates duplicate label
rect "" id bar1 size 50x1 fill solid char "▓" noborder  # empty label needs ID
```

### Arrow

**Prefer bare references** — sides are auto-inferred from relative positions:
```
arrow from "A" to "B" [label "text"]
arrow from srv1 to srv2 [label "text"]
```

Explicit sides also work:
```
arrow from "A".right to "B".left [style double] [label "text"]
```

Optional properties:
- `style single|double|heavy` (default: single, omit)
- `strokeColor #RRGGBB` / `labelColor #RRGGBB`
- `float`

### Text
```
text "content" at col,row [textColor #RRGGBB]
```
Use `\n` for newlines. Supports reference coordinates: `text "$1.00" at bar1.right+1,0`

### Pencil (freeform characters)
```
pencil at col,row cells [col,row,"char";col,row,"char",#color;...]
```
Supports reference coordinates: `pencil at container.left+9,0 cells [...]`

### Groups
```
layer "Layer 1" visible
  group "Group Name"
    rect "A"
    rect "B" right-of "A"
```

## Layout Heuristics

### Rectangle sizing
- Auto-size handles most cases — just omit `size`
- Override with `size WxH` for non-standard dimensions (bars, containers)

### Spacing
- `right-of` / `left-of` default gap: 4 characters
- `below` / `above` default gap: 2 rows
- Custom gap: `right-of "A" gap 8`

### Common patterns

**Horizontal flow:**
```
layer "Diagram" visible
  rect "Input"
  rect "Process" right-of "Input"
  rect "Output" right-of "Process"
  arrow from "Input" to "Process"
  arrow from "Process" to "Output"
```

**Vertical stack:**
```
layer "Diagram" visible
  rect "Frontend" style rounded
  rect "API" below "Frontend"
  rect "Database" below "API" style double
  arrow from "Frontend" to "API" label "HTTP"
  arrow from "API" to "Database" label "SQL"
```

**Architecture diagram:**
```
layer "Diagram" visible
  rect "Client" style rounded
  rect "Server" right-of "Client"
  rect "Cache" at "Server".bottom+0,2
  arrow from "Client" to "Server" label "request"
  arrow from "Server" to "Cache" label "read"
```

**Bidirectional connections:**
```
layer "Diagram" visible
  rect "Client" style rounded
  rect "Server" right-of "Client"
  rect "Cache" at "Server".bottom+0,2
  arrow from "Client".right to "Server".left label "request"
  arrow from "Server".bottom to "Cache".top label "read"
```

## Tips
- **Omit defaults** — don't write `style single`, `fill transparent`, `border visible`, etc.
- **Use auto-sizing** — omit `size` for label-based rectangles
- **Use relative positioning** — `right-of`, `below`, reference coords
- **Use bare arrow refs** — `from "A" to "B"` instead of `from "A".right to "B".left`
- **Use IDs for empty/duplicate labels** — `rect "" id bar1 size 50x1 fill solid char "▓" noborder`
- Rectangles must be defined before arrows that reference them
- Use `render_ascii` to preview before creating
- Use `get_diagram` to read back user edits before updating
- Prefer `style rounded` for UI components, `style double` for databases/storage
