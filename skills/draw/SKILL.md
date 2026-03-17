---
name: draw
description: Create YuzuDraw diagrams by choosing the right family and following a short reference for architecture, components, flow, bar charts, or ASCII art
user_invocable: true
---

# /draw — Create Diagrams in YuzuDraw

Use this as the single entrypoint for diagram work. Select one family, open the matching reference, then write DSL.

## Workflow

1. Classify the request into one primary diagram family.
2. Open the matching reference file under `references/`.
3. Follow that reference's defaults instead of improvising a generic style.
4. Pass DSL to CLI commands using a heredoc with `--dsl-stdin` (see CLI Invocation Rules below). Every command MUST start with `yuzudraw-cli` — never use pipes, `cat`, or `echo`.
5. Always display the rendered ASCII output in a fenced code block in your response so the user can see it directly without expanding tool results.
6. After rendering, ask the user if they'd like to save the diagram (via `create-diagram` or `update-diagram`). Always prompt — don't assume they only wanted a preview.

If a `yuzudraw-cli` command fails with "command not found", ask the user to install it with `curl -fsSL https://www.yuzudraw.com/install.sh | sh`, then retry.

## CLI Invocation Rules

Every CLI call MUST start with `yuzudraw-cli` so it can be allowlisted. Pass DSL inline via heredoc — no temp files, no pipes, no `cat`/`echo`.

- **Render:**
  ```
  yuzudraw-cli render-ascii --dsl-stdin <<'EOF'
  rect "hello" id box at 5,5 size 10x3
  EOF
  ```
- **Create:**
  ```
  yuzudraw-cli create-diagram --name <name> --dsl-stdin <<'EOF'
  ...DSL...
  EOF
  ```
- **Update:**
  ```
  yuzudraw-cli update-diagram --name <name> --dsl-stdin <<'EOF'
  ...DSL...
  EOF
  ```

Do NOT use pipes (`cat file | yuzudraw-cli`), `--dsl-file`, or any command that does not start with `yuzudraw-cli`.

## Family Selection

Open [architecture.md](/Users/agavra/dev/yuzudraw/skills/draw/references/architecture.md) when the request is about:
- system topology
- regions, zones, groups, tiers
- cross-boundary relationships
- repeated nodes and framed areas
- high-level runtime structure

Open [components.md](/Users/agavra/dev/yuzudraw/skills/draw/references/components.md) when the request is about:
- modules, packages, services, subsystems
- interfaces, APIs, dependencies
- internal product structure
- ownership or containment boundaries

Open [flow.md](/Users/agavra/dev/yuzudraw/skills/draw/references/flow.md) when the request is about:
- workflows, pipelines, lifecycles
- request or response paths
- ordered steps
- branching, retries, approvals, state transitions

Open [bar-chart.md](/Users/agavra/dev/yuzudraw/skills/draw/references/bar-chart.md) when the request is about:
- comparisons across categories
- ranked values
- before or after metrics
- stacked composition bars

Open [ascii-art.md](/Users/agavra/dev/yuzudraw/skills/draw/references/ascii-art.md) when the request is about:
- illustrations, icons, scenes, mascots
- title art or decorative callouts
- “draw” / “sketch” / “ASCII art” requests

## Explicit Overrides

If the user explicitly names a family, use it instead of re-classifying.

## Mixed Requests

Choose one dominant family:
- architecture if structure and regions matter most
- components if internal parts matter most
- flow if order matters most
- bar-chart if comparison matters most
- ascii-art if illustration is the deliverable

## Shared Rules

- Prefer a clear house style for the selected family over generic box-and-arrow output.
- Leave a small buffer on the top and left by default. Start around `col 2-4` and `row 1-2` unless the prompt or composition needs a different origin.
- Use groups to organize related elements whenever a diagram has 2+ logical categories (e.g., services vs data stores, frontend vs backend, internal vs external). Framed regions with `style double` or `style heavy` make diagrams far more readable than flat layouts. When in doubt, group.
- Use shading semantically, not decoratively.
- Use `pencil` sparingly unless the selected reference calls for it.
- If the user asks for “a diagram like X”, match X's composition first, then map it into YuzuDraw DSL.

## DSL Reference

### Document Structure

```
layer “Layer Name” visible|hidden [locked]
  [group “Group Name”]
    <shapes...>
```

- One or more layers; each layer has shapes and optional groups
- Indentation is 2 spaces per level
- Rects must be defined before arrows that reference them

### Rectangle (`rect`)

```
rect “Label” [id NAME] [at col,row] [size WxH] [POSITION] [PROPERTIES...]
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
| fill | transparent | `fill solid char “x”` |
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
arrow from ENDPOINT to ENDPOINT [style single|double|heavy] [label “text”] [strokeColor #RRGGBB] [labelColor #RRGGBB] [float]
```

**Endpoint formats:**
- `”Label”.side` — named attachment (side: left, right, top, bottom)
- `”Label”` — auto-infers side from relative position
- `col,row` — absolute coordinates
- `ID.side` or bare `ID` — reference by element ID

Arrow style defaults to `single` (omitted in serialized output).

### Text

```
text “content” at col,row [textColor #RRGGBB]
```

Use `\n` for newlines. Supports reference coordinates in `at`.

### Pencil

```
pencil at col,row cells [col,row,”char”;col,row,”char”,#color;...]
```

Freeform characters at relative offsets. Supports reference coordinates in `at`.

### Element IDs

Optional `id` keyword for naming elements:

```
rect “Server” id srv1 at 0,0 size 14x3
rect “Server” id srv2 at 20,0 size 14x3
```

**Rules:**
- Format: `[a-zA-Z_][a-zA-Z0-9_]*` (no keywords like `at`, `size`, `style`, etc.)
- Unquoted reference = ID lookup: `at srv1.right+4,0`
- Quoted reference = label lookup: `at “Server”.right+4,0`
- Required for: empty labels, duplicate labels
- Optional for: unique non-empty labels

### Reference Coordinates

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
text “→” at “A”.right
rect “B” at “A”.right+4,0
```

**Origin reference** (no `.side`):
```
rect “E” at “A”+16,0
```

**Negative offsets:**
```
rect “F” at “A”.right-4,0
rect “G” at “A”.bottom+0,-2
```

### Arrow Side Inference

When arrow endpoints are bare references (no `.side`), sides are auto-inferred:

```
arrow from “A” to “B”              # auto-picks sides
arrow from “A”.right to “B”.left   # explicit sides
```

Algorithm: compare center points. Dominant axis wins (larger absolute delta). Each endpoint uses the side facing the other rect. Tied → prefer horizontal.

### Defaults Table

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
