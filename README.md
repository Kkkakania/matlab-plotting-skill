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
- Writes a short render report explaining the selected scheme and alternatives.

## Install

Copy or symlink the skill folder into your Codex skills directory:

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
ln -s "$(pwd)/skills/matlab-plotting-skill" "${CODEX_HOME:-$HOME/.codex}/skills/matlab-plotting-skill"
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
```

Render from data:

```bash
./scripts/render_with_matlab.sh --data examples/data/time_series.csv --goal "show a time trend" --out figures --formats png,svg
```

Smoke-test all bundled schemes with synthetic data:

```bash
./scripts/render_with_matlab.sh --smoke-test --out figures/smoke --formats png
```

## Scheme Coverage

The first release includes 50 plotting schemes across trends, relationships,
heatmaps, bars, distributions, rankings, compositions, multivariate plots, and
paper layout helpers. Similar schemes share parameterized renderers so the
skill stays maintainable.

See `skills/matlab-plotting-skill/references/scheme-catalog.md`.

## Provenance

All MATLAB code is clean-room code written for this repository. The public repo
does not include encrypted MATLAB files, raw MAT datasets, FIG files, document
packs, article screenshots, or private local paths.

