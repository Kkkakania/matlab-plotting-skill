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

printf 'png\n' > "$TMP_DIR/line_trend.png"
printf 'png\n' > "$TMP_DIR/grouped_bar.png"

python3 "$ROOT_DIR/scripts/build_gallery_index.py" --dir "$TMP_DIR" --catalog "$CATALOG" --out "$TMP_DIR/index.md" --format png

grep -q "line_trend" "$TMP_DIR/index.md"
grep -q "grouped_bar" "$TMP_DIR/index.md"
grep -q "line_trend.png" "$TMP_DIR/index.md"
grep -q "Category comparison" "$TMP_DIR/index.md"

echo "gallery index test passed."
