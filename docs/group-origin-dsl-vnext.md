# Scoped Group Origins: DSL and CLI vNext

This document proposes a backward-compatible DSL and CLI extension for managing diagrams as reusable, appendable groups.

## Problem

The current DSL treats `group` as structural indentation only:

- groups have no coordinate system
- shapes inside groups still use document-global coordinates
- `update-diagram` replaces the whole document

That makes large diagrams awkward to grow incrementally. Adding a new subsystem usually means:

- picking unused absolute coordinates by hand
- rewriting existing positions
- losing the ability to treat a subsystem as a reusable snippet

## Goals

- make each group a portable snippet with its own local origin
- keep existing absolute DSL valid
- make it easy to append one or more groups into an existing diagram
- keep the CLI simple enough for agents to use reliably

## Proposed DSL

### Group Header

Add optional `id` and `at` clauses to `group`:

```dsl
group "Payments" id payments at 72,2
  rect "API" id api at 0,0
  rect "DB" id db below api gap 2
```

Proposed grammar shape:

```dsl
group "Name" [id GROUP_ID] [at POSITION]
```

Semantics:

- `group` remains non-rendering
- `at` defines the origin for that group's local coordinate system
- omitted `at` means the group origin is `0,0` relative to the containing scope
- omitted `id` keeps the group anonymous, as today

### Coordinate Resolution

Inside a group, bare coordinates become local to that group origin:

```dsl
group "Payments" id payments at 72,2
  rect "API" id api at 0,0
  text "primary" at 2,5
```

This should lower to absolute document coordinates:

- `api` at `72,2`
- `text` at `74,7`

### Nested Groups

Nested groups are relative to their parent group origin:

```dsl
group "Platform" id platform at 2,1
  group "Payments" id payments at 4,3
    rect "API" id api at 0,0
```

Result:

- `platform` origin = `2,1`
- `payments` origin = `6,4`
- `api` origin = `6,4`

### Reference Rules

Reference lookup should become lexical:

1. current group scope
2. nearest parent group scopes outward
3. document root scope

This keeps local snippets self-contained while still allowing cross-group references when needed.

### Group IDs as Scope Anchors

Group IDs should be referenceable as origin points:

```dsl
group "Payments" id payments at 72,2
  rect "API" id api at 0,0

group "Search" id search at payments+34,0
  rect "Indexer" id indexer at 0,0
```

Important constraint for vNext:

- group references resolve to the group's origin only
- group references do not support `.right` or `.bottom` yet

This keeps the model simple and avoids depending on group bounding-box inference for layout.

### Root Escape Hatch

Add a reserved `root` reference for document-global placement:

```dsl
group "Payments" id payments at 72,2
  text "global note" at root+2,1
```

This gives scoped groups an explicit escape hatch without forcing authors back to absolute-only documents.

### Relative Semantics

Inside a group, semantic placement stays local by default:

```dsl
group "Payments" id payments at 72,2
  rect "API" id api at 0,0
  rect "Worker" id worker right-of api gap 6
```

This matches how authors already think about local composition.

## Serializer Rules

`get-diagram` should emit scoped DSL when group origins are present:

- serialize `group ... id ... at ...` for positioned groups
- serialize child coordinates relative to the nearest positioned group
- prefer local references over flattened absolute coordinates
- preserve existing absolute serialization for documents with no group origins

If the serializer flattens everything back to absolute coordinates, the new authoring model collapses after the first round-trip.

## CLI Design

Keep the current commands:

- `create-diagram`
- `update-diagram`
- `get-diagram`
- `list-diagrams`
- `render-ascii`

Add one new composition command:

```text
yuzudraw-cli merge-diagram --name <name> --dsl-stdin [--into-group <group-id>] [--at <col,row>]
```

### `merge-diagram` semantics

- loads the existing document
- parses incoming DSL as a snippet
- appends incoming root statements into the document
- if `--into-group` is set, nests incoming root groups under that existing group
- if `--at` is set, offsets the incoming root scope before merge

This keeps the mental model clear:

- `update-diagram` = replace document
- `merge-diagram` = append snippet

### Recommended Agent Workflow

Reusable subsystem snippet:

```dsl
group "Payments" id payments at 0,0
  rect "API" id api at 0,0
  rect "DB" id db below api gap 2
```

Append it to a document:

```sh
yuzudraw-cli merge-diagram --name system --at 72,2 --dsl-stdin <<'EOF'
group "Payments" id payments at 0,0
  rect "API" id api at 0,0
  rect "DB" id db below api gap 2
EOF
```

The CLI-level offset makes snippets reusable across many documents without rewriting the DSL payload.

## Why This Design

This proposal deliberately avoids turning groups into fully rendered spatial containers.

Reasons:

- visible boundaries are already modeled well by `rect`
- the user need is scoped positioning and composition, not a second container rendering system
- origin-only group references are much simpler than full group edge references
- agent-authored snippets become predictable and reusable

## Backward Compatibility

- existing DSL remains valid
- existing groups without `id` or `at` keep current behavior
- existing CLI workflows remain valid
- only documents that opt into scoped groups need the new serializer behavior

## Recommended Implementation Order

1. Extend `ShapeGroup` with optional `origin` and `identifier` metadata needed for round-trip serialization.
2. Extend the DSL grammar, AST, and semantic analyzer for `group ... id ... at ...`.
3. Update serialization so positioned groups round-trip as scoped DSL.
4. Add `merge-diagram`.
5. Update the `draw` skill to prefer scoped groups for multi-subsystem diagrams once the parser ships.
