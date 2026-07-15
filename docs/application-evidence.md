# Application Evidence

Snapshot date: 2026-07-15.

This note is for reviewers who want to understand what is public and
checkable in `matlab-plotting-skill`. It is not a promise of Claude for Open
Source eligibility, approval, or subscription access.

## Repository to cite

Use this repository as companion skill evidence for the MATLAB plotting
ecosystem:

<https://github.com/Kkkakania/matlab-plotting-skill>

Do not present it as the main Claude for Open Source application repository.
Use `matlab-scientific-figures` as the main repository when a form asks for one
GitHub repository, then cite this skill as the agent-facing workflow layer.

Related repositories:

- <https://github.com/Kkkakania/matlab-scientific-figures>
- <https://github.com/Kkkakania/matlab-figure-ci>
- <https://github.com/Kkkakania/python-plotting-skill>

## Public evidence

| Area | Evidence |
|---|---|
| MATLAB plotting skill | `skills/matlab-plotting-skill/SKILL.md`, bundled MATLAB helpers, 51-scheme catalog, gallery previews, and first-render walkthrough |
| Scientific diagram skill | `skills/scientific-diagram-skill/SKILL.md`, draw.io workflow references, checked `research-method-flow.drawio`, checked `research-method-flow.svg`, provenance note, and `tests/test_scientific_diagram_examples.sh` |
| CI | Commit `8756f77`; `Quality` run `29073837604`, green and annotation-free at the 2026-07-15 snapshot |
| Public release | [`v0.1.100`](https://github.com/Kkkakania/matlab-plotting-skill/releases/tag/v0.1.100), published 2026-05-30 |
| Local release gate | `./scripts/release_check.sh`; passed on 2026-07-15 for 51 schemes, 1122 automation checks, 510 backlog tasks, gallery/provenance/privacy checks, installer tests, and the bundled diagram skill |
| Figure QA dogfooding | `mfigci check --config mfigci.yml --report mfigci-report.md` |
| Maintainer workflow | issue-triage workflow, first-use feedback path, installer checks, docs voice check, and release cadence notes |
| Private data boundary | `docs/private-data-handling.md` and `docs/local-resource-intake.md` |
| Ecosystem handoff | `docs/ecosystem-status.md` |

## What a Claude subscription would help with

- Review skill changes for missing references, install drift, and unclear task boundaries.
- Triage first-use reports into setup, MATLAB discovery, data-shape, rendering, and documentation issues.
- Draft release notes from merged commits for maintainer editing.
- Summarize `mfigci` reports and render reports without exposing private data.
- Investigate CI failures and propose small fixes that preserve the clean-room boundary.
- Keep English and Chinese documentation aligned without making the Chinese version sound like a direct translation.

## What not to claim

Do not claim broad adoption, download volume, external endorsement, company
approval, or guaranteed benefit-program results. The current honest claim is
that this is an early public skill repository with reproducible checks, checked
diagram examples, gallery previews, and a companion CI tool.

Do not cite private local folders, raw datasets, screenshots, unreviewed MATLAB
archives, or non-public conversations. Use public commits, workflow runs,
checked examples, issue links, and redacted reports.

## Short draft

`matlab-plotting-skill` is an agent-facing workflow for MATLAB scientific
plotting and research diagrams. It helps maintainers and coding agents inspect
data, choose chart patterns, render through MATLAB CLI, and produce redacted
review reports. The ecosystem is early, but it already has
clean-room gallery evidence, provenance checks, issue/PR templates, and a
companion figure-QA tool.
