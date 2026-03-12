# Bar Charts

Use this reference for metric comparison diagrams.

## When To Use It

Use bar charts when the request is primarily about:
- comparing values across categories
- showing ranked values
- showing before or after deltas
- showing stacked composition within totals

## Structure

Bar charts use borderless filled rectangles inside a bordered container:
- title box overlapping the container top border
- container framing all rows
- per row: label text, one or more filled bar segments, value text
- optional separator `│` between the label column and the bar column

Keep all rows aligned to a shared label column, bar start column, and value column.

## Layout Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `L` | Label area width | 10 |
| `B` | Max bar width | 50 |
| `V` | Value area width | 7 |

Derived values:
- container width = `L + B + V + 1`
- bar col = container col + `L`
- bar width = `round(value / max_value * B)`
- value text col = bar col + B + 1
- separator col = container col + `L` - 1

Notes:
- Use a fixed value column for every row. Do not anchor value labels to each bar's right edge unless you explicitly want ragged values.
- The extra `+ 1` in container width prevents the longest value from touching or breaking the right border.
- Leave at least 1 column between the longest value text and the right border.
- Right-pad shorter labels if you use a separator.

## Bar Styles

### Simple bars
```dsl
rect "" id bar1 at <bar_col>,<row> size <width>x1 fill solid char "▓" noborder
```

### Stacked bars
```dsl
rect "" id seg1 at <bar_col>,<row> size <seg1_width>x1 fill solid char "▓" noborder
rect "" id seg2 at <bar_col + seg1_width>,<row> size <seg2_width>x1 fill solid char "▒" noborder
```

## Example

```dsl
rect "Latency by tier" at 0,0 size 19x3
rect "" id container at 0,2 size 48x5
text "hot" at 2,3
rect "" id hot at 10,3 size 8x1 fill solid char "▓" noborder
text "8ms" at 42,3
text "warm" at 2,4
rect "" id warm at 10,4 size 20x1 fill solid char "▓" noborder
text "32ms" at 41,4
text "cold" at 2,5
rect "" id cold at 10,5 size 32x1 fill solid char "▓" noborder
text "120ms" at 40,5
```

If the fixed value column makes short rows look too sparse, reduce `B`.

## Don’ts

- Do not use this family when topology or workflow order is the main point.
- Keep the bar grammar consistent across charts so comparisons feel related.
- Do not let the longest value label determine layout by accident. Reserve space for it explicitly.
