#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_MD="$ROOT_DIR/skills/matlab-plotting-skill/SKILL.md"

grep -q -- "--plan-only" "$SKILL_MD"
grep -q "preview" "$SKILL_MD"
grep -q "mpPlan" "$SKILL_MD"

echo "skill plan-only guidance test passed."
