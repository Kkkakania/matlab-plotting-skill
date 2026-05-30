#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_JSON="$(mktemp)"
TMP_MD="$(mktemp)"
TMP_OVERRIDES="$(mktemp)"

printf '%s\n' '{' \
  '  "TASK-001-line_trend-catalog": "done",' \
  '  "TASK-010-line_trend-safety": "in_progress"' \
  '}' >"$TMP_OVERRIDES"

python3 "$ROOT_DIR/scripts/build_task_manifest.py" \
  --json-out "$TMP_JSON" \
  --markdown-out "$TMP_MD" \
  --scheme line_trend \
  --status-overrides "$TMP_OVERRIDES"

python3 - "$TMP_JSON" <<'PY'
import json
import sys
from pathlib import Path

manifest = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
status_by_id = {task["id"]: task["status"] for task in manifest["tasks"]}

assert manifest["status_counts"] == {"done": 1, "in_progress": 1, "planned": 8}
assert status_by_id["TASK-001-line_trend-catalog"] == "done"
assert status_by_id["TASK-010-line_trend-safety"] == "in_progress"
PY

grep -q "## Status Summary" "$TMP_MD"
grep -q "| done | 1 |" "$TMP_MD"
grep -q "| in_progress | 1 |" "$TMP_MD"

printf '%s\n' '{' \
  '  "TASK-001-line_trend-catalog": "nearly_done"' \
  '}' >"$TMP_OVERRIDES"

if python3 "$ROOT_DIR/scripts/build_task_manifest.py" \
  --json-out "$TMP_JSON" \
  --markdown-out "$TMP_MD" \
  --status-overrides "$TMP_OVERRIDES" >/tmp/mp-task-status.out 2>/tmp/mp-task-status.err; then
  echo "unknown task status should fail" >&2
  exit 1
fi

grep -q "Unknown task status: nearly_done" /tmp/mp-task-status.err

printf '%s\n' '{' \
  '  "TASK-999-not-real": "done"' \
  '}' >"$TMP_OVERRIDES"

if python3 "$ROOT_DIR/scripts/build_task_manifest.py" \
  --json-out "$TMP_JSON" \
  --markdown-out "$TMP_MD" \
  --status-overrides "$TMP_OVERRIDES" >/tmp/mp-task-status.out 2>/tmp/mp-task-status.err; then
  echo "unknown task override ID should fail" >&2
  exit 1
fi

grep -q "Unknown task override ID: TASK-999-not-real" /tmp/mp-task-status.err

rm -f "$TMP_JSON" "$TMP_MD" "$TMP_OVERRIDES"

echo "task manifest status test passed."
