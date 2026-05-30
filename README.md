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

| Trend | Grouped Bar |
|---|---|
| ![line trend](docs/gallery/line_trend.png) | ![grouped bar](docs/gallery/grouped_bar.png) |

| Heatmap | Density Scatter |
|---|---|
| ![heatmap matrix](docs/gallery/heatmap_matrix.png) | ![density scatter](docs/gallery/density_scatter.png) |

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

Render with an explicit scheme:

```bash
./scripts/render_with_matlab.sh --list-schemes
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
```

Run the representative visual fixture suite:

```bash
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab ./scripts/run_visual_fixtures.sh
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

## Provenance

All MATLAB code is clean-room code written for this repository. The public repo
does not include encrypted MATLAB files, raw MAT datasets, FIG files, document
packs, article screenshots, or private local paths. Generated render reports
store input and output file names rather than absolute local paths.

See `CONTRIBUTING.md`, `SECURITY.md`, and `CHANGELOG.md` for maintenance notes.
