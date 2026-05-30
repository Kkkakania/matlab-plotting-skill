#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROMPTS="$ROOT_DIR/skills/matlab-plotting-skill/references/example-prompts.md"

grep -q -- "--inspect-data" "$PROMPTS"
grep -q -- "--plan-only" "$PROMPTS"
grep -q "before rendering" "$PROMPTS"

echo "example prompts test passed."
