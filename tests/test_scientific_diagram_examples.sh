#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXAMPLE_DIR="$ROOT_DIR/skills/scientific-diagram-skill/assets/examples"

if [[ ! -x "$ROOT_DIR/scripts/check_diagram_examples.py" ]]; then
  echo "missing executable diagram example checker" >&2
  exit 1
fi

if [[ ! -s "$EXAMPLE_DIR/research-method-flow.drawio" ]]; then
  echo "missing research method drawio example" >&2
  exit 1
fi

if [[ ! -s "$EXAMPLE_DIR/research-method-flow.svg" ]]; then
  echo "missing research method SVG preview" >&2
  exit 1
fi

if [[ ! -s "$EXAMPLE_DIR/provenance.md" ]]; then
  echo "missing diagram example provenance note" >&2
  exit 1
fi

python3 "$ROOT_DIR/scripts/check_diagram_examples.py"

grep -q "research-method-flow.drawio" "$ROOT_DIR/skills/scientific-diagram-skill/SKILL.md"
grep -q "research-method-flow.svg" "$ROOT_DIR/skills/scientific-diagram-skill/SKILL.md"
grep -q "check_diagram_examples.py" "$ROOT_DIR/README.md"
grep -q "check_diagram_examples.py" "$ROOT_DIR/README.zh-CN.md"
grep -q "check_diagram_examples.py" "$ROOT_DIR/docs/install-targets.md"

echo "scientific diagram examples test passed."
