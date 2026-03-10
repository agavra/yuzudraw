---
name: bar-chart
description: Create horizontal bar charts in YuzuDraw
user_invocable: true
---

# /bar-chart — Create Horizontal Bar Charts in YuzuDraw

When the user invokes `/bar-chart <description>`, create a horizontal bar chart using the YuzuDraw MCP server.

## Workflow

1. Parse the user's description to extract data (labels, values, optional segments)
2. Compute layout variables from the data (see below)
3. Write YuzuDraw DSL following the bar chart pattern
4. Call `create_diagram` with a name and the DSL
5. The chart appears live in YuzuDraw and the ASCII render is returned

For updates, use `update_diagram`. To read back user edits, use `get_diagram`.

## Bar Chart Structure

Bar charts use borderless filled rectangles inside a bordered container:

- **Title box** — rectangle with label, overlapping the container top border (row offset -2)
- **Container** — empty bordered rectangle framing all data rows (height = num_rows + 2)
- **Per row** — label text + one or more filled bar segments + value text
- **Separator** — pencil with `│` between label column and bar column

## Layout Variables

Adjust these to fit your data:

| Variable | Description | Default |
|----------|-------------|---------|
| `L` | Label area width (longest label + 3 for padding) | 10 |
| `B` | Max bar width (full-scale bar length) | 50 |
| `V` | Value area width (longest value string + 2) | 7 |

Derived values:
- Container width = `L + B + V`
- Bar col = container col + `L`
- Bar width = `round(value / max_value * B)`
- Value text col = bar col + bar width + 1
- Pencil separator col = container col + `L` - 1

## Bar Styles

### Simple bars
Single segment per row using `▓`:
```
rectangle "" at <bar_col>,<row> size <width>x1 fill solid char "▓" border hidden
```

### Stacked bars
Two segments per row placed adjacently to show composition:
- `▓` (dark) = primary/fixed portion
- `▒` (light) = secondary/variable portion
- Place `▓` first (left), then `▒` immediately after: `▓▓▓▓▒▒▒▒▒▒`
- Segment 2 starts at col = bar col + segment 1 width
- Combined width of both segments = total bar length

```
rectangle "" at <bar_col>,<row> size <seg1_width>x1 fill solid char "▓" border hidden
rectangle "" at <bar_col + seg1_width>,<row> size <seg2_width>x1 fill solid char "▒" border hidden
```

## Examples

### Simple bar chart (3 rows)
```
layer "Chart" visible
  group "Bar Chart"
    rectangle "Revenue by Region" at 0,0 size 22x3 style single fill transparent
    rectangle "" at 0,2 size 67x5 style single fill transparent
    text "APAC" at 2,3
    rectangle "" at 10,3 size 50x1 fill solid char "▓" border hidden
    text "$1.00" at 61,3
    text "EMEA" at 2,4
    rectangle "" at 10,4 size 35x1 fill solid char "▓" border hidden
    text "$0.70" at 46,4
    text "AMER" at 2,5
    rectangle "" at 10,5 size 22x1 fill solid char "▓" border hidden
    text "$0.44" at 33,5
    pencil at 9,3 cells [0,0,"│";0,1,"│";0,2,"│"]
```

### Stacked bar chart (2 rows)
```
layer "Chart" visible
  group "Bar Chart"
    rectangle "50% margin reduction" at 0,0 size 24x3 style single fill transparent
    rectangle "" at 0,2 size 67x4 style single fill transparent
    text "before" at 2,3
    rectangle "" at 10,3 size 14x1 fill solid char "▓" border hidden
    rectangle "" at 24,3 size 36x1 fill solid char "▒" border hidden
    text "$1.00" at 61,3
    text "after" at 2,4
    rectangle "" at 10,4 size 14x1 fill solid char "▓" border hidden
    rectangle "" at 24,4 size 13x1 fill solid char "▒" border hidden
    text "$0.63" at 38,4
    pencil at 9,3 cells [0,0,"│";0,1,"│"]
```

### Multi-section chart with legend and frame

For complex charts, use groups to organize sections and a double-bordered outer frame:

```
layer "Layer 1" visible
  group "Chart 1"
    rectangle "50% hardware savings" at 11,7 size 24x3 style single fill transparent
    rectangle "" at 11,9 size 69x4 style single fill transparent
    rectangle "" at 21,10 size 14x1 fill solid char "▓" border hidden
    rectangle "" at 35,10 size 36x1 fill solid char "▒" border hidden
    rectangle "" at 21,11 size 7x1 fill solid char "▓" border hidden
    rectangle "" at 28,11 size 36x1 fill solid char "▒" border hidden
    text "before" at 13,10
    text "after" at 13,11
    text "$1.00" at 72,10
    text "$0.88" at 65,11
    pencil at 20,10 cells [0,0,"│";0,1,"│"]
  group "Chart 2"
    rectangle "50% ops savings" at 11,14 size 24x3 style single fill transparent
    rectangle "" at 11,16 size 69x4 style single fill transparent
    rectangle "" at 21,17 size 14x1 fill solid char "▓" border hidden
    rectangle "" at 35,17 size 36x1 fill solid char "▒" border hidden
    rectangle "" at 21,18 size 14x1 fill solid char "▓" border hidden
    rectangle "" at 35,18 size 13x1 fill solid char "▒" border hidden
    text "before" at 13,17
    text "after" at 13,18
    text "$1.00" at 72,17
    text "$0.62" at 49,18
    pencil at 20,17 cells [0,0,"│";0,1,"│"]
  group "Legend"
    rectangle "" at 55,4 size 26x4 style single fill transparent
    rectangle "" at 56,5 size 7x1 fill solid char "▓" border hidden
    rectangle "" at 56,6 size 7x1 fill solid char "▒" border hidden
    text "hardware cost" at 64,5
    text "ops cost" at 64,6
  rectangle "comparing hardware & ops costs" at 8,3 size 77x18 style double fill transparent shadow light x 1 y 1 textOnBorder true halign left valign top padding 1,0,0,0
```

## Key Details

- Title bottom border and container top border overlap (same row) for a connected look
- Bars use `fill solid char "▓"` (or `"▒"`) and `border hidden` — height is always 1
- The pencil separator draws `│` at each data row to divide labels from bars
- Value text is placed 1 char after the last bar segment
- Add more rows by increasing container height and adding more bar/text/pencil entries
- Right-pad shorter labels with spaces so the separator column stays aligned
- Use groups to organize multi-section charts
- Use a double-bordered outer frame with `textOnBorder true` for a polished look
- Add a legend group when using multiple bar styles (▓ and ▒)
