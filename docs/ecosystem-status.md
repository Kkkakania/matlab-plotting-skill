# Ecosystem Status

`matlab-plotting-skill` is the agent-facing layer of a small MATLAB plotting
ecosystem. It should stay focused on turning user data and goals into
reproducible MATLAB rendering commands.

## Repository Roles

| Repository | Role |
|---|---|
| [`matlab-scientific-figures`](https://github.com/Kkkakania/matlab-scientific-figures) | Clean-room MATLAB gallery, reusable plotting APIs, themes, and export helpers |
| [`matlab-figure-ci`](https://github.com/Kkkakania/matlab-figure-ci) | CI/CLI checks for gallery outputs, provenance, privacy, risky files, and release readiness |
| [`matlab-plotting-skill`](https://github.com/Kkkakania/matlab-plotting-skill) | Data inspection, scheme selection, MATLAB CLI rendering, and render reports for agent workflows |

## Feedback Channels

- First-render feedback for this skill:
  [`matlab-plotting-skill#11`](https://github.com/Kkkakania/matlab-plotting-skill/issues/11).
- Gallery/API feedback for reusable MATLAB functions:
  [`matlab-scientific-figures#9`](https://github.com/Kkkakania/matlab-scientific-figures/issues/9).
- CI/adoption feedback for figure repositories:
  [`matlab-figure-ci#1`](https://github.com/Kkkakania/matlab-figure-ci/issues/1).

Good feedback includes OS, MATLAB version, commit, command sequence, selected
scheme, report summary, output formats, and redacted failure output.

The most useful first-use path is the paired walkthrough:
[`docs/first-render-walkthrough.md`](first-render-walkthrough.md) and
[`docs/first-render-walkthrough.zh-CN.md`](first-render-walkthrough.zh-CN.md).
They separate metadata checks, MATLAB CLI checks, plan-only inspection, actual
rendering, and feedback collection so contributors can report one narrow failure
instead of a vague "the skill does not work" result.

## Coordination Snapshot

The wider ecosystem is tracked through small, verifiable maintenance checks
rather than broad adoption claims.

- `matlab-scientific-figures` maintains the gallery-facing coordination issue
  and temporary triage helpers while the public GitHub Project board is pending.
  The current Project-board task is
  [`matlab-scientific-figures#31`](https://github.com/Kkkakania/matlab-scientific-figures/issues/31).
- Its maintenance docs include helpers for visible fork intake and open issue/PR triage.
  These helpers are status snapshots, not a replacement for a real public
  Project board once the account has the required GitHub Projects scopes.
- `matlab-figure-ci` records downstream adoption status for
  `matlab-scientific-figures`, including gallery checks, provenance/privacy
  checks, and the current no-render CI boundary.
- `matlab-scientific-figures` currently pins its figure-quality workflow to
  `matlab-figure-ci` `v2.5.0`, so the gallery repository is testing the same
  checker release described by the companion adoption report.
- This repository should keep its own issue queue small and focused on first-use
  rendering, installer behavior, scheme selection, and report clarity.

## Current Boundaries

- The skill uses bundled clean-room renderers and synthetic examples.
- It does not include private datasets, raw article figures, copied third-party
  templates, encrypted MATLAB files, or local source archives.
- Public CI checks shell scripts, docs, manifests, and static safety rules. It
  does not prove that MATLAB rendered figures on GitHub-hosted runners.
- The task board is a long-horizon backlog, not a promise to tag a release for
  every row.

## Claim Boundary

This repository is early and should be described through reproducible evidence:
commands, docs, tests, gallery previews, issue links, and CI results. Do not
claim broad adoption, download volume, guaranteed program eligibility, or
approval by any external benefit program.

## Maintainer Evidence Packet

When using this repository as evidence of real maintenance, keep the packet
small and reproducible:

- link the current commit, `Quality` workflow result, and `./scripts/release_check.sh`
  command used for local validation;
- link the first-render feedback issue and any issue that motivated the change;
- include the selected scheme, command sequence, and redacted report summary
  when a first-use test is relevant;
- link `docs/private-data-handling.md` and `docs/local-resource-intake.md` when
  explaining why private data or local templates were not published;
- say "agent-facing layer for the MATLAB plotting ecosystem" rather than
  claiming independent adoption before public usage evidence exists.

Do not include private datasets, local screenshots, raw MATLAB paths,
unreviewed local prototype outputs, or claims that an external benefit program
will approve the project.
