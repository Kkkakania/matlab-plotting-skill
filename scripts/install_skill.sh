#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="$ROOT_DIR/skills/matlab-plotting-skill"
TARGET_KIND="codex"
TARGET_DIR=""
TARGET_PATH=""
MODE="link"
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage:
  install_skill.sh [--target codex|claude-code|dir] [--path <skills-dir>] [--copy] [--dry-run]
  install_skill.sh --target <skills-dir> [--copy] [--dry-run]

Default:
  Symlink skills/matlab-plotting-skill into ${CODEX_HOME:-$HOME/.codex}/skills.

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

if [[ ! -f "$SOURCE_DIR/SKILL.md" ]]; then
  echo "Skill source not found: $SOURCE_DIR" >&2
  exit 1
fi

DEST_DIR="$TARGET_DIR/matlab-plotting-skill"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Would install matlab-plotting-skill"
  echo "  source: $SOURCE_DIR"
  echo "  target: $DEST_DIR"
  echo "  mode:   $MODE"
  exit 0
fi

mkdir -p "$TARGET_DIR"

if [[ -e "$DEST_DIR" || -L "$DEST_DIR" ]]; then
  if [[ -L "$DEST_DIR" && "$(readlink "$DEST_DIR")" == "$SOURCE_DIR" ]]; then
    echo "matlab-plotting-skill is already linked at $DEST_DIR"
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

echo "Installed matlab-plotting-skill at $DEST_DIR"
