# First 5 Minutes

Use this path on a fresh clone before pointing the skill at private data.

## 1. Check The Catalog Without MATLAB

These commands only read bundled metadata:

```bash
./scripts/doctor.sh --out /tmp/matlab-plotting-skill-doctor
./scripts/render_with_matlab.sh --doctor --out /tmp/matlab-plotting-skill-doctor
./scripts/render_with_matlab.sh --list-schemes
./scripts/render_with_matlab.sh --list-schemes --status
./scripts/render_with_matlab.sh --scheme-info line_trend
./scripts/render_with_matlab.sh --scheme-info line_trend --status
./scripts/render_with_matlab.sh --scheme-info-json line_trend
```

If they fail, fix the checkout or shell wrapper before troubleshooting MATLAB.
The doctor report is written to `first_use_doctor.md/json` and does not render
figures.
The `--doctor` form is useful after the Skill has been copied into an agent
runtime because it stays inside the Skill folder.

## 2. Confirm MATLAB Is Callable

Set `MATLAB_BIN` when `matlab` is not already on `PATH`:

```bash
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab ./scripts/render_with_matlab.sh --check
```

Keep this separate from rendering so path problems are easier to diagnose.

## 3. Inspect And Plan With The Bundled CSV

Use the included CSV before trying research or project data:

```bash
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab ./scripts/render_with_matlab.sh --inspect-data --data examples/data/time_series.csv
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab ./scripts/render_with_matlab.sh --plan-only --data examples/data/time_series.csv --goal "show a time trend"
```

The plan-only command should name the selected scheme and top alternatives
without writing figure files.

For a short human-readable explanation, run:

```bash
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab ./scripts/render_with_matlab.sh --explain --data examples/data/time_series.csv --goal "show a time trend"
```

## 4. Use More Bundled Fixtures

After the first time-series pass, try the other public fixtures. They are tiny,
synthetic, and safe to share in issue reports.

| Fixture | Goal text | Expected direction |
|---|---|---|
| `examples/data/time_series.csv` | `show a time trend` | `line_trend` |
| `examples/data/multi_series.csv` | `compare multiple time series` | `multi_line_comparison` |
| `examples/data/confidence_band.csv` | `show uncertainty bounds` | `confidence_band` |
| `examples/data/method_scores.csv` | `compare methods` | `grouped_bar` or another comparison scheme |

Use the same inspect -> plan-only -> render rhythm for each fixture. This gives
you a quick feel for how the selector responds to data shape and goal wording
before you use private files.

## 5. Render Into A Scratch Directory

Render only after catalog, MATLAB, inspection, and plan-only checks pass:

```bash
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab ./scripts/render_with_matlab.sh --data examples/data/time_series.csv --goal "show a time trend" --out /tmp/matlab-plotting-skill-first-render --formats png,svg
```

SFT_OUTPUT_DIR is not used by this repository; pass `--out <directory>` to
choose the render location.

## If Something Fails

- Redact private paths and account names before sharing logs.
- Include the operating system, MATLAB version, command sequence, selected
  scheme, output formats, and report summary.
- Use the first-use feedback issue template instead of attaching private data
  files.
- See `docs/private-data-handling.md` for a short checklist before posting.
