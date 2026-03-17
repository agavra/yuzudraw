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

### Arrow label gap sizing

Arrow labels need room to render. When an arrow between two rects has a label, the `gap` must be large enough for the label text plus padding on each side. Use this formula:

```
gap = max(label_length + 6, 8)
```

- `label_length` is the character count of the label text.
- `+6` accounts for stubs, arrowhead, and 2 chars of visual padding on each side.
- Minimum gap of `8` even for short or no labels — this keeps arrows readable.
- For unlabeled arrows, the default gap (4) is fine.

When two rects share arrows in **both** directions (e.g. retry loops), route one arrow via `.bottom` or `.top` sides so labels don't compete for the same horizontal segment.

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
rect "Check?" id check right-of req gap 8
rect "Process" id process right-of check gap 9
rect "Reject" id reject below check
arrow from req to check
arrow from check to process label "yes"
arrow from check to reject label "no"
```

### Retry loop
```dsl
rect "Validate" id validate at 2,1
rect "Retry" id retry right-of validate gap 12
rect "Process" id process right-of retry gap 10
rect "Done" id done right-of process gap 8
arrow from validate to retry label "fail"
arrow from retry.bottom to validate.bottom label "fix"
arrow from retry to process label "ok"
arrow from process to done
```

## Don’ts

- Do not make the diagram symmetrical at the expense of order.
- Do not overload a flow diagram with unrelated structural detail.
