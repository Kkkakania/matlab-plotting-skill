#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CATALOG="$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"
GALLERY_DIR=""
FORMAT="png"

usage() {
  cat <<'USAGE'
Usage:
  check_gallery_outputs.sh --dir <gallery-dir> [--format png] [--catalog <scheme-catalog.md>]

Checks that every scheme in the catalog has a non-empty output file in the
gallery directory.
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

validate_format() {
  case "$FORMAT" in
    png|svg|pdf) ;;
    *)
      echo "Invalid gallery format. Use one of: png, svg, pdf." >&2
      exit 2
      ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)
      require_value "$1" "${2:-}"
      GALLERY_DIR="$2"
      shift 2
      ;;
    --format)
      require_value "$1" "${2:-}"
      FORMAT="$2"
      shift 2
      ;;
    --catalog)
      require_value "$1" "${2:-}"
      CATALOG="$2"
      shift 2
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

if [[ -z "$GALLERY_DIR" ]]; then
  echo "Missing required --dir argument." >&2
  usage >&2
  exit 2
fi

if [[ -z "$FORMAT" ]]; then
  echo "Missing --format value." >&2
  exit 2
fi
validate_format

if [[ ! -d "$GALLERY_DIR" ]]; then
  echo "Gallery directory not found: $GALLERY_DIR" >&2
  exit 1
fi

if [[ ! -f "$CATALOG" ]]; then
  echo "Scheme catalog not found: $CATALOG" >&2
  exit 1
fi

schemes=()
while IFS= read -r scheme; do
  schemes+=("$scheme")
done < <(grep -E '^\| `[A-Za-z0-9_]+` \|' "$CATALOG" | sed -E 's/^\| `([^`]+)`.*/\1/')

if [[ "${#schemes[@]}" -eq 0 ]]; then
  echo "No schemes found in catalog: $CATALOG" >&2
  exit 1
fi

missing=()
for scheme in "${schemes[@]}"; do
  output="$GALLERY_DIR/$scheme.$FORMAT"
  if [[ ! -s "$output" ]]; then
    missing+=("$scheme.$FORMAT")
  fi
done

if [[ "${#missing[@]}" -gt 0 ]]; then
  echo "Missing or empty gallery outputs:" >&2
  printf '  %s\n' "${missing[@]}" >&2
  exit 1
fi

echo "Gallery output check passed: ${#schemes[@]} .$FORMAT files in $GALLERY_DIR"
