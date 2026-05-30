# Figure Quality Checklist

Use this after rendering a figure and before sharing it in a paper draft,
slide, report, or issue.

## First Pass

- The selected scheme matches the question the figure should answer.
- The title, axis labels, legends, and units are present when needed.
- The figure can still be understood without reading the source data file.
- The main comparison is visible within a few seconds.
- No label, tick mark, legend, or annotation overlaps important data.

## Data And Encoding

- The x-axis order is intentional, especially for time or ranked categories.
- Categories are not sorted alphabetically when a meaningful order exists.
- Error bars, bands, or intervals have a clear meaning.
- Percent or composition plots sum to the expected total.
- Missing values are either removed intentionally or visible in the plot.

## Color

- Sequential palettes are used for intensity or magnitude.
- Diverging palettes are used for positive and negative values.
- Categorical palettes are used for independent groups.
- The plot remains readable when printed in grayscale.
- Color is not the only cue for a critical distinction; line style, marker, or
  label helps when needed.
- Palette choice follows `docs/palette-accessibility-notes.md`.

## Typography And Layout

- Font size is large enough for the final medium.
- Line width and marker size match the output size.
- Long labels are rotated, wrapped, or moved to a horizontal layout.
- Multi-panel figures have consistent scales unless different scales are the
  point.
- Whitespace is used to separate information, not to decorate the figure.

## Export

- PNG is used for quick review.
- SVG or PDF is used when vector output matters.
- The exported figure has the intended dimensions.
- The render report lists the selected scheme and output files.
- `render_report.json` is present when another script or agent will read the
  result.

## MATLAB Checks

```bash
./scripts/render_with_matlab.sh --check
./scripts/render_with_matlab.sh --smoke-test --out figures/smoke --formats png
./scripts/check_gallery_outputs.sh --dir figures/smoke --format png
```

## Before Sharing

- The figure and report do not expose private local paths.
- The data shown is allowed to be shared.
- Synthetic examples are clearly synthetic.
- The image does not include watermarks, personal names, school names, or
  unrelated article screenshots.
- Any manual edits made after MATLAB export are noted in the issue, pull
  request, or paper draft.
