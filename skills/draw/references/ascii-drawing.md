# ASCII Drawing

Use this reference for illustrations, icons, scenes, and decorative ASCII work.

## Defaults

- Prefer boxes and shaded fills for silhouette and major masses.
- Use `pencil` only for contours or details that boxes cannot express cleanly.
- Prefer bold readable silhouettes over delicate line art.
- Leave negative space around the drawing when possible.

## Layout Heuristics

- Start with the outer silhouette before interior marks.
- Use darker fill for the primary form and lighter fill for secondary planes or shadow.
- Group repeated details into patterns instead of drawing each one uniquely.
- Remove details that do not survive at terminal scale.

## Example

```dsl
rect "" id head at 10,3 size 16x8 fill solid char "▒" noborder
rect "" id eye1 at 14,5 size 2x1 fill solid char "▓" noborder
rect "" id eye2 at 20,5 size 2x1 fill solid char "▓" noborder
rect "" id mouth at 15,8 size 6x1 fill solid char "▓" noborder
```

## Don’ts

- Do not begin with dense `pencil` noise.
- Do not use shading everywhere. Preserve contrast and whitespace.
