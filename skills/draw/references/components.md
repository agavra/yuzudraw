# Component Diagrams

Use this reference for modules, services, interfaces, and internal product structure.

## Defaults

- Use `style double` for the main enclosing boundary when a container is helpful.
- Use `style single` for internal modules and repeated component tiles.
- Use borderless filled rectangles for dense internals or repeated structure.
- Prefer compact labels placed outside or above dense structures when interior text would collide.
- Prefer repeated tiles when the important idea is multiplicity, partitioning, or composition.
- Use shading deliberately. Structure comes first.

## Layout Heuristics

- Arrange components so the dependency direction is obvious.
- Keep peers aligned in rows or columns with even spacing.
- Use one level of containment at a time unless nested structure is necessary.
- Distinguish outside elements from internal components by placement and border weight.
- Default to unlabeled arrows unless the label adds information the reader would otherwise miss.
- For dense internals, move labels outside the box or into captions rather than writing through the component.
- When showing many homogeneous internals, use repeated tiles instead of fully labeled boxes.

Many component diagrams should stay simple: a few named components inside one or two containers with restrained connectors.

## Patterns

### Components inside a framed subsystem
```dsl
rect "App" id app at 0,0 size 64x16 style double
rect "Frontend" id fe at 3,3 style rounded
rect "API" id api right-of fe gap 10
rect "Worker" id worker below api gap 3
rect "Project File" id file below fe gap 3 style double
arrow from fe to api
arrow from api.left to file.right
arrow from api.bottom to worker.top
```

### Public API vs internals
```dsl
rect "Public API" id public at 0,0
rect "Core Engine" id core below public
rect "Plugin Host" id plugins right-of core gap 6
arrow from public to core
arrow from plugins to core
```

### Dense tiled internals
```dsl
text "Source" at 31,0
rect "" id input at 33,1 size 7x3 fill solid char "█"
text "entry path" at 0,4
rect "" id frame at 0,7 size 54x6 style double
rect "" id c1 at 2,8 size 7x3 fill solid char "█"
rect "" id c2 right-of c1 gap 2 size 7x3 fill solid char "█"
rect "" id c3 right-of c2 gap 2 size 7x3 fill solid char "█"
rect "" id c4 right-of c3 gap 2 size 7x3 fill solid char "█"
text "001" at 3,11
text "002" at 12,11
text "003" at 21,11
text "004" at 30,11
arrow from input.bottom to frame.top
rect "" id shade at frame.right,8 size 2x6 fill solid char "░" noborder
rect "" id base at 1,13 size 55x1 fill solid char "░" noborder
```

## Don’ts

- Do not turn a component diagram into a deployment map.
- Do not write labels through dense internals.
- Do not show every implementation detail. Prefer the smallest useful set of components.
- Do not flatten everything into rounded boxes when repeated tiles or structural mass would read better.
- Do not force repeated tiles onto simple dependency diagrams.
