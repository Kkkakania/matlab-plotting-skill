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
