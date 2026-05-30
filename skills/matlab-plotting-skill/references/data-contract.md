# Data Contract

Supported inputs:

- CSV files readable by `readtable`.
- Excel files readable by `detectImportOptions` and `readtable`.
- MAT files containing a table, timetable, numeric matrix, numeric vector, or
  scalar struct with one of those values.

Rules:

- Prefer named table columns over unnamed matrices.
- Treat datetime, duration, or columns named `time`, `date`, `year`, `month`,
  `day`, `step`, or `sample` as ordered axes.
- Treat string, categorical, logical, or columns named `group`, `category`,
  `class`, `method`, or `label` as grouping variables.
- Treat numeric matrices with no category columns as matrix plots.
- If a MAT file has several plausible variables, stop and ask the user which
  variable to plot.
- If the user's goal names a scheme exactly, honor it unless the data shape is
  incompatible.

Outputs:

- Figure files in the requested formats.
- `render_report.md` with selected scheme, alternatives, data summary, palette,
  output files, and warnings.

## Scheme-Specific Contracts

### `multi_line_comparison`

Use a wide table or numeric matrix with one ordered x-axis column followed by at
least two numeric series columns. Good column shapes include `time, method_a,
method_b, method_c` or `sample, baseline, candidate`.

Avoid using a long table with only `time, group, value` for explicit
`multi_line_comparison` unless it has already been pivoted to one column per
series. For long grouped observations, first consider `grouped_scatter`,
`small_multiples`, or a preprocessing step that creates a wide table.

### `confidence_band`

Use an ordered x-axis column plus a central numeric series. If uncertainty
bounds are already available, use the column order `x, center, lower, upper` so
the renderer can treat the first value column as the center line and the next
two value columns as the intended band.

For quick previews without measured uncertainty, a single center series is
acceptable; the renderer will create a visual band from the center values so the
layout can still be inspected.

### `zoomed_inset_line`

Use a long ordered x-axis when the full trend matters but a local event,
transition, anomaly, or detail window needs closer inspection. A simple
two-column table such as `time, signal` is enough for one series.

For comparisons, use one x-axis column plus several numeric series columns, for
example `time, baseline, candidate`. Keep rows sorted by the ordered axis. If
the data has no meaningful local interval to inspect, start with `line_trend`
or `multi_line_comparison` instead.

### `positive_negative_area`

Use an ordered x-axis column plus one signed numeric series that contains both
positive and negative values. This is a good fit for residuals, deltas, net
change, or deviation from a baseline where zero is the reference line.

Avoid this scheme for always-positive totals, cumulative counts, or measurements
where crossing zero has no interpretation. Use `line_trend`, `grouped_bar`, or
`waterfall_contribution` instead when the question is about level, category
comparison, or stepwise contribution.

### `segmented_line`

Use an ordered x-axis column plus one or more numeric series when the same trend
passes through named phases, operating regimes, policy periods, or experiment
stages. If available, include a `segment`, `phase`, `regime`, `stage`, or
`period` column so the renderer or agent can mark boundaries explicitly.

If no segment column exists, this scheme should only be selected when the goal
text names the transition points or explains the phase structure. Otherwise use
`line_trend`, `multi_line_comparison`, or `zoomed_inset_line` so the chart does
not imply unsupported regime changes.
