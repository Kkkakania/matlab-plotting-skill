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

NESTED_GALLERY="$TMP_DIR/gallery"
NESTED_OUT="$TMP_DIR/site/index.md"
mkdir -p "$NESTED_GALLERY"
printf 'png\n' > "$NESTED_GALLERY/line_trend.png"
python3 "$ROOT_DIR/scripts/build_gallery_index.py" --dir "$NESTED_GALLERY" --catalog "$CATALOG" --out "$NESTED_OUT" --format png

line_trend_row="$(grep '!\[line_trend\]' "$NESTED_OUT")"
grep -q "../gallery/line_trend.png" <<<"$line_trend_row"
if grep -q "$TMP_DIR" <<<"$line_trend_row"; then
  echo "gallery index image links should not leak absolute local paths" >&2
  echo "$line_trend_row" >&2
  exit 1
fi

if python3 "$ROOT_DIR/scripts/build_gallery_index.py" \
  --dir "$TMP_DIR" \
  --catalog "$CATALOG" \
  --out "$TMP_DIR/bad-index.md" \
  --format '../png' >"$TMP_DIR/bad-format.out" 2>"$TMP_DIR/bad-format.err"; then
  echo "invalid gallery index format should fail" >&2
  exit 1
fi

grep -q "Invalid gallery format" "$TMP_DIR/bad-format.err"

echo "gallery index test passed."
