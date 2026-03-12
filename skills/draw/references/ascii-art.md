# ASCII Art

Use this reference for illustrations, icons, scenes, and decorative ASCII work.

## Style

Aim for **cute, readable characters** built from composed rects — not blocky filled silhouettes.

- Use `style rounded` rects (`╭╮╰╯`) as the primary building block for body parts, limbs, and features.
- Put facial expressions and messages inside rect text (e.g., `"●   ●\n  ω"`).
- Use cute symbols freely: `●`, `◉`, `♥`, `★`, `ω`, `^`, `♪`.
- Use `pencil` for details rects can't express: ears, tails, paws, whiskers, antennae bases.
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

## Tips

- Build characters by stacking/placing rects for each body part, then add pencil accents.
- Compose faces from text inside a single head rect rather than placing individual pencil characters.
- Use `style single` (`┌┐└┘`) for mechanical/rigid parts and `style rounded` for organic/soft parts.
- Overlap pencil elements with rect borders for ears, horns, or tails that break the silhouette.
