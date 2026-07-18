# OpenAI Build Week 2026

This page separates the pre-existing project from the work completed during
the OpenAI Build Week submission period.

## Before July 13, 2026

The repository already read CSV, Excel, and MAT data, inferred a basic schema,
ranked 51 MATLAB plotting schemes, rendered one selected figure, exported
PNG/SVG/PDF, and wrote a render report. It also included gallery, privacy,
provenance, installer, and release checks.

Those capabilities are useful foundations, but they are not presented as Build
Week work.

## Build Week Additions

Development starts from remote commit `1f82b1b`, with implementation on the
`build-week-2026` branch after the submission period opened.

- Render two to five ranked candidates from the same data and goal.
- Write a path-safe `candidate_manifest.json` for Codex visual review.
- Ask GPT-5.6 in Codex to score claim support, legibility, accessibility,
  honesty, and reproducibility.
- Validate the review against a strict JSON contract and repair allowlist.
- Apply only controlled MATLAB figure-object repairs; model-authored code is
  never executed.
- Export the final figure, a before/after comparison, and Markdown/JSON review
  evidence.
- Provide a one-command synthetic-data demo and a checked review fixture.
- Exercise the model-to-MATLAB boundary with one valid control and 14
  adversarial mutations that must fail closed.

The key product change is not "more chart types." It is a reviewable loop that
can reject a highly ranked but semantically misleading chart before it reaches
a paper, report, or presentation.

## Reproduce The Demo

```bash
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab \
  ./scripts/run_review_demo.sh --out /tmp/matlab-plot-review-demo
```

Review `candidate_manifest.json`, `before_after.png`, and
`review_evidence.md/json` in the output directory.

## Reproduce The Adversarial Benchmark

```bash
./scripts/run_review_contract_benchmark.py \
  --validator scripts/validate_plot_review.py \
  --manifest examples/review/multi_series_manifest.json \
  --review examples/review/multi_series_review.json \
  --out /tmp/plot-review-contract-benchmark
```

The checked result is
[`15/15`](build-week/review-contract-benchmark/review_contract_benchmark.md):
the valid control is accepted and all 14 adversarial outputs are rejected. The
benchmark covers unknown executable actions, injected values, candidate and
model spoofing, extra or missing fields, invalid score types and ranges,
duplicate actions, contradictory verdicts, oversized findings, and malformed
JSON. Its JSON report contains no local absolute paths.

All bundled inputs are synthetic. No private archive, paper figure, local path,
or unpublished research data is required or included.
