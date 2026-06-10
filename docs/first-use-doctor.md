# First-use Doctor

`scripts/doctor.sh` is a pre-render diagnostic for a fresh clone. It is meant
to answer a simple question before a user spends time debugging MATLAB:

> Is this checkout healthy enough to start planning or rendering figures?

The doctor does not render figures. It checks repository metadata, public
catalog health, readiness docs, privacy/provenance scans, and optional data-file
shape hints. MATLAB is only called when `--with-matlab` is provided.

## Metadata-only Check

The default mode is `metadata-only`.

Run this first:

```bash
./scripts/doctor.sh --out /tmp/matlab-plotting-skill-doctor
```

This writes:

- `/tmp/matlab-plotting-skill-doctor/first_use_doctor.md`
- `/tmp/matlab-plotting-skill-doctor/first_use_doctor.json`

The JSON report uses `schema_version: 1.0` and is safe for automation. The
Markdown report is easier to paste into first-use feedback after a human review.

## Check A Data File Lightly

Before exposing private data to rendering, check the filename and extension:

```bash
./scripts/doctor.sh \
  --out /tmp/matlab-plotting-skill-doctor \
  --data examples/data/time_series.csv
```

The report stores only the file name, such as `time_series.csv`, not the
absolute local path. It does not inspect file contents unless MATLAB-backed
commands are run later through `--inspect-data`, `--plan-only`, or rendering.

## Include MATLAB CLI

Use this when you want the doctor to verify MATLAB can start:

```bash
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab \
  ./scripts/doctor.sh \
  --out /tmp/matlab-plotting-skill-doctor \
  --with-matlab
```

The MATLAB check inherits the same `MATLAB_BIN` and
`MP_MATLAB_TIMEOUT_SECONDS` behavior as the rendering wrapper.

## What It Checks

- repository skeleton: README and `SKILL.md`
- scheme catalog count: 50 public schemes
- readiness matrix: committed support status
- privacy scan: no obvious private/provenance traces
- forbidden-file scan: no `.p`, `.fig`, committed `.mat`, document bundles, or archives
- optional data extension: CSV, Excel, and MAT are supported
- optional MATLAB CLI check when `--with-matlab` is passed

## How It Fits The Workflow

Use the doctor before `--inspect-data`, `--plan-only`, or rendering when a
fresh clone feels uncertain. Use `collect_first_use_feedback.sh` after a render
when you already have `render_report.md` or `render_report.json`.

The doctor is not a release gate. Maintainers should still run
`./scripts/release_check.sh` before tagging or merging behavior changes.
