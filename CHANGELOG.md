# Changelog

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
