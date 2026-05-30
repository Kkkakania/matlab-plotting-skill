#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_JSON="$(mktemp)"
TMP_MD="$(mktemp)"

python3 "$ROOT_DIR/scripts/build_task_manifest.py" --json-out "$TMP_JSON" --markdown-out "$TMP_MD"

python3 - "$TMP_JSON" <<'PY'
import json
import sys
from collections import Counter
from pathlib import Path

manifest = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
tasks = manifest["tasks"]
ids = [task["id"] for task in tasks]
schemes = [task["scheme"] for task in tasks]
lanes = {task["lane"] for task in tasks}
per_scheme = Counter(schemes)

assert manifest["scheme_count"] == 50
assert manifest["lane_count"] == 10
assert manifest["task_count"] == 500
assert len(tasks) == 500
assert len(ids) == len(set(ids))
assert ids[0] == "TASK-001-line_trend-catalog"
assert ids[-1] == "TASK-500-annotated_callout-safety"
assert set(per_scheme.values()) == {10}
assert lanes == {
    "catalog",
    "data-contract",
    "demo-data",
    "selection-rule",
    "explicit-cli",
    "png-render",
    "vector-render",
    "report",
    "gallery",
    "safety",
}
assert all(task["acceptance"] for task in tasks)
assert all(task["command_hint"] for task in tasks)
assert all(task["status"] == "planned" for task in tasks)
PY

grep -q "TASK-001-line_trend-catalog" "$TMP_MD"
grep -q "TASK-500-annotated_callout-safety" "$TMP_MD"
grep -q "Total tasks: 500" "$TMP_MD"

rm -f "$TMP_JSON" "$TMP_MD"

echo "task manifest test passed."
