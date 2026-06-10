# CLI Output Contract

This document describes the machine-readable outputs that scripts can consume.
It is intentionally narrow: human-facing prose may change faster than these
field names.

## Metadata Commands

`--list-schemes-json` returns an array of 50 records. Each record includes:

- `schema_version`: currently `1.0`
- `scheme`
- `family`
- `best_for`
- `palette`

`--list-schemes-json --status` keeps the same records and adds:

- `readiness`: for example `gallery-backed`, `preview available`, `render path started`, or `cataloged`
- `gallery`: `preview`, `no`, or `unknown`

`--scheme-info-json <name>` returns one record with the same catalog fields.
`--scheme-info-json <name> --status` adds `readiness` and `gallery` for that
single scheme.

Unknown schemes fail with exit code `67` and print the missing scheme name to
stderr.

## MATLAB-Backed Commands

`--inspect-data` returns JSON from `mpInspectData`:

- `schema_version`
- `FileName`
- `VariableName`
- `Schema`

`--plan-only` returns JSON from `mpPlan`:

- `schema_version`
- `SelectedScheme`
- `SelectedFamily`
- `SelectedPalette`
- `Alternatives`
- `Schema`
- `Explanation`
- `ScoreSnapshot`

Full rendering writes `render_report.json`, which includes:

- `schema_version`
- `selectedScheme`
- `schemeFamily`
- `palette`
- `goal`
- `dataFile`
- `dataSummary`
- `selectionSignals`
- `selectionExplanation`
- `scoreSnapshot`
- `alternatives`
- `outputs`

The report stores file names rather than absolute local paths.

## Versioning Rules

Patch-level additions may add optional fields. Removing or renaming existing
fields requires a `schema_version` change and a changelog note.

The score values are routing evidence, not scientific rankings. Treat
`ScoreSnapshot` as an explanation aid, not a stable numeric API.
