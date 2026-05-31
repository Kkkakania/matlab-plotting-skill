#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

CATALOG="$TMP_DIR/catalog.md"
cat > "$CATALOG" <<'CATALOG_MD'
| Scheme | Family | Best For | Palette |
|---|---|---|---|
| `line_trend` | Trend | One series | categorical |
| `grouped_bar` | Bar | Category comparison | categorical |
CATALOG_MD

check_missing_value() {
  local option="$1"
  local err_file="$TMP_DIR/${option#--}.err"
  local status

  set +e
  "$ROOT_DIR/scripts/check_gallery_outputs.sh" "$option" >/dev/null 2>"$err_file"
  status=$?
  set -e

  if [[ "$status" -ne 2 ]]; then
    echo "expected $option without a value to exit 2, got $status" >&2
    cat "$err_file" >&2
    exit 1
  fi

  if ! grep -q -- "$option requires a value" "$err_file"; then
    echo "expected clear missing-value message for $option" >&2
    cat "$err_file" >&2
    exit 1
  fi
}

check_missing_value --dir
check_missing_value --format
check_missing_value --catalog

printf 'not empty\n' > "$TMP_DIR/line_trend.png"

if "$ROOT_DIR/scripts/check_gallery_outputs.sh" --dir "$TMP_DIR" --catalog "$CATALOG" --format png; then
  echo "gallery check should fail when one scheme output is missing" >&2
  exit 1
fi

printf 'not empty\n' > "$TMP_DIR/grouped_bar.png"

"$ROOT_DIR/scripts/check_gallery_outputs.sh" --dir "$TMP_DIR" --catalog "$CATALOG" --format png

echo "gallery output check test passed."
