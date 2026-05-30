# Gallery Provenance

The committed gallery previews are generated from bundled synthetic demo data.
They are not screenshots of papers, copied figures, private datasets, or local
template archives.

| Asset | Scheme | Data Source | Generation Path | Safety Notes |
|---|---|---|---|---|
| `line_trend.png` | `line_trend` | synthetic demo data | `mpDemoDataForScheme` -> `mpRenderScheme` -> PNG export | no private data, no external image source |
| `multi_line_comparison.png` | `multi_line_comparison` | synthetic CSV example | `examples/data/multi_series.csv` -> `mpRun` -> PNG export | no private data, no external image source |
| `confidence_band.png` | `confidence_band` | synthetic CSV example | `examples/data/confidence_band.csv` -> `mpRun` -> PNG export | no private data, no external image source |
| `zoomed_inset_line.png` | `zoomed_inset_line` | synthetic demo data | `mpDemoDataForScheme` -> temporary CSV -> `mpRun` -> PNG export | no private data, no external image source |
| `positive_negative_area.png` | `positive_negative_area` | synthetic demo data | `mpDemoDataForScheme` -> temporary CSV -> `mpRun` -> PNG export | no private data, no external image source |
| `density_scatter.png` | `density_scatter` | synthetic demo data | `mpDemoDataForScheme` -> `mpRenderScheme` -> PNG export | no private data, no external image source |
| `heatmap_matrix.png` | `heatmap_matrix` | synthetic demo data | `mpDemoDataForScheme` -> `mpRenderScheme` -> PNG export | no private data, no external image source |
| `grouped_bar.png` | `grouped_bar` | synthetic demo data | `mpDemoDataForScheme` -> `mpRenderScheme` -> PNG export | no private data, no external image source |
