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
grep -q "Catalog entry names the scheme" "$BOARD"
grep -q "No private paths, forbidden files" "$BOARD"

echo "committed 500-task board test passed."
