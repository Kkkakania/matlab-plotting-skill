# Changelog

## v0.1.82

- Completed `TASK-050-positive_negative_area-safety` in the 500-task board.
- Added a dedicated safety regression for the `positive_negative_area` public
  preview, README link, and provenance row.

## v0.1.81

- Completed `TASK-049-positive_negative_area-gallery` in the 500-task board.
- Added a committed gallery preview, README entry, provenance row, and CI
  coverage for `positive_negative_area`.

## v0.1.80

- Completed `TASK-048-positive_negative_area-report` in the 500-task board.
- Added MATLAB regression coverage proving Markdown and JSON reports record
  `positive_negative_area` and its generated output.

## v0.1.79

- Completed `TASK-047-positive_negative_area-vector-render` in the 500-task
  board.
- Added MATLAB regression coverage proving `positive_negative_area.svg` and
  `positive_negative_area.pdf` are generated and non-empty.

## v0.1.78

- Completed `TASK-046-positive_negative_area-png-render` in the 500-task board.
- Added MATLAB regression coverage proving `positive_negative_area.png` is
  generated and non-empty from synthetic signed-delta data.

## v0.1.77

- Completed `TASK-045-positive_negative_area-explicit-cli` in the 500-task
  board.
- Added MATLAB regression coverage proving explicit `positive_negative_area`
  selection creates deterministic output and report metadata from synthetic CSV
  input.

## v0.1.76

- Completed `TASK-044-positive_negative_area-selection-rule` in the 500-task
  board.
- Improved scheme scoring so time-series signed-change goals around zero prefer
  `positive_negative_area`.
- Added MATLAB regression coverage comparing `positive_negative_area`,
  `line_trend`, and `diverging_bar` scores for signed-delta goals.

## v0.1.75

- Completed `TASK-043-positive_negative_area-demo-data` in the 500-task board.
- Added scheme-specific synthetic signed-delta data with values above and below
  zero.
- Added MATLAB regression coverage proving the demo data is recognized as
  positive/negative and renders with area objects.

## v0.1.74

- Completed `TASK-042-positive_negative_area-data-contract` in the 500-task
  board.
- Documented the expected `positive_negative_area` shape: ordered x-axis,
  signed numeric series, and a meaningful zero reference line.
- Added release-gate and CI coverage for the scheme-specific contract.

## v0.1.73

- Completed `TASK-041-positive_negative_area-catalog` in the 500-task board.
- Added release-gate and CI coverage proving `positive_negative_area` is
  exposed through text and JSON scheme-info with its catalog metadata.

## v0.1.72

- Completed `TASK-040-zoomed_inset_line-safety` in the 500-task board.
- Added release-gate and CI coverage checking the zoomed-inset gallery preview,
  README reference, and provenance row for private or unclear traces.

## v0.1.71

- Completed `TASK-039-zoomed_inset_line-gallery` in the 500-task board.
- Added a committed `zoomed_inset_line` gallery preview generated from bundled
  synthetic demo data.
- Updated README preview, gallery index, provenance, release-gate checks, and
  CI coverage for the new preview.

## v0.1.70

- Completed `TASK-038-zoomed_inset_line-report` in the 500-task board.
- Added MATLAB regression coverage proving Markdown and JSON reports record
  `zoomed_inset_line` and its generated output.

## v0.1.69

- Completed `TASK-037-zoomed_inset_line-vector-render` in the 500-task board.
- Added MATLAB regression coverage proving `zoomed_inset_line.svg` and
  `zoomed_inset_line.pdf` are generated and non-empty.

## v0.1.68

- Completed `TASK-036-zoomed_inset_line-png-render` in the 500-task board.
- Added MATLAB regression coverage proving `zoomed_inset_line.png` is generated
  and non-empty from synthetic local-event data.

## v0.1.67

- Completed `TASK-035-zoomed_inset_line-explicit-cli` in the 500-task board.
- Added MATLAB regression coverage proving explicit `zoomed_inset_line`
  selection creates deterministic output and report metadata from synthetic
  CSV input.

## v0.1.66

- Completed `TASK-034-zoomed_inset_line-selection-rule` in the 500-task board.
- Improved scheme scoring so time-series goals mentioning zoomed detail,
  local events, anomaly windows, or highlights prefer `zoomed_inset_line`.
- Added MATLAB regression coverage comparing `zoomed_inset_line` and
  `line_trend` scores for local-detail goals.

## v0.1.65

- Completed `TASK-033-zoomed_inset_line-demo-data` in the 500-task board.
- Added scheme-specific synthetic demo data with a long ordered trend and a
  visible local event window.
- Added MATLAB regression coverage proving the demo data renders with a main
  axis, inset axis, and highlighted detail rectangle.

## v0.1.64

- Completed `TASK-032-zoomed_inset_line-data-contract` in the 500-task board.
- Documented the expected `zoomed_inset_line` shape: long ordered x-axis,
  one or more numeric series, and a meaningful local interval to inspect.
- Added release-gate and CI coverage for the scheme-specific contract.

## v0.1.63

- Completed `TASK-031-zoomed_inset_line-catalog` in the 500-task board.
- Added release-gate and CI coverage proving `zoomed_inset_line` is exposed
  through text and JSON scheme-info with its catalog metadata.
- Aligned the MATLAB scheme catalog description with the public scheme catalog.

## v0.1.62

- Completed `TASK-030-confidence_band-safety` in the 500-task board.
- Added release-gate and CI coverage checking the confidence-band CSV example,
  gallery preview, and provenance row for private or unclear traces.

## v0.1.61

- Completed `TASK-029-confidence_band-gallery` in the 500-task board.
- Added a committed `confidence_band` gallery preview generated from the
  synthetic uncertainty CSV example.
- Updated README preview, gallery index, provenance, release-gate checks, and
  CI coverage for the new preview.

## v0.1.60

- Completed `TASK-028-confidence_band-report` in the 500-task board.
- Added MATLAB regression coverage proving Markdown and JSON reports record
  `confidence_band` and its generated output.

## v0.1.59

- Completed `TASK-027-confidence_band-vector-render` in the 500-task board.
- Added MATLAB regression coverage proving `confidence_band.svg` and
  `confidence_band.pdf` are generated and non-empty.

## v0.1.58

- Completed `TASK-026-confidence_band-png-render` in the 500-task board.
- Added MATLAB regression coverage proving `confidence_band.png` is generated
  and non-empty from the synthetic uncertainty CSV example.

## v0.1.57

- Completed `TASK-025-confidence_band-explicit-cli` in the 500-task board.
- Added a small synthetic `examples/data/confidence_band.csv` file for
  explicit confidence-band rendering workflows.
- Added MATLAB regression coverage proving explicit `confidence_band` selection
  creates deterministic output and report metadata.

## v0.1.56

- Completed `TASK-024-confidence_band-selection-rule` in the 500-task board.
- Improved scheme scoring so time-series goals mentioning confidence,
  uncertainty, intervals, bands, or bounds prefer `confidence_band`.
- Added MATLAB regression coverage comparing `confidence_band` and `line_trend`
  scores for uncertainty-focused goals.

## v0.1.55

- Completed `TASK-023-confidence_band-demo-data` in the 500-task board.
- Added scheme-specific synthetic `confidence_band` demo data with `center`,
  `lower`, and `upper` columns.
- Updated the confidence-band renderer to use provided lower/upper bounds when
  present, with MATLAB regression coverage for line and band objects.

## v0.1.54

- Completed `TASK-022-confidence_band-data-contract` in the 500-task board.
- Documented the expected `confidence_band` shape: ordered x-axis, center
  series, and optional lower/upper uncertainty columns.
- Added release-gate and CI coverage for the scheme-specific contract.

## v0.1.53

- Completed `TASK-021-confidence_band-catalog` in the 500-task board.
- Added release-gate and CI coverage proving `confidence_band` is exposed
  through text and JSON scheme-info with its catalog metadata.

## v0.1.52

- Completed `TASK-020-multi_line_comparison-safety` in the 500-task board.
- Added release-gate and CI coverage checking the multi-line CSV example,
  gallery preview, and provenance row for private or unclear traces.

## v0.1.51

- Completed `TASK-019-multi_line_comparison-gallery` in the 500-task board.
- Added a committed `multi_line_comparison` gallery preview generated from the
  synthetic CSV example.
- Updated README preview, gallery index, provenance, release-gate checks, and
  CI coverage for the new preview.

## v0.1.50

- Completed `TASK-018-multi_line_comparison-report` in the 500-task board.
- Added MATLAB regression coverage proving Markdown and JSON reports record
  `multi_line_comparison` and its generated output.

## v0.1.49

- Completed `TASK-017-multi_line_comparison-vector-render` in the 500-task
  board.
- Added MATLAB regression coverage proving `multi_line_comparison.svg` and
  `multi_line_comparison.pdf` are generated and non-empty.

## v0.1.48

- Completed `TASK-016-multi_line_comparison-png-render` in the 500-task board.
- Added MATLAB regression coverage proving `multi_line_comparison.png` is
  generated and non-empty from the synthetic wide CSV example.

## v0.1.47

- Completed `TASK-015-multi_line_comparison-explicit-cli` in the 500-task
  board.
- Added a small synthetic `examples/data/multi_series.csv` file for explicit
  multi-line rendering workflows.
- Added MATLAB regression coverage proving explicit `multi_line_comparison`
  selection creates deterministic output and report metadata.

## v0.1.46

- Completed `TASK-014-multi_line_comparison-selection-rule` in the 500-task
  board.
- Improved scheme scoring so wide time-series data with compare/multiple-series
  goals prefers `multi_line_comparison` over single-line trend output.
- Added MATLAB regression coverage comparing `multi_line_comparison` and
  `line_trend` scores for a wide synthetic time-series table.

## v0.1.45

- Completed `TASK-013-multi_line_comparison-demo-data` in the 500-task board.
- Added MATLAB regression coverage proving the bundled synthetic demo data
  contains a wide multi-series shape and renders at least two lines.

## v0.1.44

- Completed `TASK-012-multi_line_comparison-data-contract` in the 500-task
  board.
- Documented the expected wide-table input shape for multi-line comparison:
  one ordered x-axis column plus at least two numeric series columns.
- Added release-gate and CI coverage for the scheme-specific contract.

## v0.1.43

- Completed `TASK-011-multi_line_comparison-catalog` in the 500-task board.
- Added release-gate and CI coverage proving `multi_line_comparison` is exposed
  through text and JSON scheme-info with its catalog metadata.

## v0.1.42

- Completed `TASK-010-line_trend-safety` in the 500-task board.
- Added a gallery provenance file documenting committed preview assets as
  synthetic-data renders rather than external figures or private examples.
- Added release-gate and CI coverage that fails when committed gallery PNGs do
  not have provenance rows.

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
