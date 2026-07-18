#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEMO="$ROOT_DIR/scripts/run_review_demo.sh"
SKILL="$ROOT_DIR/skills/matlab-plotting-skill/SKILL.md"
CONTRACT="$ROOT_DIR/skills/matlab-plotting-skill/references/review-contract.md"
FIXTURE="$ROOT_DIR/examples/review/multi_series_review.json"

for path in "$DEMO" "$CONTRACT" "$FIXTURE" "$ROOT_DIR/docs/build-week-2026.md"; do
  if [[ ! -s "$path" ]]; then
    echo "missing Build Week workflow file: $path" >&2
    exit 1
  fi
done

if [[ ! -x "$DEMO" ]]; then
  echo "review demo script must be executable" >&2
  exit 1
fi

"$DEMO" --help | grep -q -- "--out <directory>"
grep -q -- "--candidate-pack" "$SKILL"
grep -q -- "--finalize-review" "$SKILL"
grep -q -- "candidate_manifest.json" "$CONTRACT"
grep -q -- "Do not infer uncertainty bounds" "$CONTRACT"
grep -q -- "Before July 13, 2026" "$ROOT_DIR/docs/build-week-2026.md"
grep -q -- "Build Week additions" "$ROOT_DIR/README.md"

python3 "$ROOT_DIR/scripts/validate_plot_review.py" --review "$FIXTURE" \
  >"${TMPDIR:-/tmp}/matlab-plotting-demo-review.json"

echo "Build Week review workflow test passed."
