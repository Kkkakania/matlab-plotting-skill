#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="$ROOT_DIR/skills/scientific-diagram-skill"

if [[ ! -s "$SKILL_DIR/SKILL.md" ]]; then
  echo "missing scientific diagram skill" >&2
  exit 1
fi

grep -q "name: scientific-diagram-skill" "$SKILL_DIR/SKILL.md"
grep -q "description:" "$SKILL_DIR/SKILL.md"
grep -q "draw.io" "$SKILL_DIR/SKILL.md"
grep -q "diagrams.net" "$SKILL_DIR/SKILL.md"
grep -q "Mermaid" "$SKILL_DIR/SKILL.md"
grep -q "clean-room" "$SKILL_DIR/SKILL.md"
grep -q "No Watermarks" "$SKILL_DIR/SKILL.md"
grep -q "private logos" "$SKILL_DIR/SKILL.md"
grep -q "references/drawio-workflow.md" "$SKILL_DIR/SKILL.md"
grep -q "references/diagram-quality-checklist.md" "$SKILL_DIR/SKILL.md"
grep -q "references/export-and-provenance.md" "$SKILL_DIR/SKILL.md"

grep -q "Scientific Diagram Skill" "$SKILL_DIR/agents/openai.yaml"
grep -q "draw.io" "$SKILL_DIR/agents/openai.yaml"

grep -q "# Draw.io Workflow" "$SKILL_DIR/references/drawio-workflow.md"
grep -q "mxGraphModel" "$SKILL_DIR/references/drawio-workflow.md"
grep -q "# Diagram Quality Checklist" "$SKILL_DIR/references/diagram-quality-checklist.md"
grep -q "# Export And Provenance" "$SKILL_DIR/references/export-and-provenance.md"
grep -q "mfigci" "$SKILL_DIR/references/export-and-provenance.md"

if grep -RInE "seamless|game-changing|行业领先|赋能|一站式" "$SKILL_DIR"; then
  echo "scientific diagram skill contains hype wording" >&2
  exit 1
fi

echo "scientific diagram skill test passed."
