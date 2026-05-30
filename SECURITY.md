# Security

This repository should not contain private data, local path dumps, raw research
datasets, encrypted MATLAB files, or copied article figures.

## Reporting Problems

Open a GitHub issue if you find:

- A path or identity leak in generated reports.
- A scanner miss in `scripts/check_privacy.sh`.
- A risky file type that should be blocked before release.
- A renderer that writes unexpected files outside the requested output folder.

If the report includes sensitive details, describe the pattern without posting
the sensitive value itself.

## Current Guardrails

- `scripts/check_forbidden_files.sh` blocks common private or binary artifacts.
- `scripts/check_privacy.sh` scans for local paths, author/copyright markers,
  emails, and related provenance risks.
- Render reports store file names rather than absolute local paths.

