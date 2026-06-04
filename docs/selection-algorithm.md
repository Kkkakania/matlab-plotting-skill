# Selection Algorithm

This document describes how `matlab-plotting-skill` chooses a plotting scheme.
It is meant to make the selector auditable, not to present the score as a
statistical model.

## Inputs

The selector uses two inputs:

- Data schema inferred from CSV, Excel, or MAT input.
- User goal text, such as `show a time trend` or `compare methods`.

The schema currently tracks:

- table, matrix, vector, or scalar-like shape
- row and column counts
- numeric, categorical, and time-like column counts
- matrix-like structure
- positive/negative values
- percent-like values

## Rule Families

The selector applies deterministic rule boosts. A scheme with the strongest
combined score becomes the selected scheme, and the next few schemes become
alternatives.

| Signal | Typical Effect |
|---|---|
| time-like column | trend schemes become stronger |
| time-like column plus several numeric columns | `multi_line_comparison` becomes stronger |
| uncertainty, confidence, interval, or bounds in the goal | `confidence_band` becomes stronger |
| matrix-like data | matrix and heatmap schemes become stronger |
| category plus numeric data | bar, ranking, and distribution schemes become candidates |
| two or more numeric columns without categories | relationship schemes become stronger |
| dense numeric samples | `density_scatter` and `contour_scatter` become stronger |
| regression, fit, slope, or trend line in the goal | `regression_scatter` becomes stronger |
| magnitude, size, bubble, or third numeric variable in the goal | `bubble_scatter` becomes stronger |
| positive and negative values | signed-area and diverging-bar schemes become stronger |
| percent, share, composition, or part-to-whole language | composition schemes become stronger |
| local event, anomaly, window, or zoom language | `zoomed_inset_line` becomes stronger |
| phase, regime, stage, period, or transition language | `segmented_line` becomes stronger |

Exact weights live in `skills/matlab-plotting-skill/assets/matlab/mpSelectScheme.m`.
The public contract is the direction of the rules, not a permanent numeric
score for every scheme.

## Inspecting A Choice

Use `--plan-only` when an agent needs machine-readable output:

```bash
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab ./scripts/render_with_matlab.sh \
  --plan-only \
  --data examples/data/time_series.csv \
  --goal "show a time trend"
```

The JSON includes:

- `SelectedScheme`
- `Alternatives`
- `Schema`
- `Explanation`
- `ScoreSnapshot`

Use `--explain` when a person wants a terminal summary:

```bash
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab ./scripts/render_with_matlab.sh \
  --explain \
  --data examples/data/time_series.csv \
  --goal "show a time trend"
```

Rendered reports also include a `Selection Explanation` section and a
machine-readable `selectionExplanation` field in `render_report.json`.

## Limits

The score is a deterministic routing hint. It is not a claim that the selected
plot is scientifically optimal, publication-ready, or better than the
alternatives for every audience.

When the result matters, review the selected scheme, alternatives, output image,
and figure-quality checklist before sharing the figure.
