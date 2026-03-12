# YuzuDraw TODO List

## Bugs

- [ ] opening and collapsing groups is slow
- [ ] the build release pipelien takes too long to run, taking up my actions minutes
- [ ] up/down when selecting in object pane should select other itemsA
- [ ] selecting a full group in object pane doesn't allow for deleting it with "delete" button
- [ ] diagrams tend to have arrows that are cut off in negative x axis. simple fix is to just always start with a bit of room from top/left sides
- [ ] use a CLI library instead of hardcoding it
- [ ] investigate suspected DSL/rendering alignment bug causing bar-chart separator and value-column misalignment

## Core Features

- [x] replace MCP with CLI
- [ ] Wrap text by default (and option to inspector)
- [ ] Support align / distribute vertical/horziontal multiple items
- [ ] Eraser functionality for when drawing with pencils
- [ ] configurable attachment points
- [ ] Export should compute bounding boxes so that it doesnt have too mcuh padding.
- [ ] Cmd+R to rename selected shape (needs focus management for inline rename)
- [ ] Shift+arrow keys to move shapes by 10 cells (larger step movement)
- [ ] option+click to copy and drag selection
- [ ] shift+up/down to move more cells
- [ ] add user settings to set defaults for certain inspector panel properties
- [ ] text box behavior is a bit clunky
- [ ] support zoom in/out
- [ ] support resize in both directions with option-resize
- [ ] more comprehensive integration tests

## Advanced Features

- [ ] Alignment guides for multiple item alignment
- [ ] Add a comprehensive component library, possibly with a scaling mechanism for some of them (pre-defined scaling operations so I can decide the size before inserting in a special window)
- [ ] Split up skill into library of diagram tools (e.g. bar-chart works really well)
