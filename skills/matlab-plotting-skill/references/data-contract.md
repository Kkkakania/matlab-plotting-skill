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

