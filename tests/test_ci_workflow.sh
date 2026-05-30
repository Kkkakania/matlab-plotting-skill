#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKFLOW="$ROOT_DIR/.github/workflows/quality.yml"

if [[ ! -s "$WORKFLOW" ]]; then
  echo "missing quality workflow" >&2
  exit 1
fi

grep -q "scripts/build_automation_manifest.py" "$WORKFLOW"
grep -q "tests/test_scheme_info.sh" "$WORKFLOW"
grep -q "tests/test_automation_manifest.sh" "$WORKFLOW"
grep -q "tests/test_ci_workflow.sh" "$WORKFLOW"
grep -q "tests/test_task_manifest.sh" "$WORKFLOW"
grep -q "tests/test_task_manifest_filter.sh" "$WORKFLOW"
grep -q "automation-manifest.json" "$WORKFLOW"
grep -q "task-manifest.json" "$WORKFLOW"
grep -q "task-board.md" "$WORKFLOW"
grep -q "actions/upload-artifact" "$WORKFLOW"

echo "CI workflow test passed."
