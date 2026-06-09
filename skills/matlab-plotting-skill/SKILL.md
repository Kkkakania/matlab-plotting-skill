---
name: matlab-plotting-skill
description: Self-contained MATLAB scientific plotting skill. Use when the user asks Codex to choose, generate, adapt, render, export, or review MATLAB figures from CSV, Excel, MAT, table, matrix, or described data; when they need MATLAB CLI rendering; when they want an automatic plot choice, palette choice, PNG/SVG/PDF export, render report, or a publication-style figure workflow.
activation:
  version: 1
  prefers:
    - user explicitly mentions MATLAB, .m, .mat, .fig, Simulink, or MATLAB CLI
    - user has MATLAB_BIN configured or asks for MATLAB-backed rendering
    - user wants reproducible publication-style figures with PNG/SVG/PDF export reports
    - user asks to inspect CSV, Excel, MAT, table, matrix, or described data for a MATLAB figure
  deprioritises:
    - user says Python, matplotlib, seaborn, plotly, R, ggplot, gnuplot, or no MATLAB
    - recent MATLAB CLI check failed and the user has not asked to retry MATLAB
    - user only needs a lightweight browser, web, or spreadsheet chart
---

# MATLAB Plotting Skill

## Overview

Use this skill to turn user data and a plotting goal into a rendered MATLAB
figure. The bundled MATLAB assets include 50 plotting schemes, a data-schema
inference layer, palette defaults, exporters, and a report writer.

This skill is self-contained. Do not rely on private local folders, external
plotting repositories, encrypted MATLAB files, or article image packs.
If local plotting folders are present, use them only to identify chart tasks and
read `docs/local-resource-intake.md` before turning any idea into public code.

## Workflow

1. Inspect the user's request and identify the communication task: trend,
   relationship, matrix, comparison, distribution, ranking, composition,
   multivariate, spatial/vector, or layout.
2. If the user provided a file, check whether it is CSV, Excel, or MAT. See
   `references/data-contract.md` when the data shape is unclear.
3. Choose the plot by reading `references/scheme-catalog.md` only when the
   built-in name/tag mapping is not enough. To inspect one scheme without
   opening MATLAB, use `--scheme-info <name>` or `--scheme-info-json <name>`.
   Read `references/example-prompts.md` when writing usage examples for a user.
   If the idea came from a private local plotting folder, write it as a public
   communication task first and check `docs/local-resource-intake.md` before
   touching code.
4. When the user needs to inspect file structure before choosing a plot, use
   `--inspect-data`, which calls `mpInspectData` and returns schema JSON.
5. When the user wants to inspect the choice before rendering, preview the
   selection with `--plan-only`, which calls `mpPlan` and returns JSON:

   ```bash
   skills/matlab-plotting-skill/scripts/render_with_matlab.sh --plan-only --data <file> --goal "<goal>"
   ```

6. Prefer the bundled CLI for rendering:

   ```bash
   skills/matlab-plotting-skill/scripts/render_with_matlab.sh --data <file> --goal "<goal>" --out <dir> --formats png,svg
   ```

   Use `--scheme <name>` when the user asks for a specific scheme.

7. If MATLAB is missing, explain that the user needs MATLAB CLI and provide the
   exact command to run later. Do not claim a figure was rendered.
8. After rendering, report the selected scheme, output files, and any quality
   warnings from `render_report.md`. Use `render_report.json` when a script or
   follow-up automation needs structured metadata.

For a first-time user, mirror the sequence in
`docs/first-render-walkthrough.md`: check MATLAB, inspect data, run
`--plan-only`, render PNG/SVG, then review the report and privacy checks.

## MATLAB CLI

The renderer uses `MATLAB_BIN` when set, then falls back to `matlab` on `PATH`.
MATLAB-backed commands have a 600-second timeout by default. `--smoke-test`
auto-scales the timeout from the catalog size and prints the applied budget;
set `MP_MATLAB_TIMEOUT_SECONDS=0` only for deliberate long local renders.
On macOS, a common value is:

```bash
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab
```

Read `references/matlab-cli.md` for troubleshooting.

## Selection Defaults

- Time column plus numeric values: trend schemes.
- Two numeric columns: scatter or density scatter.
- Numeric matrix: heatmap schemes.
- Category plus numeric values: grouped bar, box/jitter, or ranking schemes.
- Percent or part-whole language: composition schemes.
- Positive and negative values: diverging bar or positive-negative area.
- "Zoom", "event", "detail", or "local": zoomed inset line.
- "Paper", "panel", "overview", or "layout": multi-panel or annotated layout.

When a MAT file has multiple plausible variables, list the candidates and ask
the user which variable to render instead of guessing.

## Safety Rules

- Keep generated scripts and outputs in the user's chosen project directory.
- Do not write into the skill directory during normal use.
- Do not copy raw private data into this repository.
- Treat local plotting collections as requirements sources only; do not copy
  their code, labels, screenshots, watermarks, binary artifacts, or author
  metadata.
- Do not introduce `.p`, `.fig`, committed `.mat`, `.docx`, `.pdf`, article
  screenshots, local absolute paths, email addresses, or provenance-unclear
  source files.
- Keep generated preview assets out of `skills/`, `scripts/`, and source or
  template directories; use reviewed output or gallery folders.
- Use synthetic data for smoke tests and examples.
