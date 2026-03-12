---
name: draw
description: Create YuzuDraw diagrams by choosing the right family and following a short reference for architecture, components, flow, bar charts, or ASCII art
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
6. Pass DSL to CLI commands using a heredoc with `--dsl-stdin` (see CLI Invocation Rules below).
7. Always display the rendered ASCII output in a fenced code block in your response so the user can see it directly without expanding tool results.
8. After rendering, ask the user if they'd like to save the diagram (via `create-diagram` or `update-diagram`). Always prompt — don't assume they only wanted a preview.

## CLI Invocation Rules

Every CLI call MUST start with `yuzudraw-cli` so it can be allowlisted. Pass DSL inline via heredoc — no temp files, no pipes, no `cat`/`echo`.

- **Render:**
  ```
  yuzudraw-cli render-ascii --dsl-stdin <<'EOF'
  rect "hello" id box at 5,5 size 10x3
  EOF
  ```
- **Create:**
  ```
  yuzudraw-cli create-diagram --name <name> --dsl-stdin <<'EOF'
  ...DSL...
  EOF
  ```
- **Update:**
  ```
  yuzudraw-cli update-diagram --name <name> --dsl-stdin <<'EOF'
  ...DSL...
  EOF
  ```

Do NOT use pipes (`cat file | yuzudraw-cli`), `--dsl-file`, or any command that does not start with `yuzudraw-cli`.

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

Open [ascii-art.md](/Users/agavra/dev/yuzudraw/skills/draw/references/ascii-art.md) when the request is about:
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
- ascii-art if illustration is the deliverable

## Shared Rules

- Prefer a clear house style for the selected family over generic box-and-arrow output.
- Leave a small buffer on the top and left by default. Start around `col 2-4` and `row 1-2` unless the prompt or composition needs a different origin.
- Use groups to organize related elements whenever a diagram has 2+ logical categories (e.g., services vs data stores, frontend vs backend, internal vs external). Framed regions with `style double` or `style heavy` make diagrams far more readable than flat layouts. When in doubt, group.
- Use shading semantically, not decoratively.
- Use `pencil` sparingly unless the selected reference calls for it.
- If the user asks for “a diagram like X”, match X's composition first, then map it into YuzuDraw DSL.
