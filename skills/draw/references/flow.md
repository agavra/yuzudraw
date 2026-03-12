# Flow Diagrams

Use this reference for workflows, pipelines, lifecycles, and ordered request paths.

## Defaults

- Prefer one row or one column of major steps.
- Use short labels. Move detail to edge labels or side notes.
- Use arrows for every transition.

## Layout Heuristics

- Ordered steps should read in one pass.
- Branches should rejoin only when the merged path is conceptually meaningful.
- Keep retry loops compact and local.
- Avoid symmetry if it obscures order.

## Patterns

### Straight pipeline
```dsl
rect "Input" id input at 2,1
rect "Validate" id validate right-of input
rect "Transform" id transform right-of validate
rect "Store" id store right-of transform
arrow from input to validate
arrow from validate to transform
arrow from transform to store
```

### Decision branch
```dsl
rect "Request" id req at 2,1
rect "Check?" id check right-of req gap 5
rect "Process" id process right-of check gap 5
rect "Reject" id reject below check
arrow from req to check
arrow from check to process label "yes"
arrow from check to reject label "no"
```

## Don’ts

- Do not make the diagram symmetrical at the expense of order.
- Do not overload a flow diagram with unrelated structural detail.
