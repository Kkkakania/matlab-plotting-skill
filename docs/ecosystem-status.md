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

## Handoff Contract

This repository hands off render evidence, not source material. Handoff means
artifacts and commands that a maintainer can inspect without seeing the user's
private data.

| Producer | Producer artifact | Next consumer | What to review |
|---|---|---|---|
| `matlab-plotting-skill` | `render_report.md and render_report.json`, selected scheme, exported PNG/SVG | First-use feedback issue or maintainer triage | Data-shape summary, selected scheme, alternatives, warnings, output formats, and redaction status |
| `matlab-figure-ci` | `mfigci-report.md and .mfigci-results.json` | Maintainer review before sharing outputs | Gallery presence, risky files, provenance warnings, privacy errors, and relative-path reporting |
| `matlab-scientific-figures` | clean-room gallery examples and reusable APIs | Future template request, only after review | Whether the chart task deserves a public synthetic example and reusable MATLAB function |

Do not move private datasets, local absolute paths, screenshots, copied
templates, watermarked images, binary MATLAB files, or third-party helper code
from a user session into a public issue or gallery request. If a render report
suggests a useful missing chart type, rewrite it as a small public task with
synthetic data and a reproducible command.

## Feedback Channels

- First-render feedback for this skill:
  [`matlab-plotting-skill#11`](https://github.com/Kkkakania/matlab-plotting-skill/issues/11).
- Gallery/API feedback for reusable MATLAB functions:
  [`matlab-scientific-figures#9`](https://github.com/Kkkakania/matlab-scientific-figures/issues/9).
- CI/adoption feedback for figure repositories:
  [`matlab-figure-ci#1`](https://github.com/Kkkakania/matlab-figure-ci/issues/1).

Good feedback includes OS, MATLAB version, commit, command sequence, the
`first_use_doctor.md/json` summary when setup is uncertain, selected scheme,
report summary, output formats, and redacted failure output.

The most useful first-use path is the paired walkthrough:
[`docs/first-render-walkthrough.md`](first-render-walkthrough.md) and
[`docs/first-render-walkthrough.zh-CN.md`](first-render-walkthrough.zh-CN.md).
They start with the pre-render doctor in
[`docs/first-use-doctor.md`](first-use-doctor.md), then separate metadata
checks, MATLAB CLI checks, plan-only inspection, actual rendering, and feedback
collection so contributors can report one narrow failure instead of a vague "the
skill does not work" result.

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
- include the doctor report summary when the change touches setup, checkout, or
  MATLAB discovery behavior;
- include the selected scheme, command sequence, and redacted report summary
  when a first-use test is relevant;
- link `docs/private-data-handling.md` and `docs/local-resource-intake.md` when
  explaining why private data or local templates were not published;
- say "agent-facing layer for the MATLAB plotting ecosystem" rather than
  claiming independent adoption before public usage evidence exists.

Use a review packet when the audience is a maintainer or contributor. Include
the current commit, the `Quality` workflow run URL, `./scripts/release_check.sh`,
the issue or PR that motivated the change, and the exact files that changed.
When the change touches rendering behavior, include `render_report.md/json`,
the selected scheme, warnings, and redaction status.

Use an application packet when the audience is outside the issue queue. Keep it
short: public repository link, current commit or release line, workflow run URL,
first-use feedback link, `mfigci-report.md` if exported figures were checked,
and one redacted issue or PR link. This is not an approval argument. It is a
record of what was checked and where the boundary sits.

If exported figures are checked with `matlab-figure-ci`, generate the shared
evidence draft from its working results:

```bash
mfigci report --style evidence --output mfigci-evidence.md
```

This report style is available on matlab-figure-ci main after v2.5.0. Treat it
as a main-branch convenience until a later `matlab-figure-ci` release is pinned
by downstream workflows.

Do not include private datasets, local screenshots, raw MATLAB paths,
unreviewed local prototype outputs, or claims that an external benefit program
will approve the project.
