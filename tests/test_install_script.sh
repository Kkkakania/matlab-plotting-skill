#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="$(mktemp -d)"
trap 'rm -rf "$TARGET_DIR"' EXIT

set +e
"$ROOT_DIR/scripts/install_skill.sh" --skill >/dev/null 2>"$TARGET_DIR/missing-skill.err"
missing_skill_status=$?
set -e

if [[ "$missing_skill_status" -ne 2 ]]; then
  echo "expected --skill without a value to exit 2, got $missing_skill_status" >&2
  cat "$TARGET_DIR/missing-skill.err" >&2
  exit 1
fi

if ! grep -q -- "--skill requires a value" "$TARGET_DIR/missing-skill.err"; then
  echo "expected clear missing-value message for --skill" >&2
  cat "$TARGET_DIR/missing-skill.err" >&2
  exit 1
fi

set +e
"$ROOT_DIR/scripts/install_skill.sh" --skill unknown-skill --target "$TARGET_DIR" >/dev/null 2>"$TARGET_DIR/unknown-skill.err"
unknown_skill_status=$?
set -e

if [[ "$unknown_skill_status" -ne 2 ]]; then
  echo "expected unknown --skill to exit 2, got $unknown_skill_status" >&2
  cat "$TARGET_DIR/unknown-skill.err" >&2
  exit 1
fi

if ! grep -q -- "Unknown skill" "$TARGET_DIR/unknown-skill.err"; then
  echo "expected clear unknown skill message" >&2
  cat "$TARGET_DIR/unknown-skill.err" >&2
  exit 1
fi

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

set +e
"$ROOT_DIR/scripts/install_skill.sh" --target dir --dry-run >/dev/null 2>"$TARGET_DIR/missing-dir-path.err"
missing_dir_path_status=$?
set -e

if [[ "$missing_dir_path_status" -ne 2 ]]; then
  echo "expected --target dir without --path to exit 2, got $missing_dir_path_status" >&2
  cat "$TARGET_DIR/missing-dir-path.err" >&2
  exit 1
fi

if ! grep -q -- "--target dir requires --path" "$TARGET_DIR/missing-dir-path.err"; then
  echo "expected clear missing path message for --target dir" >&2
  cat "$TARGET_DIR/missing-dir-path.err" >&2
  exit 1
fi

HOME_FIXTURE="$TARGET_DIR/"
HOME_FIXTURE+="home"

dry_codex="$(HOME="$HOME_FIXTURE" CODEX_HOME= "$ROOT_DIR/scripts/install_skill.sh" --target codex --dry-run)"
if [[ "$dry_codex" != *"$HOME_FIXTURE/.codex/skills/matlab-plotting-skill"* ]]; then
  echo "codex target should resolve under HOME/.codex/skills" >&2
  echo "$dry_codex" >&2
  exit 1
fi

dry_claude="$(HOME="$HOME_FIXTURE" "$ROOT_DIR/scripts/install_skill.sh" --target claude-code --dry-run)"
if [[ "$dry_claude" != *"$HOME_FIXTURE/.claude/skills/matlab-plotting-skill"* ]]; then
  echo "claude-code target should resolve under HOME/.claude/skills" >&2
  echo "$dry_claude" >&2
  exit 1
fi

explicit_dir="$TARGET_DIR/project-skills"
dry_explicit="$("$ROOT_DIR/scripts/install_skill.sh" --target dir --path "$explicit_dir" --dry-run)"
if [[ "$dry_explicit" != *"$explicit_dir/matlab-plotting-skill"* ]]; then
  echo "dir target should resolve to the explicit --path directory" >&2
  echo "$dry_explicit" >&2
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

if [[ ! -x "$TARGET_DIR/matlab-plotting-skill/scripts/doctor.sh" ]]; then
  echo "copy install should include an executable skill-local doctor script" >&2
  exit 1
fi

"$TARGET_DIR/matlab-plotting-skill/scripts/render_with_matlab.sh" --doctor --out "$TARGET_DIR/installed-doctor" >/dev/null
if [[ ! -s "$TARGET_DIR/installed-doctor/first_use_doctor.md" || ! -s "$TARGET_DIR/installed-doctor/first_use_doctor.json" ]]; then
  echo "installed skill should run --doctor without the repository root" >&2
  exit 1
fi
if grep -q "$TARGET_DIR" "$TARGET_DIR/installed-doctor/first_use_doctor.md" "$TARGET_DIR/installed-doctor/first_use_doctor.json"; then
  echo "installed skill doctor reports should not leak the install path" >&2
  exit 1
fi

diagram_target="$TARGET_DIR/diagram-skills"
diagram_dry="$("$ROOT_DIR/scripts/install_skill.sh" --skill scientific-diagram-skill --target dir --path "$diagram_target" --dry-run)"
if [[ "$diagram_dry" != *"$diagram_target/scientific-diagram-skill"* ]]; then
  echo "diagram skill dry-run should resolve to the selected skill name" >&2
  echo "$diagram_dry" >&2
  exit 1
fi

"$ROOT_DIR/scripts/install_skill.sh" --skill scientific-diagram-skill --target dir --path "$diagram_target" --copy

if [[ ! -f "$diagram_target/scientific-diagram-skill/SKILL.md" ]]; then
  echo "copy install should create the scientific diagram SKILL.md under target" >&2
  exit 1
fi

if [[ ! -s "$diagram_target/scientific-diagram-skill/references/drawio-workflow.md" ]]; then
  echo "copy install should include scientific diagram references" >&2
  exit 1
fi

echo "install script test passed."
