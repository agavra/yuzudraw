# ASCII Art

Use this reference for illustrations, icons, scenes, and decorative ASCII work.

## Style

Aim for **cute, readable characters** built from composed rects — not blocky filled silhouettes.

- Use `style rounded` rects (`╭╮╰╯`) as the primary building block for body parts, limbs, and features.
- Put facial expressions and messages inside rect text (e.g., `"●   ●\n  ω"`).
- Use cute symbols freely: `●`, `◉`, `♥`, `★`, `ω`, `^`, `♪`.
- Use `pencil` for details rects can't express: ears, tails, paws, whiskers, antennae bases.
  - Syntax: `pencil at col,row cells [relCol,relRow,"char";relCol,relRow,"char"]`
  - Cell offsets are relative to the `at` origin.
  - Place pencil elements **outside** rect boundaries — rects overwrite pencil cells they overlap.
- Use arrows with `headEnd dot` for antennae, pointers, or connectors between parts.
- Leave negative space around the drawing. Don't fill every cell.
- Keep it compact but not tiny — give features room to breathe.

## Example

```
         ●
         │
   ╭─────┴────╮
   │  ^   ^   │
   │    -     │
   ╰──────────╯
   ╭───────────╮
   │           │
╭──╮ │  ♥ BEEP   │ ╭──╮
│o=│ │  BOOP! ♥  │ │=o│
╰──╯ │           │ ╰──╯
   ╰─┬──┬─┬──┬─╯
     │| │ │| │
     └──┘ └──┘
```

```dsl
rect "^   ^\n  -" id head at 8,3 size 12x4 style rounded
arrow from head.top to 14,1 headEnd dot label ""
rect "♥ BEEP\nBOOP! ♥" id body at 8,7 size 13x6 style rounded
rect "o=" id larm at 3,9 size 4x3 style rounded
rect "=o" id rarm at 22,9 size 4x3 style rounded
rect "|" id lleg at 10,12 size 4x3 style single
rect "|" id rleg at 15,12 size 4x3 style single
```

### Pencil example — cat ears and whiskers

```dsl
pencil at 7,1 cells [0,0,"/";1,0,"\"]
pencil at 6,2 cells [0,0,"/";1,0," ";2,0,"\"]
pencil at 15,1 cells [0,0,"/";1,0,"\"]
pencil at 14,2 cells [0,0,"/";1,0," ";2,0,"\"]
rect "●     ●\n   ω" id head at 5,3 size 14x4 style rounded
pencil at 2,5 cells [0,0,"=";1,0,"=";2,0,"="]
pencil at 19,5 cells [0,0,"=";1,0,"=";2,0,"="]
```

Pencil cells are placed **before** rects in render order — rects paint over any overlapping pencil.

## Tips

- Build characters by stacking/placing rects for each body part, then add pencil accents.
- Compose faces from text inside a single head rect rather than placing individual pencil characters.
- Use `style single` (`┌┐└┘`) for mechanical/rigid parts and `style rounded` for organic/soft parts.
- Place pencil elements outside rect boundaries for ears, horns, or tails that break the silhouette. Rects overwrite overlapping pencil cells.
