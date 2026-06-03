# MATLAB Plotting Skill

[English](README.md) | [简体中文](README.zh-CN.md)

An Agent Skill that chooses and renders MATLAB scientific figures from user data.

The skill is self-contained. It does not depend on private archives, local
template folders, or another plotting repository. The only runtime requirement
is a working MATLAB command line executable.

## Project Ecosystem

This skill is the agent-facing layer in a small MATLAB scientific-figure
ecosystem:

- [`matlab-scientific-figures`](https://github.com/Kkkakania/matlab-scientific-figures)
  is the main clean-room MATLAB gallery and template reference.
- [`matlab-figure-ci`](https://github.com/Kkkakania/matlab-figure-ci) provides
  CI/CLI checks for gallery outputs, provenance, privacy, and release readiness.
- [`matlab-plotting-skill`](https://github.com/Kkkakania/matlab-plotting-skill)
  helps agents choose and render suitable MATLAB figures from user data.

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
Current support status is tracked in `docs/scheme-readiness.md`, which separates
the 50-scheme catalog from gallery-backed and still-maturing schemes.

| Trend | Multi-Line | Confidence Band |
|---|---|---|
| ![line trend](docs/gallery/line_trend.png) | ![multi-line comparison](docs/gallery/multi_line_comparison.png) | ![confidence band](docs/gallery/confidence_band.png) |

| Zoomed Inset | Scatter | Density Scatter |
|---|---|---|
| ![zoomed inset line](docs/gallery/zoomed_inset_line.png) | ![scatter relationship](docs/gallery/scatter_relationship.png) | ![density scatter](docs/gallery/density_scatter.png) |

| Grouped Scatter | Contour Scatter | Regression Scatter |
|---|---|---|
| ![grouped scatter](docs/gallery/grouped_scatter.png) | ![contour scatter](docs/gallery/contour_scatter.png) | ![regression scatter](docs/gallery/regression_scatter.png) |

| Heatmap | Grouped Bar | Positive/Negative Area |
|---|---|---|
| ![heatmap matrix](docs/gallery/heatmap_matrix.png) | ![grouped bar](docs/gallery/grouped_bar.png) | ![positive negative area](docs/gallery/positive_negative_area.png) |

| Segmented Line |
|---|
| ![segmented line](docs/gallery/segmented_line.png) |

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

For a first hands-on pass, follow
[`docs/first-render-walkthrough.md`](docs/first-render-walkthrough.md). It
walks through MATLAB setup, data inspection, `--plan-only`, rendering, and
post-render checks with one bundled CSV.

Fresh-clone feedback is most useful when it includes the MATLAB version,
commands run, selected scheme, report summary, and any redacted failure output.
Use the first-use feedback issue template for that path instead of pasting
private data files or local path dumps.

## First 5 Minutes

Use this narrow path on a fresh clone before trying private data:

1. Check the catalog without MATLAB.

   ```bash
   ./scripts/render_with_matlab.sh --list-schemes
   ./scripts/render_with_matlab.sh --list-schemes --status
   ./scripts/render_with_matlab.sh --scheme-info line_trend
   ```

2. Confirm MATLAB is callable.

   ```bash
   MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab ./scripts/render_with_matlab.sh --check
   ```

3. Inspect and plan with the bundled CSV.

   ```bash
   MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab ./scripts/render_with_matlab.sh --inspect-data --data examples/data/time_series.csv
   MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab ./scripts/render_with_matlab.sh --plan-only --data examples/data/time_series.csv --goal "show a time trend"
   ```

4. Render into a scratch directory.

   ```bash
   MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab ./scripts/render_with_matlab.sh --data examples/data/time_series.csv --goal "show a time trend" --out /tmp/matlab-plotting-skill-first-render --formats png,svg
   ```

SFT_OUTPUT_DIR is not used by this repository; pass `--out <directory>` to
choose the render location.

The same sequence is available as a shareable
[`docs/first-five-minutes.md`](docs/first-five-minutes.md) guide, including
additional bundled fixtures such as `multi_series.csv`, `confidence_band.csv`,
and `method_scores.csv`.

## CLI

### Try Metadata First

Use these commands before configuring MATLAB:

```bash
./scripts/render_with_matlab.sh --list-schemes
./scripts/render_with_matlab.sh --scheme-info line_trend
./scripts/render_with_matlab.sh --scheme-info-json line_trend
```

These commands do not render figures. They help confirm that the repository,
skill catalog, and shell wrapper are working before you point the workflow at a
MATLAB executable.

Set MATLAB if it is not already on `PATH`:

```bash
export MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab
./scripts/render_with_matlab.sh --check
```

MATLAB-backed commands use a 600-second timeout by default. Set
`MP_MATLAB_TIMEOUT_SECONDS=0` to disable the guard for a long local render, or
set a smaller value when testing CI behavior.

Some commands are metadata-only and can be used before MATLAB is configured.
Commands that inspect data, plan a figure, smoke-test schemes, or render output
call MATLAB because the data loading and selection logic lives in the bundled
MATLAB code.

| Works without MATLAB | Requires MATLAB |
|---|---|
| `--list-schemes` | `--check` |
| `--list-schemes-json` | `--inspect-data --data <file>` |
| `--scheme-info <name>` | `--plan-only --data <file> --goal "<text>"` |
| `--scheme-info-json <name>` | `--smoke-test` |
|  | full rendering with `--data`, `--goal`, and `--out` |

Render from data:

```bash
./scripts/render_with_matlab.sh --data examples/data/time_series.csv --goal "show a time trend" --out figures --formats png,svg
```

`--formats` accepts a comma-separated list containing `png`, `svg`, and `pdf`.
Invalid entries fail before MATLAB starts.

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

The JSON catalog commands keep the existing array/item shape and include a
`schema_version` field on each record so downstream scripts can detect future
format changes without brittle key guessing.

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

By default, this writes to `/tmp/matlab-plotting-skill-visual-fixtures` so a
fresh checkout stays clean. Add `--out <directory>` when you want to keep the
fixture images somewhere else.

Build the automation manifest used to audit scheme coverage:

```bash
python3 scripts/build_automation_manifest.py --out figures/automation-manifest.json
```

GitHub Actions also uploads this manifest as a workflow artifact on each push
and pull request.

Build the long-horizon scheme backlog:

```bash
python3 scripts/build_task_manifest.py --json-out task-manifest.json --markdown-out task-board.md
```

The backlog maps 50 plotting schemes to 10 concrete task lanes each and
summarizes coverage by family and lane. It is planning infrastructure, not a
release cadence, so related rows should be batched into normal maintenance
releases. GitHub Actions uploads both `task-manifest.json` and `task-board.md`.

Filter the backlog when working on one scheme or one lane:

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

Public GitHub Actions run packaging, docs, manifest, privacy, provenance, and
MATLAB wrapper checks on hosted Linux runners. They do not perform real MATLAB
rendering. Rendering changes should also pass the MATLAB release gate above on a
machine with MATLAB installed. See `docs/ci-coverage.md`.

## Release Status

The current public line is `v0.1.x`. Early bootstrap tags were intentionally
small while the scheme catalog, preview gallery, task board, and release gates
were being assembled. Future tags should be slower and grouped around
user-visible changes such as a gallery-backed scheme, a new CLI/report field, a
renderer behavior fix, or a first-use workflow improvement.

For the exact policy, see `docs/maintenance-cadence.md`.

## Scheme Coverage

The catalog contains 50 plotting schemes across trends, relationships,
heatmaps, bars, distributions, rankings, compositions, multivariate plots, and
paper layout helpers. Treat the gallery-backed schemes listed in
`docs/scheme-readiness.md` as the most stable first-use path: they have
committed previews, data contracts, CLI coverage, PNG/vector checks, reports,
and safety coverage. Cataloged-only schemes are tracked design targets until
their support lanes are completed.

Similar schemes share parameterized renderers so the skill stays maintainable.

See `skills/matlab-plotting-skill/references/scheme-catalog.md`.
See `docs/first-render-walkthrough.md` for the shortest first-render path.
See `docs/chart-selection-guide.md` when choosing between schemes.
See `docs/figure-quality-checklist.md` before sharing rendered figures.
See `docs/scheme-readiness.md` for the current user-facing support matrix.
See `docs/palette-accessibility-notes.md` when color choice affects the result.
See `docs/ecosystem-status.md` for repository roles, feedback channels, and
claim boundaries.
See `docs/automation-manifest.md` for the generated check matrix.
See `docs/maintenance-cadence.md` for the normal issue, batching, and release
rhythm.
See `ROADMAP.md` for the current state, next candidates, and non-goals.
See `docs/500-task-plan.md` for the long-horizon scheme backlog.
See `docs/500-task-board.md` for the committed task board used to plan
incremental scheme work without turning every task into a release.

## Provenance

All MATLAB code is clean-room code written for this repository. The public repo
does not include encrypted MATLAB files, raw MAT datasets, FIG files, document
packs, article screenshots, or private local paths. Generated render reports
store input and output file names rather than absolute local paths.

See `CONTRIBUTING.md`, `SECURITY.md`, and `CHANGELOG.md` for maintenance notes.
