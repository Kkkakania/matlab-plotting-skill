# Maintenance Cadence

This project favors steady maintenance over frequent version bumps.

## Normal Rhythm

- Review new issues and first-use feedback weekly when there is activity.
- Batch related task-board rows into one maintenance change.
- Keep small documentation fixes in `Unreleased` until there is a user-visible
  reason to tag.
- Run the public quality workflow on every push and pull request.
- Run the MATLAB-backed release gate before tagging rendering changes.

## When To Tag

Tag a release when users get one of these:

- a new gallery-backed scheme
- a new command or report field
- a renderer bug fix that changes output behavior
- a compatibility fix for a MATLAB release or operating system
- a documentation set that materially improves first-use success

Do not tag a release only because one task-board row moved to `done`.

## Suggested Release Shapes

- Patch release: documentation fixes, CI checks, small policy or template fixes.
- Minor release: new scheme support, new CLI behavior, new report output, or a
  meaningful first-use workflow improvement.
- Major release: incompatible CLI, data contract, or report schema changes.

## Before A Release

1. Update `CHANGELOG.md` from `Unreleased`.
2. Confirm `docs/scheme-readiness.md` matches `docs/task-status.json`.
3. Run `./scripts/release_check.sh`.
4. If rendering changed, run `./scripts/release_check.sh --with-matlab`.
5. Inspect the gallery outputs that changed.
