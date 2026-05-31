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
