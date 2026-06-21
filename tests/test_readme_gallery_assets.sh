#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

assets=(
  "docs/gallery/line_trend.png"
  "docs/gallery/multi_line_comparison.png"
  "docs/gallery/confidence_band.png"
  "docs/gallery/zoomed_inset_line.png"
  "docs/gallery/scatter_relationship.png"
  "docs/gallery/grouped_scatter.png"
  "docs/gallery/contour_scatter.png"
  "docs/gallery/regression_scatter.png"
  "docs/gallery/positive_negative_area.png"
  "docs/gallery/segmented_line.png"
  "docs/gallery/stacked_time_series.png"
  "docs/gallery/grouped_bar.png"
  "docs/gallery/heatmap_matrix.png"
  "docs/gallery/density_scatter.png"
)

for asset in "${assets[@]}"; do
  if [[ ! -s "$ROOT_DIR/$asset" ]]; then
    echo "missing gallery asset: $asset" >&2
    exit 1
  fi
  grep -q "$asset" "$ROOT_DIR/README.md"
  grep -q "$asset" "$ROOT_DIR/README.zh-CN.md"
done

echo "README gallery assets test passed."
