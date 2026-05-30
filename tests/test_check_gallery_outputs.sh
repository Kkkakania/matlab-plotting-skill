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

printf 'not empty\n' > "$TMP_DIR/line_trend.png"

if "$ROOT_DIR/scripts/check_gallery_outputs.sh" --dir "$TMP_DIR" --catalog "$CATALOG" --format png; then
  echo "gallery check should fail when one scheme output is missing" >&2
  exit 1
fi

printf 'not empty\n' > "$TMP_DIR/grouped_bar.png"

"$ROOT_DIR/scripts/check_gallery_outputs.sh" --dir "$TMP_DIR" --catalog "$CATALOG" --format png

echo "gallery output check test passed."
