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
grep -q "tests/test_task_manifest_status.sh" "$WORKFLOW"
grep -q "tests/test_docs_500_task_board.sh" "$WORKFLOW"
grep -q "tests/test_line_trend_data_contract.sh" "$WORKFLOW"
grep -q "tests/test_multi_line_comparison_catalog.sh" "$WORKFLOW"
grep -q "tests/test_multi_line_comparison_data_contract.sh" "$WORKFLOW"
grep -q "tests/test_confidence_band_catalog.sh" "$WORKFLOW"
grep -q "tests/test_zoomed_inset_line_catalog.sh" "$WORKFLOW"
grep -q "tests/test_positive_negative_area_catalog.sh" "$WORKFLOW"
grep -q "tests/test_segmented_line_catalog.sh" "$WORKFLOW"
grep -q "tests/test_confidence_band_data_contract.sh" "$WORKFLOW"
grep -q "tests/test_zoomed_inset_line_data_contract.sh" "$WORKFLOW"
grep -q "tests/test_positive_negative_area_data_contract.sh" "$WORKFLOW"
grep -q "tests/test_line_trend_gallery.sh" "$WORKFLOW"
grep -q "tests/test_multi_line_comparison_gallery.sh" "$WORKFLOW"
grep -q "tests/test_confidence_band_gallery.sh" "$WORKFLOW"
grep -q "tests/test_zoomed_inset_line_gallery.sh" "$WORKFLOW"
grep -q "tests/test_positive_negative_area_gallery.sh" "$WORKFLOW"
grep -q "tests/test_multi_line_comparison_safety.sh" "$WORKFLOW"
grep -q "tests/test_confidence_band_safety.sh" "$WORKFLOW"
grep -q "tests/test_zoomed_inset_line_safety.sh" "$WORKFLOW"
grep -q "tests/test_positive_negative_area_safety.sh" "$WORKFLOW"
grep -q "tests/test_gallery_provenance.sh" "$WORKFLOW"
grep -q "automation-manifest.json" "$WORKFLOW"
grep -q "task-manifest.json" "$WORKFLOW"
grep -q "task-board.md" "$WORKFLOW"
grep -q "docs/task-status.json" "$WORKFLOW"
grep -q "actions/upload-artifact" "$WORKFLOW"

echo "CI workflow test passed."
