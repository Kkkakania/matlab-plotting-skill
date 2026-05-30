#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOARD="$ROOT_DIR/docs/500-task-board.md"

if [[ ! -s "$BOARD" ]]; then
  echo "missing committed 500-task board" >&2
  exit 1
fi

task_count="$(grep -Ec '^\| `TASK-[0-9]{3}-' "$BOARD")"
if [[ "$task_count" -ne 500 ]]; then
  echo "expected 500 committed task rows, found $task_count" >&2
  exit 1
fi

grep -q "Total tasks: 500" "$BOARD"
grep -q "TASK-001-line_trend-catalog" "$BOARD"
grep -q "TASK-500-annotated_callout-safety" "$BOARD"
grep -q "Command Hint" "$BOARD"
grep -q "| done | 3 |" "$BOARD"
grep -q '| `TASK-001-line_trend-catalog` | `line_trend` | catalog | Clarify catalog entry | Catalog entry names the scheme, family, best use, and palette. | `./scripts/render_with_matlab.sh --scheme-info line_trend` | done |' "$BOARD"
grep -q '| `TASK-002-line_trend-data-contract` | `line_trend` | data-contract | Document input shape | Data expectations are clear enough to choose the scheme without private examples. | `grep -n "line_trend" skills/matlab-plotting-skill/references/scheme-catalog.md docs/chart-selection-guide.md` | done |' "$BOARD"
grep -q '| `TASK-003-line_trend-demo-data` | `line_trend` | demo-data | Provide synthetic demo data | Synthetic data can exercise the scheme with no private files. | `MATLAB_BIN=/path/to/matlab ./scripts/render_with_matlab.sh --smoke-test --formats png` | done |' "$BOARD"
grep -q "Catalog entry names the scheme" "$BOARD"
grep -q "No private paths, forbidden files" "$BOARD"

echo "committed 500-task board test passed."
