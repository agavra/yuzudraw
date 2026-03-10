# YuzuDraw TODO List

## Bugs

- [x] Small rectangles have should not have midpoint selectors
- [x] The edit menu is all sorts of weird
- [x] Attach points for destination aren't showing (they are snapping)
- [x] highlighted options in inspector panel show square corners on rounded pills
- [ ] dragging color takes up too many undo/redo slots
- [ ] deleting all emenets in a group doesn't delete the group
- [ ] cant' drag rectange to height 1
- [ ] show the cursor tool when selecting a tool (and highlight in toolbar)
- [ ] sometimes resize cursor shows when the action is drag, we should make sure this is impossible for any action, may require refactor
- [ ] use proper glyphs with overlapping boxes (make it optional)
- [ ] double clicking in selected group edits text? is thsi good behavior?
- [ ] copy paste in group should remain in group if group is still selected
- [ ] too easy to accidentally move when selecting, press delay should be more
- [ ] rename action should select existing text
- [ ] copy pasting shadow for box doesn't seem to work?
- [ ] selecting locked layer should allow you to select inner components for copy/paste but not edit
- [ ] click and drag across layers doesnt work
- [ ] can't delete layers
- [ ] should be able to select items in other layers to select the layerA
- [ ] hitbox should always be layers/objects higher up the stack

## Core Features

- [x] add the ability to move many items at once
- [x] add copy-cut-paste support (shorctus)
- [x] update keyboard shortcuts in general
- [ ] configurable attachment points
- [x] Shift+Click to edit properties of multiple items (use the same mechanism as group layer selection)
- [ ] Eraser functionality for when drawing with pencils
- [x] SVG export
- [ ] Add hand tool to move around canvas (as drop down)
- [ ] Export should compute bounding boxes so that it doesnt have too mcuh padding.
- [ ] Cmd+R to rename selected shape (needs focus management for inline rename)
- [ ] Shift+arrow keys to move shapes by 10 cells (larger step movement)
- [ ] option+click to copy and drag selection 
- [ ] shift+up/down to move more cells

## AI Integration Features

- [x] Build basic Claude integration with bi-direcitonal editing

## Advanced Features

- [ ] Add line tool for custom polygon shapes (as drop down on arrow)
- [ ] Alignment guides for multiple item alignment

## Super Features

- [ ] Add a comprehensive component library, possibly with a scaling mechanism for some of them (pre-defined scaling operations so I can decide the size before inserting in a special window)
- [ ] Auto-Layouts
