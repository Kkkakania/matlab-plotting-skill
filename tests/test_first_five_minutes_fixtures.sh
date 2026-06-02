#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC="$ROOT_DIR/docs/first-five-minutes.md"
README="$ROOT_DIR/README.md"

grep -q "examples/data/time_series.csv" "$DOC"
grep -q "examples/data/multi_series.csv" "$DOC"
grep -q "examples/data/confidence_band.csv" "$DOC"
grep -q "examples/data/method_scores.csv" "$DOC"
grep -q "Use More Bundled Fixtures" "$DOC"
grep -q "Fixture" "$DOC"
grep -q "Expected direction" "$DOC"
grep -q -- "--list-schemes --status" "$DOC"
grep -q "docs/first-five-minutes.md" "$README"
grep -q "multi_series.csv" "$README"

echo "first five minutes fixtures test passed."
