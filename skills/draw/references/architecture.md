# Architecture Diagrams

Use this reference for system-topology diagrams with strong spatial grouping.

## Defaults

- Use `style double` or `style heavy` for the outermost boundary.
- Use `style single` for inner regions unless the outer frame is already dense.
- Prefer rectangular regions with explicit labels over floating labels.
- Prefer repeated box patterns when multiplicity is important.
- Prefer `fill solid char "▓"` or `"▒"` for large internal blocks.
- Prefer top-to-bottom or left-to-right flow, not both equally.
- Prefer labels on borders or just above a frame when the interior is dense.

## Layout Heuristics

- Start with one dominant axis.
- Wrap major subsystems in framed regions such as zones, groups, lanes, or tiers.
- When showing many peers, use a repeated horizontal row or vertical stack with identical sizing.
- Keep more important layers visually stronger than surrounding nodes.
- Avoid diagonals. Use orthogonal connectors and explicit labels.
- Prefer asymmetry when it clarifies the system.
- For hierarchy-heavy diagrams, use nested boxes rather than one generic rectangle.
- Use `░` backing strips on the right and bottom edges of the biggest regions to give them weight.

If labels or connectors start colliding, simplify before adding more structure.

## Patterns

### Regions and repeated nodes
```dsl
rect "Region" id region at 2,1 size 88x20 style double
rect "Zone A" id a at 4,3 size 25x14
rect "Zone B" id b right-of a gap 4 size 25x14
rect "Zone C" id c right-of b gap 4 size 25x14
rect "Node A" at a.left+4,5
rect "Node B" at b.left+4,5
rect "Node C" at c.left+4,5
```

### Split regions
```dsl
rect "Region A" id leftRegion at 2,1 size 38x18 style double
rect "Region B" id rightRegion at 48,1 size 38x18 style double
rect "Node A" id n1 at 8,4 size 18x3
rect "Node B" id n2 below n1
rect "" id block1 at rightRegion.left+3,3 size 28x2 fill solid char "■" noborder
rect "" id block2 at rightRegion.left+5,8 size 24x2 fill solid char "█" noborder
text "Block 1" at rightRegion.left+4,2
text "Block 2" at rightRegion.left+4,7
arrow from n1.right to block1.left
arrow from n2.right to block2.left
```

## Don’ts

- Do not default to rounded UI-style boxes everywhere.
- Do not use `pencil` for things that can be expressed with regions, bars, and box patterns.
- Do not mix too many border styles in one diagram.
- Do not treat every box equally. Boundary, nodes, and internal layers should read differently.
- Do not force dense patterns onto lighter diagrams.
