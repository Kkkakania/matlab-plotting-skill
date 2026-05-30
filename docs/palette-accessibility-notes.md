# Palette And Accessibility Notes

The bundled palettes are meant to make common scientific figures readable, not
decorative. Choose the palette from the data relationship first.

## Categorical

Use categorical colors for independent groups, methods, classes, regions, or
conditions.

- Do not use a color gradient for unrelated groups.
- Keep the number of groups modest when possible.
- Add marker shape, line style, or direct labels when groups are easy to mix up.

## Sequential

Use sequential colors for ordered magnitude, intensity, density, or count.

- Low and high values should be visually ordered.
- Avoid using sequential color when values cross a meaningful zero point.
- Use a colorbar when exact magnitude interpretation matters.

## Diverging

Use diverging colors when zero, baseline, or neutral difference matters.

- Negative and positive sides should be visually balanced.
- The midpoint should represent zero, baseline, or no change.
- Do not use diverging color for ordinary category labels.

## Neutral

Use neutral styling when the figure should print cleanly or when color would
add more noise than meaning.

- Prefer neutral for draft review and black-and-white reports.
- Pair neutral colors with line style or marker changes.

## Grayscale And Colorblind Checks

- Check whether the main comparison still works in grayscale.
- Check likely colorblind cases when color is carrying a critical distinction.
- Do not rely on red/green contrast alone.
- Use line style, marker shape, annotation, or ordering for critical
  distinctions.
- Keep legends close to the data or use direct labeling when possible.
- When in doubt, render a neutral version and compare it with the color version.

## Practical Rule

If removing color changes the conclusion, the figure probably needs another cue.
