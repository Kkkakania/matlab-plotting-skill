#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT_DIR/mfigci.yml"
WORKFLOW="$ROOT_DIR/.github/workflows/quality.yml"
GITIGNORE="$ROOT_DIR/.gitignore"

if [[ ! -s "$CONFIG" ]]; then
  echo "missing mfigci.yml dogfooding config" >&2
  exit 1
fi

grep -q "name: matlab-plotting-skill" "$CONFIG"
grep -q "matlab-figures" "$CONFIG"
grep -q 'path: "docs/gallery"' "$CONFIG"
grep -q 'fail_on_warnings: false' "$CONFIG"
grep -q 'enabled: false' "$CONFIG"
grep -q 'scripts/check_privacy.sh' "$CONFIG"
grep -q 'scripts/collect_first_use_feedback.sh' "$CONFIG"
grep -q '"line_trend.png"' "$CONFIG"
grep -q '"density_scatter.png"' "$CONFIG"
grep -q '"segmented_line.png"' "$CONFIG"
grep -q '"stacked_time_series.png"' "$CONFIG"

grep -q "mfigci-report.md" "$GITIGNORE"
grep -q ".mfigci-results.json" "$GITIGNORE"
grep -q "mfigci-evidence.md" "$GITIGNORE"

grep -q "pip install git+https://github.com/Kkkakania/matlab-figure-ci.git@v2.5.0" "$WORKFLOW"
grep -q "mfigci rules --config mfigci.yml" "$WORKFLOW"
grep -q "mfigci check --config mfigci.yml --report mfigci-report.md" "$WORKFLOW"
grep -q "name: mfigci-report" "$WORKFLOW"
grep -q ".mfigci-results.json" "$WORKFLOW"
grep -q "include-hidden-files: true" "$WORKFLOW"

grep -q "mfigci check --config mfigci.yml --report mfigci-report.md" "$ROOT_DIR/README.md"
grep -q "mfigci check --config mfigci.yml --report mfigci-report.md" "$ROOT_DIR/README.zh-CN.md"
grep -q "matlab-figure-ci reviews exported gallery artifacts" "$ROOT_DIR/docs/ecosystem-status.md"
grep -q "matlab-figure-ci 会检查导出的 gallery 产物" "$ROOT_DIR/README.zh-CN.md"

echo "mfigci dogfooding config test passed."
