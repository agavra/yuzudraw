# YuzuDraw DSL Reference

## Overview

The YuzuDraw DSL is a text format for describing ASCII diagrams. It's used in `.yuzudraw` files and via the MCP tools (`create_diagram`, `update_diagram`, `get_diagram`).

## Document Structure

```
layer "Layer Name" visible|hidden [locked]
  [group "Group Name"]
    <shapes...>
```

- One or more layers; each layer has shapes and optional groups
- Indentation is 2 spaces per level
- Rects must be defined before arrows that reference them

## Shapes

### Rectangle (`rect`)

```
rect "Label" [id NAME] [at col,row] [size WxH] [POSITION] [PROPERTIES...]
```

Also accepts `rectangle` and `box` as aliases.

**Positioning** (pick one):
- `at col,row` — absolute position
- `at REF.SIDE+colOffset,rowOffset` — reference coordinates (see below)
- `right-of REF [gap N]` — to the right of another rect (default gap: 4)
- `below REF [gap N]` — below another rect (default gap: 2)
- `left-of REF [gap N]` — to the left (accounts for self width)
- `above REF [gap N]` — above (accounts for self height)
- Omitted → defaults to `0,0`

**Auto-sizing** (when `size` is omitted):
- `width = max(longestLine + 4, 10)`
- `height = lineCount + 2`
- Use `\n` for multiline labels

**Properties** (all optional, defaults shown):

| Property | Default | Syntax |
|----------|---------|--------|
| style | single | `style single\|double\|rounded\|heavy` |
| fill | transparent | `fill solid char "x"` |
| border | visible | `noborder` to hide |
| borders | all | `borders top,bottom,left,right` |
| line | solid | `line dashed dash N gap N` |
| halign | center | `halign left\|center\|right` |
| valign | middle | `valign top\|middle\|bottom` |
| textOnBorder | false | `textOnBorder` (bare flag = true) |
| padding | 0,0,0,0 | `padding L,R,T,B` |
| shadow | none | `shadow light\|medium\|dark\|full x N y N` |
| borderColor | none | `borderColor #RRGGBB` |
| fillColor | none | `fillColor #RRGGBB` |
| textColor | none | `textColor #RRGGBB` |
| float | false | `float` |

### Arrow

```
arrow from ENDPOINT to ENDPOINT [style single|double|heavy] [label "text"] [strokeColor #RRGGBB] [labelColor #RRGGBB] [float]
```

**Endpoint formats:**
- `"Label".side` — named attachment (side: left, right, top, bottom)
- `"Label"` — auto-infers side from relative position
- `col,row` — absolute coordinates
- `ID.side` or bare `ID` — reference by element ID

Arrow style defaults to `single` (omitted in serialized output).

### Text

```
text "content" at col,row [textColor #RRGGBB]
```

Use `\n` for newlines. Supports reference coordinates in `at`.

### Pencil

```
pencil at col,row cells [col,row,"char";col,row,"char",#color;...]
```

Freeform characters at relative offsets. Supports reference coordinates in `at`.

## Element IDs

Optional `id` keyword for naming elements:

```
rect "Server" id srv1 at 0,0 size 14x3
rect "Server" id srv2 at 20,0 size 14x3
```

**Rules:**
- Format: `[a-zA-Z_][a-zA-Z0-9_]*` (no keywords like `at`, `size`, `style`, etc.)
- Unquoted reference = ID lookup: `at srv1.right+4,0`
- Quoted reference = label lookup: `at "Server".right+4,0`
- Required for: empty labels, duplicate labels
- Optional for: unique non-empty labels

## Reference Coordinates

Position any element relative to a rect's edges:

```
at REF.SIDE+colOffset,rowOffset
```

**Edge reference points:**
- `.right` → `(ref.col + ref.width, ref.row)`
- `.bottom` → `(ref.col, ref.row + ref.height)`
- `.left` → `(ref.col, ref.row)` (same as origin, for readability)
- `.top` → `(ref.col, ref.row)` (same as origin, for readability)

**Offset can be omitted** (defaults to `+0,0`):
```
text "→" at "A".right
rect "B" at "A".right+4,0
```

**Origin reference** (no `.side`):
```
rect "E" at "A"+16,0
```

**Negative offsets:**
```
rect "F" at "A".right-4,0
rect "G" at "A".bottom+0,-2
```

## Arrow Side Inference

When arrow endpoints are bare references (no `.side`), sides are auto-inferred:

```
arrow from "A" to "B"              # auto-picks sides
arrow from "A".right to "B".left   # explicit sides
```

Algorithm: compare center points. Dominant axis wins (larger absolute delta). Each endpoint uses the side facing the other rect. Tied → prefer horizontal.

## Defaults Table

Properties at default values are omitted from serialized output:

| Property | Default | Omitted when |
|----------|---------|-------------|
| `style` | single | `strokeStyle == .single` |
| `fill` | transparent | `fillMode == .transparent` |
| `border` | visible | `hasBorder == true` |
| `halign` | center | `textHorizontalAlignment == .center` |
| `valign` | middle | `textVerticalAlignment == .middle` |
| `textOnBorder` | false | `allowTextOnBorder == false` |
| `padding` | 0,0,0,0 | all zeros |
| arrow `style` | single | `strokeStyle == .single` |

## Examples

### Horizontal flow
```
layer "Diagram" visible
  rect "Input" at 0,0 size 12x3
  rect "Process" right-of "Input"
  rect "Output" right-of "Process"
  arrow from "Input" to "Process"
  arrow from "Process" to "Output"
```

### Vertical stack
```
layer "Diagram" visible
  rect "Frontend" style rounded
  rect "API" below "Frontend"
  rect "Database" below "API" style double
  arrow from "Frontend" to "API" label "HTTP"
  arrow from "API" to "Database" label "SQL"
```

### Architecture diagram
```
layer "Diagram" visible
  rect "Client" at 0,0 size 12x3 style rounded
  rect "Server" right-of "Client" size 12x3
  rect "Cache" at "Server".bottom+0,2 size 12x3
  arrow from "Client" to "Server" label "request"
  arrow from "Server" to "Cache" label "read"
```

### Bar chart
```
layer "Chart" visible
  group "Bar Chart"
    rect "Revenue by Region" at 0,0 size 22x3
    rect "" id container at 0,2 size 67x5
    text "APAC" at 2,3
    rect "" id bar1 at 10,3 size 50x1 fill solid char "▓" noborder
    text "$1.00" at bar1.right+1,0
    text "EMEA" at 2,4
    rect "" id bar2 at 10,4 size 35x1 fill solid char "▓" noborder
    text "$0.70" at bar2.right+1,0
    pencil at container.left+9,3 cells [0,0,"│";0,1,"│";0,2,"│"]
```
