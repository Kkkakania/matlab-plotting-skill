# Roadmap

This roadmap tracks the current public shape of `matlab-plotting-skill`.
It should agree with README, CHANGELOG, scheme readiness, and the maintenance
cadence.

## Current State

- Current public line: `v0.1.x`.
- Maturity: early public project; the skill is usable for gallery-backed
  schemes, while cataloged-only schemes remain design targets.
- Catalog size: 50 plotting schemes.
- Stable first-use path: bundled synthetic data, plan-only selection,
  gallery-backed rendering, Markdown/JSON reports, privacy checks, provenance
  checks, and local MATLAB release gates.
- Public workflow: shell, Python, documentation, task-board, privacy,
  provenance, and wrapper checks on hosted Linux runners.
- MATLAB rendering is intentionally a local release-gate step because hosted
  public CI runners do not include MATLAB by default.

## Completed Foundation

Delivered:

- Agent-facing skill metadata and example prompts.
- CSV, Excel, and MAT data-entry workflows.
- Metadata-only commands that work before MATLAB is configured.
- Gallery-backed examples for the most stable schemes.
- First-render walkthrough with redaction guidance.
- 500-task scheme backlog for planned coverage without turning every row into
  a release.
- Maintenance cadence guidance that slows down tagging after the bootstrap
  line.

## Next Candidates

Candidates should be batched into normal maintenance releases instead of tagged
one row at a time:

- Add one gallery-backed scheme only when it has synthetic data, selection
  guidance, report coverage, preview output, and safety checks.
- Improve first-use failure messages around MATLAB executable discovery and
  data-loading errors.
- Add more real-world-style synthetic CSV/Excel examples without copying user
  or third-party datasets.
- Tighten scheme-readiness reporting when a planned scheme becomes
  gallery-backed.
- Collect first-use feedback through GitHub issues with private details
  redacted.

## Non-Goals

- No artificial stars, forks, usage claims, or download claims.
- No copied templates, raw private datasets, `.fig`, `.mat`, `.p`, document
  packs, or local-path dumps.
- No release tag for every checklist row.
- No claim that cataloged-only schemes are as stable as gallery-backed schemes.

