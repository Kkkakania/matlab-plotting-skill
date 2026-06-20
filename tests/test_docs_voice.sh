#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STYLE_DOC="$ROOT_DIR/docs/writing-style.md"
SKILL_DOC="$ROOT_DIR/skills/matlab-plotting-skill/SKILL.md"

if [[ ! -s "$STYLE_DOC" ]]; then
  echo "missing docs/writing-style.md" >&2
  exit 1
fi

grep -q "# Writing Style" "$STYLE_DOC"
grep -q "Write like a maintainer" "$STYLE_DOC"
grep -q "Say what works today" "$STYLE_DOC"
grep -q "Do not claim adoption" "$STYLE_DOC"
grep -q "Prefer one concrete command" "$STYLE_DOC"
grep -q "Keep Chinese docs conversational" "$STYLE_DOC"

grep -q "docs/writing-style.md" "$ROOT_DIR/README.md"
grep -q "docs/writing-style.md" "$ROOT_DIR/README.zh-CN.md"
grep -q "docs/writing-style.md" "$ROOT_DIR/CONTRIBUTING.md"
grep -q "grounded, maintainer-style" "$SKILL_DOC"

voice_checked_files=(
  "$ROOT_DIR/README.md"
  "$ROOT_DIR/README.zh-CN.md"
  "$ROOT_DIR/docs/first-five-minutes.md"
  "$ROOT_DIR/docs/first-render-walkthrough.md"
  "$ROOT_DIR/docs/first-render-walkthrough.zh-CN.md"
  "$ROOT_DIR/docs/first-use-doctor.md"
  "$ROOT_DIR/docs/ecosystem-status.md"
  "$ROOT_DIR/docs/maintenance-cadence.md"
  "$SKILL_DOC"
  "$ROOT_DIR/skills/scientific-diagram-skill/SKILL.md"
  "$ROOT_DIR/skills/scientific-diagram-skill/references/drawio-workflow.md"
  "$ROOT_DIR/skills/scientific-diagram-skill/references/diagram-quality-checklist.md"
  "$ROOT_DIR/skills/scientific-diagram-skill/references/export-and-provenance.md"
  "$ROOT_DIR/skills/scientific-diagram-skill/assets/examples/provenance.md"
)

english_hype='seamless|cutting-edge|revolutionary|game-changing|state-of-the-art|robust and scalable|powerful and intuitive|comprehensive solution|widely adopted|users worldwide|trusted by'
chinese_hype='赋能|一站式|颠覆式|无缝|智能化闭环|高质量高强度|全流程闭环|广泛采用|行业领先'

if grep -RInE "$english_hype|$chinese_hype" "${voice_checked_files[@]}"; then
  echo "found hype or unsupported adoption wording in user-facing docs" >&2
  exit 1
fi

echo "Docs voice test passed."
