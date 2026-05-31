#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="$(mktemp -d)"
trap 'rm -rf "$TARGET_DIR"' EXIT

set +e
"$ROOT_DIR/scripts/install_skill.sh" --target >/dev/null 2>"$TARGET_DIR/missing-target.err"
missing_target_status=$?
set -e

if [[ "$missing_target_status" -ne 2 ]]; then
  echo "expected --target without a value to exit 2, got $missing_target_status" >&2
  cat "$TARGET_DIR/missing-target.err" >&2
  exit 1
fi

if ! grep -q -- "--target requires a value" "$TARGET_DIR/missing-target.err"; then
  echo "expected clear missing-value message for --target" >&2
  cat "$TARGET_DIR/missing-target.err" >&2
  exit 1
fi

dry_output="$("$ROOT_DIR/scripts/install_skill.sh" --target "$TARGET_DIR" --dry-run)"
if [[ "$dry_output" != *"matlab-plotting-skill"* ]]; then
  echo "dry-run output should mention the skill name" >&2
  exit 1
fi

if [[ -e "$TARGET_DIR/matlab-plotting-skill" ]]; then
  echo "dry-run must not create the skill directory" >&2
  exit 1
fi

"$ROOT_DIR/scripts/install_skill.sh" --target "$TARGET_DIR" --copy

if [[ ! -f "$TARGET_DIR/matlab-plotting-skill/SKILL.md" ]]; then
  echo "copy install should create SKILL.md under target" >&2
  exit 1
fi

echo "install script test passed."
