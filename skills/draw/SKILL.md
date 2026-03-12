---
name: draw
description: Create YuzuDraw diagrams by choosing the right family and following a short reference for architecture, components, flow, bar charts, or ASCII drawing
user_invocable: true
---

# /draw — Create Diagrams in YuzuDraw

Use this as the single entrypoint for diagram work. Select one family, open the matching reference, then write DSL.

## Workflow

1. Check whether `yuzudraw-cli` is installed with `command -v yuzudraw-cli`.
2. If missing, ask the user to install it with `curl -fsSL https://www.yuzudraw.com/install.sh | sh`, then stop.
3. Classify the request into one primary diagram family.
4. Open the matching reference file under `references/`.
5. Follow that reference's defaults instead of improvising a generic style.
6. Write YuzuDraw DSL, render with `render-ascii` when useful, then create or update the diagram.

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

Open [ascii-drawing.md](/Users/agavra/dev/yuzudraw/skills/draw/references/ascii-drawing.md) when the request is about:
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
- ascii-drawing if illustration is the deliverable

## Shared Rules

- Prefer a clear house style for the selected family over generic box-and-arrow output.
- Use shading semantically, not decoratively.
- Use `pencil` sparingly unless the selected reference calls for it.
- If the user asks for “a diagram like X”, match X's composition first, then map it into YuzuDraw DSL.
