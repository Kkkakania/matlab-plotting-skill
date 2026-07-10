#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_NAME="matlab-plotting-skill"
TARGET_KIND="codex"
TARGET_DIR=""
TARGET_PATH=""
MODE="link"
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage:
  install_skill.sh [--skill matlab-plotting-skill|scientific-diagram-skill] [--target codex|claude-code|dir] [--path <skills-dir>] [--copy] [--dry-run]
  install_skill.sh --target <skills-dir> [--copy] [--dry-run]

Default:
  Symlink skills/matlab-plotting-skill into ${CODEX_HOME:-$HOME/.codex}/skills.

Skills:
  matlab-plotting-skill      Choose and render MATLAB scientific figures.
  scientific-diagram-skill   Plan and export Mermaid/draw.io research diagrams.

Targets:
  codex        Install into ${CODEX_HOME:-$HOME/.codex}/skills.
  claude-code  Install into ${CLAUDE_HOME:-$HOME/.claude}/skills.
  dir          Install into the directory passed with --path.

Compatibility:
  Passing a filesystem path to --target is still supported.
USAGE
}

require_value() {
  local option="$1"
  local value="${2:-}"

  if [[ -z "$value" || "$value" == --* ]]; then
    echo "$option requires a value." >&2
    usage >&2
    exit 2
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skill)
      require_value "$1" "${2:-}"
      case "$2" in
        matlab-plotting-skill|scientific-diagram-skill)
          SKILL_NAME="$2"
          ;;
        *)
          echo "Unknown skill: $2" >&2
          usage >&2
          exit 2
          ;;
      esac
      shift 2
      ;;
    --target)
      require_value "$1" "${2:-}"
      case "$2" in
        codex|claude-code|dir)
          TARGET_KIND="$2"
          ;;
        *)
          TARGET_KIND="legacy-dir"
          TARGET_DIR="$2"
          ;;
      esac
      shift 2
      ;;
    --path)
      require_value "$1" "${2:-}"
      TARGET_PATH="$2"
      shift 2
      ;;
    --copy)
      MODE="copy"
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$TARGET_KIND" in
  codex)
    TARGET_DIR="${CODEX_HOME:-$HOME/.codex}/skills"
    ;;
  claude-code)
    TARGET_DIR="${CLAUDE_HOME:-$HOME/.claude}/skills"
    ;;
  dir)
    if [[ -z "$TARGET_PATH" ]]; then
      echo "--target dir requires --path <skills-dir>." >&2
      usage >&2
      exit 2
    fi
    TARGET_DIR="$TARGET_PATH"
    ;;
  legacy-dir)
    ;;
  *)
    echo "Unknown target kind: $TARGET_KIND" >&2
    usage >&2
    exit 2
    ;;
esac

SOURCE_DIR="$ROOT_DIR/skills/$SKILL_NAME"

if [[ ! -f "$SOURCE_DIR/SKILL.md" ]]; then
  echo "Skill source not found: $SOURCE_DIR" >&2
  exit 1
fi
SOURCE_REAL_DIR="$(cd "$SOURCE_DIR" && pwd -P)"

DEST_DIR="$TARGET_DIR/$SKILL_NAME"

link_points_to_source() {
  local link_path="$1"
  local target="$2"
  local target_dir
  local target_base
  local resolved

  if [[ "$target" == "$SOURCE_DIR" || "$target" == "$SOURCE_REAL_DIR" ]]; then
    return 0
  fi

  target_dir="$(dirname "$target")"
  target_base="$(basename "$target")"
  if [[ "$target" == /* ]]; then
    resolved="$(cd "$target_dir" 2>/dev/null && printf '%s/%s' "$(pwd -P)" "$target_base")" || return 1
  else
    resolved="$(cd "$(dirname "$link_path")/$target_dir" 2>/dev/null && printf '%s/%s' "$(pwd -P)" "$target_base")" || return 1
  fi

  [[ "$resolved" == "$SOURCE_REAL_DIR" ]]
}

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Would install $SKILL_NAME"
  echo "  source: $SOURCE_DIR"
  echo "  target: $DEST_DIR"
  echo "  mode:   $MODE"
  exit 0
fi

mkdir -p "$TARGET_DIR"

if [[ -e "$DEST_DIR" || -L "$DEST_DIR" ]]; then
  if [[ -L "$DEST_DIR" ]] && link_points_to_source "$DEST_DIR" "$(readlink "$DEST_DIR")"; then
    echo "$SKILL_NAME is already linked at $DEST_DIR"
    exit 0
  fi
  echo "Target already exists: $DEST_DIR" >&2
  echo "Remove it first or choose another --target." >&2
  exit 1
fi

if [[ "$MODE" == "copy" ]]; then
  cp -R "$SOURCE_DIR" "$DEST_DIR"
else
  ln -s "$SOURCE_DIR" "$DEST_DIR"
fi

echo "Installed $SKILL_NAME at $DEST_DIR"
