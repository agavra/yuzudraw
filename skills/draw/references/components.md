# Component Diagrams

Use this reference for modules, services, interfaces, and internal product structure.

## Defaults

- Use `style double` for the main enclosing boundary.
- Use `style single` for service/module components.
- Use `fill solid char "▒"` or `fill solid char "█"` for data stores (databases, caches, queues, logs) to distinguish them from active services.
- Use `textOnBorder valign top` for container labels — put the label as the rect's own text (e.g., `rect "Platform" ... textOnBorder valign top`), not as a separate `text` element. When using `halign left` add `padding 2,0,0,0` and when using `halign right` add `padding 0,2,0,0` so the text sits inside the corner characters.
- Use `shadow light` on the outermost boundary for depth.
- Use borderless filled rectangles for dense internals or repeated structure.
- Default to unlabeled arrows unless the label adds information the reader would otherwise miss. When labels help (read, write, query), use them.

## Visual Distinction Rule

A component diagram should make it immediately obvious which elements are **containers**, which are **services**, and which are **data stores**:

| Element type | Border | Fill | Notes |
|---|---|---|---|
| Outer boundary | `style double` | none | Use `textOnBorder valign top` for label |
| Inner sub-boundary | `style double` or `style heavy` | none | For grouping related components |
| Service / module | `style single` | none | Active processing components |
| Data store (DB, cache, WAL, queue) | `style heavy` or `style double` | `fill solid char "▒"` | Passive storage |
| External system | `style rounded` | none | Outside the boundary |

## Layout Heuristics

- Arrange components so the dependency direction is obvious (top-to-bottom or left-to-right).
- Keep peers aligned in rows or columns with even spacing.
- Group related components in sub-boundaries when there are 2+ logical tiers (e.g., services vs data stores). This is important — when a diagram has both services and data stores, wrap the data stores in a "Data Layer" sub-boundary.
- For subsystem snippets that may be appended later, keep one top-level logical `group` around the whole subsystem so local coordinates can be introduced without restructuring the diagram.
- Distinguish outside elements from internal components by placement and border weight.
- For dense internals, move labels outside the box or into captions rather than writing through the component.
- When showing many homogeneous internals, use repeated tiles instead of fully labeled boxes.

Many component diagrams should stay simple: a few named components inside one or two containers with restrained connectors.

## Patterns

### Service pipeline with data stores
```dsl
rect "Platform" id platform at 2,1 size 76x24 style double textOnBorder valign top shadow light

rect "Ingestion" id ingest at 6,4
rect "Processor" id proc below ingest gap 3
rect "Query API" id query at 50,16

rect "Data Layer" id datalayer at 30,3 size 40x12 style double textOnBorder valign top
rect "WAL" id wal at 34,6 size 32x3 style heavy fill solid char "▒"
rect "Index" id idx at 34,10 size 32x3 style heavy fill solid char "▒"

arrow from ingest.right to wal.left label "write"
arrow from proc.right to idx.left label "write"
arrow from wal.left to proc.right label "read"
arrow from idx.right to query.left label "read"
```

### Components inside a framed subsystem
```dsl
rect "App" id app at 2,1 size 64x16 style double textOnBorder valign top shadow light
rect "Frontend" id fe at 5,4
rect "API" id api right-of fe gap 10
rect "Worker" id worker below api gap 3
rect "Config Store" id config below fe gap 3 fill solid char "▒"
arrow from fe to api
arrow from api.left to config.right
arrow from api.bottom to worker.top
```

### Proposed vNext appendable subsystem
```dsl
group "App" id app at 2,1
  rect "App" id app_frame at 0,0 size 64x16 style double textOnBorder valign top shadow light
  rect "Frontend" id fe at 3,3
  rect "API" id api right-of fe gap 10
  rect "Worker" id worker below api gap 3
  rect "Config Store" id config below fe gap 3 fill solid char "▒"
```

Use this once scoped group origins ship. The whole subsystem can then be merged into larger diagrams with one offset.

### Dense tiled internals
```dsl
text "Source" at 33,1
rect "" id input at 35,2 size 7x3 fill solid char "█"
text "entry path" at 2,5
rect "" id frame at 2,8 size 54x6 style double textOnBorder valign top
rect "" id c1 at 4,9 size 7x3 fill solid char "█"
rect "" id c2 right-of c1 gap 2 size 7x3 fill solid char "█"
rect "" id c3 right-of c2 gap 2 size 7x3 fill solid char "█"
rect "" id c4 right-of c3 gap 2 size 7x3 fill solid char "█"
text "001" at 5,12
text "002" at 14,12
text "003" at 23,12
text "004" at 32,12
arrow from input.bottom to frame.top
rect "" id shade at frame.right,8 size 2x6 fill solid char "░" noborder
rect "" id base at 3,14 size 55x1 fill solid char "░" noborder
```

### Public API with external consumers
```dsl
rect "External" id ext at 2,1 style rounded
rect "System" id sys at 2,6 size 60x14 style double textOnBorder valign top shadow light
rect "Public API" id api at 6,9 style heavy
rect "Core Engine" id core right-of api gap 8
rect "State Store" id store below core gap 3 fill solid char "▒"
arrow from ext.bottom to api.top
arrow from api to core
arrow from core.bottom to store.top
```

## Don'ts

- Do not turn a component diagram into a deployment map.
- Do not write labels through dense internals.
- Do not show every implementation detail. Prefer the smallest useful set of components.
- Do not flatten everything into rounded boxes when repeated tiles or structural mass would read better.
- Do not force repeated tiles onto simple dependency diagrams.
- Do not make data stores visually identical to services — use fill or heavier borders to distinguish them.
- Do not use a single flat container when the diagram has distinct logical layers (services, data, external) — use nested sub-boundaries.
