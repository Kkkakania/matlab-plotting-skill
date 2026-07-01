# First Render Walkthrough

This walkthrough is the shortest path from a data file to a rendered MATLAB
figure. It is written for first-time users who want one safe command sequence
before reading the full scheme catalog.

## 1. Try Metadata First

Use these commands before configuring MATLAB:

```bash
./scripts/doctor.sh --out /tmp/matlab-plotting-skill-doctor
./scripts/render_with_matlab.sh --list-schemes
./scripts/render_with_matlab.sh --list-schemes --status
./scripts/render_with_matlab.sh --scheme-info line_trend
./scripts/render_with_matlab.sh --scheme-info line_trend --status
./scripts/render_with_matlab.sh --scheme-info-json line_trend
```

They do not render figures. They confirm that the repository, scheme catalog,
and shell wrapper are available before you troubleshoot MATLAB itself.
The doctor writes `first_use_doctor.md/json`, which is useful when a fresh clone
fails before rendering.

## 2. Check MATLAB

Set `MATLAB_BIN` when MATLAB is not already on `PATH`:

```bash
export MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab
./scripts/render_with_matlab.sh --check
```

On Windows Git Bash, the executable path usually needs the `.exe` suffix and
quotes around `Program Files`:

```bash
MATLAB_BIN="/c/Program Files/MATLAB/R2024b/bin/matlab.exe" \
  ./scripts/render_with_matlab.sh --check
```

If this fails, fix MATLAB first. Metadata-only commands such as
`--list-schemes`, `--scheme-info`, and `--scheme-info-json` can still run
without MATLAB.

MATLAB-backed commands have a 600-second timeout guard. `--smoke-test`
auto-scales the guard from the catalog size and prints the applied budget before
MATLAB starts. Use `MP_MATLAB_TIMEOUT_SECONDS=0` only when you deliberately
want to let a long local render run without that guard.

## 3. Inspect The Data

Use `--inspect-data` before choosing a chart when the file is new to you:

```bash
./scripts/render_with_matlab.sh --inspect-data --data examples/data/time_series.csv
```

In the JSON output, check `RoleHint` and `NextCommandHint` first. They are the
quick human-facing bridge from schema inspection to planning: for example, a
single time-series CSV should report `looks like a single time series` and
suggest a `--plan-only` command. The command hint uses the file name or a
placeholder, not an absolute local path.

For MAT files with several plausible variables, add `--var <name>` after
inspecting the available variables. Do not guess when the variable choice is
ambiguous.

## 4. Preview The Choice

Use `--plan-only` to see the selected scheme, alternatives, and score snapshot
without writing figure files:

```bash
./scripts/render_with_matlab.sh \
  --plan-only \
  --data examples/data/time_series.csv \
  --goal "show a time trend"
```

If the selected scheme is not what you want, either adjust the goal text or use
an explicit scheme:

```bash
./scripts/render_with_matlab.sh --scheme-info line_trend
```

Use `--scheme` to bypass planning when you already know which renderer should
handle the data:

```bash
./scripts/render_with_matlab.sh \
  --data examples/data/time_series.csv \
  --scheme line_trend \
  --out figures/first-render
```

For a terminal-friendly explanation of the selector's reasoning, use:

```bash
./scripts/render_with_matlab.sh \
  --explain \
  --data examples/data/time_series.csv \
  --goal "show a time trend"
```

## 5. Render PNG And SVG

Render only after the data and scheme make sense:

```bash
./scripts/render_with_matlab.sh \
  --data examples/data/time_series.csv \
  --goal "show a time trend" \
  --out figures/first-render \
  --formats png,svg
```

Use `--formats png,svg,pdf` when you need both raster and paper-ready vector
exports. The CLI rejects unknown format names before MATLAB starts.

The output directory should contain figure files plus:

- `render_report.md`
- `render_report.json`

Use the Markdown report for human review and the JSON report for follow-up
automation.

## 6. Review Before Sharing

Before using a figure in a paper, report, or repository:

1. Check the selected scheme and alternatives in `render_report.md`.
2. Confirm axis labels, legend labels, units, and title are meaningful.
3. Confirm no private file paths, emails, raw screenshots, or personal data were
   copied into the output directory.
4. If the figure will be committed, run:

```bash
./scripts/check_gallery_outputs.sh --dir figures/first-render --format png
./scripts/check_privacy.sh
./scripts/check_forbidden_files.sh
```

## 7. Share First-Use Feedback

If this walkthrough fails on a fresh clone, open the first-use feedback form:

https://github.com/Kkkakania/matlab-plotting-skill/issues/new?template=first_use_feedback.yml

Useful reports include the MATLAB version, operating system, command sequence,
selected scheme, `render_report.md` summary, and a short description of what was
expected. Redact private paths, research data, emails, and local account names
before posting.
See `docs/private-data-handling.md` for the exact sharing boundary.

After rendering, you can generate a redacted Markdown draft from the output
directory:

```bash
./scripts/collect_first_use_feedback.sh \
  --out figures/first-render \
  --doctor /tmp/matlab-plotting-skill-doctor \
  --command './scripts/render_with_matlab.sh --data <redacted> --goal "show a time trend" --out figures/first-render --formats png,svg' \
  --matlab R2025a \
  --os macOS \
  --commit "$(git rev-parse --short HEAD)" \
  --goal "show a time trend" \
  --data-shape "24 rows, 1 time column, 1 value column"
```

Review the draft before posting it. The helper redacts common local absolute
paths and emails, but you are still responsible for removing private research
data, lab names, account names, and anything that should not be public.
Use `--data-shape` for a short structural summary from `--inspect-data`; do not
paste raw rows from a private dataset.

Copy this template when reporting a first-use result:

```text
OS:
MATLAB:
Commit:
Command sequence:
first_use_doctor.md/json summary:
Data shape:
Goal text:
Selected scheme:
Top alternatives:
Output formats:
render_report.md summary:
Expected result:
Actual result:
Private details redacted: yes/no
```

## Common First Choices

| Goal | First Scheme To Try |
|---|---|
| Show one ordered measurement over time | `line_trend` |
| Compare several ordered series | `multi_line_comparison` |
| Show uncertainty around a center line | `confidence_band` |
| Inspect a local event in a long trend | `zoomed_inset_line` |
| Show two numeric variables | `scatter_relationship` |
| Show grouped x-y observations | `grouped_scatter` |
| Show many overlapping x-y points | `density_scatter` |
| Compare category scores | `grouped_bar` |
| Show a numeric matrix | `heatmap_matrix` |

For broader choices, use `docs/chart-selection-guide.md`.
