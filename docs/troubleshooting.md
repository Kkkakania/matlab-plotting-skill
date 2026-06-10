# Troubleshooting

Use this page when the first render does not work. Start with the smallest
command that matches the symptom. Most failures are easier to understand before
private data is involved.

## Start With The Checkout

Run the metadata-only doctor first:

```bash
./scripts/doctor.sh --out /tmp/matlab-plotting-skill-doctor
```

Open `/tmp/matlab-plotting-skill-doctor/first_use_doctor.md`. It checks the
repository layout, key docs, shell scripts, catalog metadata, and privacy scan
without starting MATLAB.

## MATLAB is not found

Check whether the wrapper can find MATLAB:

```bash
./scripts/render_with_matlab.sh --check
```

If MATLAB is installed but not on `PATH`, set `MATLAB_BIN`:

```bash
export MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab
./scripts/render_with_matlab.sh --check
```

On macOS, adjust the version in the path. On Linux or Windows-backed shells,
use the MATLAB executable path for that machine.

## The command hangs

Separate shell-wrapper problems from MATLAB startup time:

```bash
./scripts/render_with_matlab.sh --list-schemes --status
MATLAB_BIN=/path/to/matlab ./scripts/render_with_matlab.sh --check
```

MATLAB-backed commands use a timeout guard. For a deliberate long local render,
set:

```bash
export MP_MATLAB_TIMEOUT_SECONDS=0
```

If this is the first time MATLAB has opened after install or update, try
`--check` once before rendering data.

## No figure files were written

Check the output directory and formats first:

```bash
./scripts/render_with_matlab.sh \
  --data examples/data/time_series.csv \
  --goal "show a time trend" \
  --out /tmp/matlab-plotting-skill-first-render \
  --formats png,svg
```

Then look for:

- `/tmp/matlab-plotting-skill-first-render/render_report.md`
- `/tmp/matlab-plotting-skill-first-render/render_report.json`
- at least one `.png`, `.svg`, or `.pdf` file matching the requested formats

Unknown format names fail before MATLAB starts. Valid names are `png`, `svg`,
and `pdf`.

## The selected scheme feels wrong

Inspect the data and the selection before rendering:

```bash
./scripts/render_with_matlab.sh --inspect-data --data examples/data/time_series.csv
./scripts/render_with_matlab.sh --plan-only --data examples/data/time_series.csv --goal "show a time trend"
./scripts/render_with_matlab.sh --explain --data examples/data/time_series.csv --goal "show a time trend"
```

If you already know the scheme you want, make it explicit:

```bash
./scripts/render_with_matlab.sh \
  --data examples/data/method_scores.csv \
  --scheme grouped_bar \
  --out /tmp/matlab-plotting-skill-grouped-bar \
  --formats png,svg
```

If the automatic choice still looks wrong, include the schema summary,
selected scheme, alternatives, and goal text in the issue. Do not upload the
private dataset unless you have intentionally made a small public reproduction.

## MAT file has multiple variables

The skill should not guess when a MAT file contains several plausible arrays or
tables. Specify the variable:

```bash
./scripts/render_with_matlab.sh \
  --data data/results.mat \
  --var matrixData \
  --goal "matrix heatmap" \
  --out figures \
  --formats png
```

If you are not sure which variable to use, run `--inspect-data` first and share
only the redacted variable summary.

## Do not paste private data

For first-use feedback, generate a draft:

```bash
./scripts/collect_first_use_feedback.sh --out /path/to/render-output
```

Review it before posting. Remove private data values, full local paths, names,
emails, tokens, and unpublished project details. See
[`docs/private-data-handling.md`](private-data-handling.md) for the sharing
boundary.

Useful reports usually include:

- OS and MATLAB version
- commit hash
- command sequence
- selected scheme and alternatives
- output formats requested
- redacted error output or report summary
