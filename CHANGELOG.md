# Changelog

## v0.1.41

- Completed `TASK-009-line_trend-gallery` in the 500-task board.
- Added an `--only-existing` gallery index mode and a committed gallery index
  so public previews show real rendered assets without placeholder rows.
- Added release-gate and CI coverage proving `line_trend` is represented in
  the generated gallery with catalog metadata.

## v0.1.40

- Completed `TASK-008-line_trend-report` in the 500-task board.
- Added MATLAB regression coverage proving Markdown and JSON reports record
  `line_trend` and its generated output.

## v0.1.39

- Completed `TASK-007-line_trend-vector-render` in the 500-task board.
- Added MATLAB regression coverage proving `line_trend.svg` and
  `line_trend.pdf` are generated and non-empty.

## v0.1.38

- Completed `TASK-006-line_trend-png-render` in the 500-task board.
- Added MATLAB regression coverage proving `line_trend.png` is generated and
  non-empty.

## v0.1.37

- Completed `TASK-005-line_trend-explicit-cli` in the 500-task board.
- Added MATLAB regression coverage proving explicit `line_trend` selection
  creates deterministic output and report metadata.

## v0.1.36

- Completed `TASK-004-line_trend-selection-rule` in the 500-task board.
- Added MATLAB regression coverage proving time-series demo data is routed to
  `line_trend` ahead of unrelated relationship schemes.

## v0.1.35

- Completed `TASK-003-line_trend-demo-data` in the 500-task board.
- Added MATLAB regression coverage proving the `line_trend` synthetic demo data
  has the expected schema, selects `line_trend`, and renders a figure.

## v0.1.34

- Completed `TASK-002-line_trend-data-contract` in the 500-task board.
- Added regression coverage proving the `line_trend` data contract appears in
  both the scheme catalog and chart selection guide.

## v0.1.33

- Added task status overrides for the 500-task roadmap.
- Marked `TASK-001-line_trend-catalog` as done after verifying
  `--scheme-info line_trend` exposes the required catalog fields.
- Added release-gate and CI coverage for valid statuses and task override IDs.

## v0.1.32

- Added a committed `docs/500-task-board.md` with all 500 planned goals,
  acceptance checks, command hints, and statuses.
- Added release-gate and CI coverage so the committed board must contain
  exactly 500 task rows.

## v0.1.31

- Task-roadmap filters now fail fast for unknown scheme or lane names.
- Added regression coverage so misspelled filters cannot silently produce empty
  task boards.

## v0.1.30

- Added `--scheme` and `--lane` filters to the 500-task roadmap generator.
- Added tests for focused task boards, including one-scheme and one-lane views.

## v0.1.29

- Added family and lane summaries to the generated 500-task roadmap.
- Extended task-manifest tests so the summary counts must add up to exactly
  500 tasks.

## v0.1.28

- Added an exact 500-task roadmap generated from 50 plotting schemes and 10
  task lanes per scheme.
- Added JSON and Markdown task-board generation plus CI artifact upload.
- Added release-gate coverage to prevent the task plan from drifting away from
  exactly 500 tasks.

## v0.1.27

- Updated GitHub Actions to run the scheme-info and automation-manifest tests.
- Added a CI artifact that uploads `automation-manifest.json` on each push and
  pull request.

## v0.1.26

- Added an automation manifest generator that expands the 50 scheme catalog
  into 1,100 concrete audit checks across catalog, selection, rendering,
  reporting, and safety stages.
- Added release-gate coverage to keep the manifest above 500 checks with
  unique IDs and useful command hints.

## v0.1.25

- Added CLI `--scheme-info` and `--scheme-info-json` for single-scheme lookup
  without launching MATLAB.
- Added release-gate coverage for scheme lookup and unknown-scheme errors.

## v0.1.24

- Added CLI `--list-schemes-json` for machine-readable scheme catalog output.
- Added CI and release-gate coverage for JSON catalog output.

## v0.1.23

- Added example prompts for schema inspection and plan-only selection workflows.
- Added CI coverage for key prompt examples.

## v0.1.22

- Added `mpInspectData` for schema inspection without plot selection or rendering.
- Added CLI `--inspect-data` to return schema JSON for CSV, Excel, and MAT inputs.

## v0.1.21

- Documented `--plan-only` / `mpPlan` in the skill workflow.
- Added CI coverage so the skill entrypoint keeps the plan-only guidance.

## v0.1.20

- Added `mpPlan` for selecting a plotting scheme without rendering.
- Added CLI `--plan-only` to return a JSON planning result before export.

## v0.1.19

- Added `scripts/release_check.sh` as a single release gate for local maintainers.
- Added optional MATLAB-backed release checks through `--with-matlab`.

## v0.1.18

- Added a representative renderer-level visual fixture suite.
- Added a local MATLAB entrypoint for fixture rendering and report metadata checks.

## v0.1.17

- Added top-candidate score snapshots to Markdown and JSON render reports.
- Extended MATLAB regression coverage for selection transparency.

## v0.1.16

- Added README gallery preview images generated from bundled synthetic data.
- Added CI coverage to ensure README gallery assets remain present and linked.

## v0.1.15

- Added concrete selection signals to Markdown and JSON render reports.
- Added MATLAB regression coverage for report transparency.

## v0.1.14

- Added explicit MAT variable selection through `mpReadData(..., variableName)`
  and CLI `--var`.
- Improved ambiguous MAT-file errors with candidate variable summaries.

## v0.1.13

- Added palette and accessibility notes for categorical, sequential, diverging,
  and neutral palettes.
- Linked palette guidance from the figure quality checklist and README.

## v0.1.12

- Added Markdown gallery index generation for smoke-test outputs.
- Added fixture-based CI coverage for the gallery index builder.

## v0.1.11

- Added a chart selection guide organized by task and data shape.
- Added CI coverage for the guide.

## v0.1.10

- Added a figure quality checklist for reviewing exported MATLAB figures before
  sharing them.
- Added CI coverage for the checklist.

## v0.1.9

- Added `render_report.json` beside the Markdown report for automation.
- Kept JSON report paths privacy-safe by storing file names, not absolute paths.

## v0.1.8

- Added `--check` to verify MATLAB CLI wiring before rendering.
- Added shell coverage with a fake MATLAB executable.

## v0.1.7

- Added GitHub issue forms for bugs and scheme requests.
- Added a pull request template with testing and provenance checks.

## v0.1.6

- Added CONTRIBUTING, SECURITY, CODE_OF_CONDUCT, and CHANGELOG.
- Added repository docs coverage in CI.

## v0.1.5

- Added `--list-schemes` so users can browse all 50 plotting schemes without
  starting MATLAB.
- Added shell coverage for the scheme list.

## v0.1.4

- Changed render reports to use input and output file names instead of absolute
  local paths.
- Added MATLAB regression coverage for report privacy.

## v0.1.3

- Added a gallery output checker for smoke-test render folders.
- Added CI coverage for gallery checks.

## v0.1.2

- Added an install helper with dry-run and copy modes.
- Added example prompts for common skill requests.

## v0.1.1

- Added explicit scheme rendering with `--scheme`.

## v0.1.0

- Initial self-contained skill release with 50 plotting schemes, MATLAB CLI
  rendering, synthetic demo data, validation scripts, and privacy/provenance
  checks.
