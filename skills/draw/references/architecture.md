# Architecture Diagrams

Use this reference for system-topology diagrams with strong spatial grouping.

## Defaults

- Use `style double` or `style heavy` for region boundaries — the structural groupings that contain other things.
- Use `style single` for leaf nodes (services, servers, gateways) inside regions.
- Use `textOnBorder` for region labels — put the label as the rect's own text (e.g., `rect "US-East" ... textOnBorder`), not as a separate `text` element. This places the label on the border line.
- Use `shadow light` (or `shadow medium`) on major regions and the outermost boundary for depth.
- Use `fill solid char "▓"` or `"▒"` for data stores (databases, caches, queues) to visually distinguish them from services.
- Prefer top-to-bottom or left-to-right flow, not both equally.
- When a diagram has 3+ levels of nesting, step down border weight at each level: double → heavy → single.

## Visual Hierarchy Rule

Every diagram should have at least 2 visually distinct tiers. The reader should immediately see which boxes are **containers** (regions, zones, tiers) and which are **leaf nodes** (services, servers). Achieve this through border weight, fill, and shadow:

| Element type | Border | Fill | Shadow |
|---|---|---|---|
| Outermost boundary | `style double` | none | `shadow light` |
| Region / zone / tier | `style double` | none | optional |
| Leaf service node | `style single` | none | none |
| Data store (DB, cache, queue) | `style double` | `fill solid char "▒"` | none |
| Entrypoint (LB, gateway) | `style heavy` | none | none |

## Layout Heuristics

- Start with one dominant axis.
- Wrap major subsystems in framed regions such as zones, groups, lanes, or tiers.
- When showing many peers, use a repeated horizontal row or vertical stack with identical sizing.
- Keep more important layers visually stronger than surrounding nodes.
- Avoid diagonals. Use orthogonal connectors and explicit labels.
- Prefer asymmetry when it clarifies the system.
- For hierarchy-heavy diagrams, use nested boxes rather than one generic rectangle.

If labels or connectors start colliding, simplify before adding more structure.

## Patterns

### Region with label on border
```dsl
rect "US-East" id useast at 2,1 size 44x18 style double textOnBorder shadow light
rect "CDN Edge" id cdn at 6,4
rect "API Gateway" id gw below cdn gap 2 style heavy
rect "App Server 1" id app1 below gw gap 2
rect "App Server 2" id app2 right-of app1 gap 4
arrow from cdn to gw
arrow from gw to app1
arrow from gw to app2
```

### Side-by-side regions with shared data store
```dsl
rect "Region A" id regionA at 2,1 size 40x16 style double textOnBorder shadow light
rect "Region B" id regionB at 48,1 size 40x16 style double textOnBorder shadow light

rect "Service 1" id s1 at 8,4
rect "Service 2" id s2 at 54,4

rect "Global DB" id db at 30,20 size 30x5 style double fill solid char "▒"

arrow from s1.bottom to db.top
arrow from s2.bottom to db.top
arrow from regionA.right to regionB.left label "replication"
```

### Fan-out from entrypoint
```dsl
rect "Load Balancer" id lb at 30,1 style heavy

rect "Server Tier" id tier at 4,6 size 80x8 style double textOnBorder
rect "Server 1" id srv1 at 10,8
rect "Server 2" id srv2 right-of srv1 gap 6
rect "Server 3" id srv3 right-of srv2 gap 6

arrow from lb.bottom to srv1.top
arrow from lb.bottom to srv2.top
arrow from lb.bottom to srv3.top

rect "Database" id db at 30,17 size 26x5 style double fill solid char "▒"

arrow from srv1.bottom to db.top
arrow from srv2.bottom to db.top
arrow from srv3.bottom to db.top
```

### Nested data stores (WAL + index pattern)
```dsl
rect "Storage" id storage at 2,1 size 56x16 style double textOnBorder shadow light

rect "WAL" id wal at 6,4 size 44x4 style heavy
rect "" id waldata at 8,5 size 30x2 fill solid char "■" noborder
rect "" id walpending at 38,5 size 8x2 fill solid char "◈" noborder

rect "Index" id idx at 6,10 size 44x4 style heavy
rect "" id idxdata at 8,11 size 24x2 fill solid char "■" noborder

text "committed" at 8,3
text "pending" at 38,3
```

## Don'ts

- Do not default to rounded UI-style boxes everywhere.
- Do not use `pencil` for things that can be expressed with regions, bars, and box patterns.
- Do not mix more than 3 border styles in one diagram.
- Do not treat every box equally. Boundaries, nodes, and data stores should each read differently.
- Do not force dense patterns onto lighter diagrams.
- Do not use `style single` for region boundaries — regions should always be heavier than their contents.
