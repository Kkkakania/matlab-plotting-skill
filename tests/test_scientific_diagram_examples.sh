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

if [[ ! -s "$EXAMPLE_DIR/manifest.json" ]]; then
  echo "missing diagram example manifest" >&2
  exit 1
fi

python3 "$ROOT_DIR/scripts/check_diagram_examples.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
cp -R "$EXAMPLE_DIR" "$TMP_DIR/examples"
python3 - "$TMP_DIR/examples/manifest.json" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
manifest = json.loads(path.read_text(encoding="utf-8"))
manifest["examples"][0]["privateData"] = True
path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
PY
if DIAGRAM_EXAMPLE_DIR="$TMP_DIR/examples" python3 "$ROOT_DIR/scripts/check_diagram_examples.py" 2>"$TMP_DIR/bad-manifest.err"; then
  echo "checker should reject manifest examples marked private" >&2
  exit 1
fi
grep -q "privateData" "$TMP_DIR/bad-manifest.err"

grep -q "research-method-flow.drawio" "$ROOT_DIR/skills/scientific-diagram-skill/SKILL.md"
grep -q "research-method-flow.svg" "$ROOT_DIR/skills/scientific-diagram-skill/SKILL.md"
grep -q "manifest.json" "$ROOT_DIR/skills/scientific-diagram-skill/SKILL.md"
grep -q "check_diagram_examples.py" "$ROOT_DIR/README.md"
grep -q "check_diagram_examples.py" "$ROOT_DIR/README.zh-CN.md"
grep -q "manifest.json" "$ROOT_DIR/README.md"
grep -q "manifest.json" "$ROOT_DIR/README.zh-CN.md"
grep -q "example manifest" "$ROOT_DIR/docs/install-targets.md"
grep -q "check_diagram_examples.py" "$ROOT_DIR/docs/install-targets.md"

echo "scientific diagram examples test passed."
