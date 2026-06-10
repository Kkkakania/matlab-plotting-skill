# Long-Horizon Scheme Backlog

This roadmap is generated from the public 50-scheme catalog:

```bash
python3 scripts/build_task_manifest.py \
  --json-out task-manifest.json \
  --markdown-out task-board.md
```

The task model is deliberately exact, but it is a backlog, not a release
cadence. Maintainers should batch related tasks into normal releases, keep
small documentation fixes in `Unreleased`, and avoid publishing a tag for every
row.

Current scope:

- 50 plotting schemes.
- 10 task lanes for each scheme.
- 500 planned tasks total.

The next catalog refresh should be driven by task gaps, not by copying local
examples. Recent local review points toward signal-processing plots, electrical
diagnostic plots, model-evaluation views, distribution comparisons, directional
plots, and a small number of 3D views. Those ideas belong in the backlog only
after they are rewritten with synthetic data and new MATLAB code.

A larger private prototype library first covered 216 plotting ideas.
The newer private index reports 239 template ideas plus 60 palette families.
Treat that as a map, not as an import queue.
The first public follow-up should be a small batch of schemes that agents can
explain well, for example impedance, power/energy, workflow panels,
calibration, PSD, confusion-matrix, or residual-history plots.

The generated JSON is the source of truth for planning coverage. The Markdown
board is a readable view for maintainers. It includes family and lane summaries
before the full task table, so maintainers can review coverage without scanning
all 500 rows. The repository also commits a full generated board at
`docs/500-task-board.md`.

For focused work, filter the generated board:

```bash
python3 scripts/build_task_manifest.py \
  --json-out line-trend-tasks.json \
  --markdown-out line-trend-tasks.md \
  --scheme line_trend

python3 scripts/build_task_manifest.py \
  --json-out safety-tasks.json \
  --markdown-out safety-tasks.md \
  --lane safety
```

Unknown scheme or lane filters fail with a non-zero exit code so misspellings
do not quietly produce an empty board.

Task progress is tracked through `docs/task-status.json`. Regenerate the
committed board with:

```bash
python3 scripts/build_task_manifest.py \
  --json-out /tmp/task-manifest.json \
  --markdown-out docs/500-task-board.md \
  --status-overrides docs/task-status.json
```

## Task Lanes

Every scheme receives these same ten lanes:

1. `catalog`: clarify scheme purpose, family, and palette.
2. `data-contract`: document the expected input shape.
3. `demo-data`: provide synthetic demo coverage.
4. `selection-rule`: make automatic selection explainable.
5. `explicit-cli`: support direct `--scheme` usage.
6. `png-render`: support PNG output for previews.
7. `vector-render`: support SVG/PDF output for papers and reports.
8. `report`: explain the result in Markdown and JSON reports.
9. `gallery`: make the rendered example visible in generated galleries.
10. `safety`: pass privacy, provenance, and forbidden-file checks.

## Task IDs

Task IDs are stable and ordered:

```text
TASK-001-line_trend-catalog
TASK-002-line_trend-data-contract
...
TASK-500-annotated_callout-safety
```

## CI

GitHub Actions generates and uploads:

- `task-manifest.json`
- `task-board.md`

`tests/test_task_manifest.sh` fails if the plan is not exactly 500 tasks, if
any task ID is duplicated, or if any scheme does not receive exactly 10 tasks.
It also checks that the generated summaries add up to exactly 500 tasks.
