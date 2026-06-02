#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WITH_MATLAB=0
MATLAB_BIN="${MATLAB_BIN:-matlab}"
export PYTHONDONTWRITEBYTECODE=1

usage() {
  cat <<'USAGE'
Usage:
  release_check.sh [--with-matlab]

Runs the release gate used before tagging a version.

Default checks:
  - shell syntax
  - Python syntax
  - shell-based tests
  - validate_skill.py
  - check_forbidden_files.sh
  - check_privacy.sh
  - git diff whitespace check

With --with-matlab:
  - MATLAB unit tests
  - MATLAB Code Analyzer checks
  - renderer visual fixtures

Environment:
  MATLAB_BIN=/path/to/matlab
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-matlab)
      WITH_MATLAB=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

cd "$ROOT_DIR"

echo "== Syntax checks =="
python3 -m py_compile scripts/build_gallery_index.py scripts/build_automation_manifest.py scripts/build_task_manifest.py
find scripts -type d -name '__pycache__' -prune -exec rm -rf {} +
bash -n scripts/*.sh
bash -n skills/matlab-plotting-skill/scripts/*.sh
bash -n tests/*.sh

echo "== Shell tests =="
tests/test_install_script.sh
tests/test_check_gallery_outputs.sh
tests/test_check_privacy.sh
tests/test_list_schemes.sh
tests/test_list_schemes_json.sh
tests/test_first_five_minutes_fixtures.sh
tests/test_scheme_info.sh
tests/test_automation_manifest.sh
tests/test_ci_workflow.sh
tests/test_task_manifest.sh
tests/test_task_manifest_filter.sh
tests/test_task_manifest_status.sh
tests/test_scheme_readiness.sh
tests/test_scheme_readiness_fresh.sh
tests/test_repo_docs.sh
tests/test_github_templates.sh
tests/test_matlab_check.sh
tests/test_docs_quality_checklist.sh
tests/test_docs_chart_selection.sh
tests/test_line_trend_data_contract.sh
tests/test_multi_line_comparison_catalog.sh
tests/test_multi_line_comparison_data_contract.sh
tests/test_confidence_band_catalog.sh
tests/test_zoomed_inset_line_catalog.sh
tests/test_positive_negative_area_catalog.sh
tests/test_segmented_line_catalog.sh
tests/test_scatter_relationship_catalog.sh
tests/test_grouped_scatter_catalog.sh
tests/test_density_scatter_catalog.sh
tests/test_contour_scatter_catalog.sh
tests/test_regression_scatter_catalog.sh
tests/test_bubble_scatter_catalog.sh
tests/test_confidence_band_data_contract.sh
tests/test_zoomed_inset_line_data_contract.sh
tests/test_positive_negative_area_data_contract.sh
tests/test_segmented_line_data_contract.sh
tests/test_scatter_relationship_data_contract.sh
tests/test_grouped_scatter_data_contract.sh
tests/test_density_scatter_data_contract.sh
tests/test_contour_scatter_data_contract.sh
tests/test_regression_scatter_data_contract.sh
tests/test_bubble_scatter_data_contract.sh
tests/test_build_gallery_index.sh
tests/test_line_trend_gallery.sh
tests/test_multi_line_comparison_gallery.sh
tests/test_confidence_band_gallery.sh
tests/test_zoomed_inset_line_gallery.sh
tests/test_positive_negative_area_gallery.sh
tests/test_segmented_line_gallery.sh
tests/test_scatter_relationship_gallery.sh
tests/test_grouped_scatter_gallery.sh
tests/test_density_scatter_gallery.sh
tests/test_contour_scatter_gallery.sh
tests/test_regression_scatter_gallery.sh
tests/test_multi_line_comparison_safety.sh
tests/test_confidence_band_safety.sh
tests/test_zoomed_inset_line_safety.sh
tests/test_positive_negative_area_safety.sh
tests/test_segmented_line_safety.sh
tests/test_scatter_relationship_safety.sh
tests/test_grouped_scatter_safety.sh
tests/test_density_scatter_safety.sh
tests/test_contour_scatter_safety.sh
tests/test_regression_scatter_safety.sh
tests/test_gallery_provenance.sh
tests/test_docs_palette_accessibility.sh
tests/test_readme_gallery_assets.sh
tests/test_docs_500_task_board.sh
tests/test_visual_fixtures_script.sh
tests/test_release_check_script.sh
tests/test_skill_plan_only_guidance.sh
tests/test_example_prompts.sh

echo "== Repository checks =="
find . -type d -name '__pycache__' -not -path './.git/*' -prune -exec rm -rf {} +
python3 scripts/validate_skill.py
scripts/check_forbidden_files.sh
scripts/check_privacy.sh
git diff --check

if [[ "$WITH_MATLAB" -eq 1 ]]; then
  echo "== MATLAB checks =="
  "$MATLAB_BIN" -batch "addpath(genpath('skills/matlab-plotting-skill/assets/matlab')); results = [runtests('tests/test_mp_core.m'), runtests('tests/test_mp_visual_fixtures.m')]; assertSuccess(results); issues = []; files = dir('skills/matlab-plotting-skill/assets/matlab/*.m'); for k = 1:numel(files), issues = [issues; checkcode(fullfile(files(k).folder, files(k).name), '-id')]; end; assert(isempty(issues));"
  "$ROOT_DIR/scripts/run_visual_fixtures.sh" --out "${TMPDIR:-/tmp}/mp-release-visual-fixtures"
fi

echo "Release check passed."
