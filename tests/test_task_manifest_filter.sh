#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_JSON="$(mktemp)"
TMP_MD="$(mktemp)"

python3 "$ROOT_DIR/scripts/build_task_manifest.py" \
  --json-out "$TMP_JSON" \
  --markdown-out "$TMP_MD" \
  --scheme line_trend

python3 - "$TMP_JSON" <<'PY'
import json
import sys
from pathlib import Path

manifest = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
tasks = manifest["tasks"]

assert manifest["task_count"] == 10
assert manifest["filters"] == {"scheme": "line_trend", "lane": ""}
assert {task["scheme"] for task in tasks} == {"line_trend"}
assert tasks[0]["id"] == "TASK-001-line_trend-catalog"
assert tasks[-1]["id"] == "TASK-010-line_trend-safety"
PY

grep -q "Active filters: scheme=line_trend" "$TMP_MD"
grep -q "TASK-010-line_trend-safety" "$TMP_MD"

python3 "$ROOT_DIR/scripts/build_task_manifest.py" \
  --json-out "$TMP_JSON" \
  --markdown-out "$TMP_MD" \
  --lane safety

python3 - "$TMP_JSON" <<'PY'
import json
import sys
from pathlib import Path

manifest = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
tasks = manifest["tasks"]

assert manifest["task_count"] == 50
assert manifest["filters"] == {"scheme": "", "lane": "safety"}
assert {task["lane"] for task in tasks} == {"safety"}
assert tasks[0]["id"] == "TASK-010-line_trend-safety"
assert tasks[-1]["id"] == "TASK-500-annotated_callout-safety"
PY

grep -q "Active filters: lane=safety" "$TMP_MD"
grep -q "TASK-500-annotated_callout-safety" "$TMP_MD"

rm -f "$TMP_JSON" "$TMP_MD"

echo "task manifest filter test passed."
