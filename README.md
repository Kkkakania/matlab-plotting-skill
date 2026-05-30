# MATLAB Plotting Skill

An Agent Skill that chooses and renders MATLAB scientific figures from user data.

The skill is self-contained. It does not depend on private archives, local
template folders, or another plotting repository. The only runtime requirement
is a working MATLAB command line executable.

## What It Does

- Reads CSV, Excel, or MAT data.
- Infers the data shape and the user's plotting goal.
- Selects one of 50 plotting schemes.
- Renders the figure with clean-room MATLAB code bundled in the skill.
- Exports PNG and SVG by default, with optional PDF.
- Writes Markdown and JSON render reports explaining the selected scheme and alternatives.
- Includes concrete selection signals in reports so automatic choices are easier to audit.
- Includes a score snapshot for the top scheme candidates.

## Preview

All previews below are generated from bundled synthetic data.
The generated preview index is in `docs/gallery/index.md`, and preview
provenance is tracked in `docs/gallery/provenance.md`.

| Trend | Multi-Line | Confidence Band |
|---|---|---|
| ![line trend](docs/gallery/line_trend.png) | ![multi-line comparison](docs/gallery/multi_line_comparison.png) | ![confidence band](docs/gallery/confidence_band.png) |

| Heatmap | Density Scatter | Grouped Bar |
|---|---|---|
| ![heatmap matrix](docs/gallery/heatmap_matrix.png) | ![density scatter](docs/gallery/density_scatter.png) | ![grouped bar](docs/gallery/grouped_bar.png) |

## Install

Copy or symlink the skill folder into your Codex skills directory:

```bash
./scripts/install_skill.sh
```

Preview the install target first:

```bash
./scripts/install_skill.sh --dry-run
```

Then ask Codex for tasks such as:

```text
Use my CSV to make the best MATLAB figure for comparing methods.
Render a correlation figure from this Excel sheet.
Choose a plot for this MAT file and export PNG/SVG.
```

## CLI

Set MATLAB if it is not already on `PATH`:

```bash
export MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab
./scripts/render_with_matlab.sh --check
```

Render from data:

```bash
./scripts/render_with_matlab.sh --data examples/data/time_series.csv --goal "show a time trend" --out figures --formats png,svg
```

Inspect data schema without selecting or rendering:

```bash
./scripts/render_with_matlab.sh --inspect-data --data examples/data/time_series.csv
```

Preview the selected scheme without rendering:

```bash
./scripts/render_with_matlab.sh --plan-only --data examples/data/time_series.csv --goal "show a time trend"
```

Render with an explicit scheme:

```bash
./scripts/render_with_matlab.sh --list-schemes
./scripts/render_with_matlab.sh --list-schemes-json
./scripts/render_with_matlab.sh --scheme-info line_trend
./scripts/render_with_matlab.sh --scheme-info-json line_trend
./scripts/render_with_matlab.sh --data examples/data/method_scores.csv --scheme grouped_bar --out figures --formats png,svg
```

When a MAT file contains several variables, choose one explicitly:

```bash
./scripts/render_with_matlab.sh --data data/results.mat --var matrixData --goal "matrix heatmap" --out figures --formats png
```

See `skills/matlab-plotting-skill/references/example-prompts.md` for more
prompts.

Smoke-test all bundled schemes with synthetic data:

```bash
./scripts/render_with_matlab.sh --smoke-test --out figures/smoke --formats png
./scripts/check_gallery_outputs.sh --dir figures/smoke --format png
python3 scripts/build_gallery_index.py --dir figures/smoke --catalog skills/matlab-plotting-skill/references/scheme-catalog.md --out figures/smoke/index.md --format png
python3 scripts/build_gallery_index.py --dir docs/gallery --catalog skills/matlab-plotting-skill/references/scheme-catalog.md --out docs/gallery/index.md --format png --only-existing
```

Run the representative visual fixture suite:

```bash
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab ./scripts/run_visual_fixtures.sh
```

Build the automation manifest used to audit scheme coverage:

```bash
python3 scripts/build_automation_manifest.py --out figures/automation-manifest.json
```

GitHub Actions also uploads this manifest as a workflow artifact on each push
and pull request.

Build the exact 500-task plan:

```bash
python3 scripts/build_task_manifest.py --json-out task-manifest.json --markdown-out task-board.md
```

The task plan maps 50 plotting schemes to 10 concrete task lanes each and
summarizes coverage by family and lane. GitHub Actions uploads both
`task-manifest.json` and `task-board.md`.

Filter the task plan when working on one scheme or one lane:

```bash
python3 scripts/build_task_manifest.py --json-out line-trend.json --markdown-out line-trend.md --scheme line_trend
python3 scripts/build_task_manifest.py --json-out safety.json --markdown-out safety.md --lane safety
```

Unknown scheme or lane names fail fast instead of producing an empty board.
Task progress is tracked in `docs/task-status.json`; the committed task board
uses that file when generated.

Run the release gate:

```bash
./scripts/release_check.sh
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab ./scripts/release_check.sh --with-matlab
```

## Scheme Coverage

The first release includes 50 plotting schemes across trends, relationships,
heatmaps, bars, distributions, rankings, compositions, multivariate plots, and
paper layout helpers. Similar schemes share parameterized renderers so the
skill stays maintainable.

See `skills/matlab-plotting-skill/references/scheme-catalog.md`.
See `docs/chart-selection-guide.md` when choosing between schemes.
See `docs/figure-quality-checklist.md` before sharing rendered figures.
See `docs/palette-accessibility-notes.md` when color choice affects the result.
See `docs/automation-manifest.md` for the generated check matrix.
See `docs/500-task-plan.md` for the exact 500-task roadmap.
See `docs/500-task-board.md` for the committed 500 planned goals and steps.

## Provenance

All MATLAB code is clean-room code written for this repository. The public repo
does not include encrypted MATLAB files, raw MAT datasets, FIG files, document
packs, article screenshots, or private local paths. Generated render reports
store input and output file names rather than absolute local paths.

See `CONTRIBUTING.md`, `SECURITY.md`, and `CHANGELOG.md` for maintenance notes.
