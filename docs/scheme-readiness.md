# Scheme Readiness

This matrix separates the 50-scheme catalog from the smaller set of schemes
that currently have committed gallery previews and completed support tasks.

## Summary

| Readiness | Schemes |
|---|---:|
| gallery-backed | 8 |
| preview available | 3 |
| render path started | 0 |
| cataloged | 39 |

## Matrix

| Scheme | Family | Readiness | Gallery | Data Contract | Explicit CLI | PNG | Vector | Report | Safety |
|---|---|---|---|---|---|---|---|---|---|
| `line_trend` | Trend | gallery-backed | [preview](gallery/line_trend.png) | yes | yes | yes | yes | yes | yes |
| `multi_line_comparison` | Trend | gallery-backed | [preview](gallery/multi_line_comparison.png) | yes | yes | yes | yes | yes | yes |
| `confidence_band` | Trend | gallery-backed | [preview](gallery/confidence_band.png) | yes | yes | yes | yes | yes | yes |
| `zoomed_inset_line` | Trend | gallery-backed | [preview](gallery/zoomed_inset_line.png) | yes | yes | yes | yes | yes | yes |
| `positive_negative_area` | Trend | gallery-backed | [preview](gallery/positive_negative_area.png) | yes | yes | yes | yes | yes | yes |
| `segmented_line` | Trend | gallery-backed | [preview](gallery/segmented_line.png) | yes | yes | yes | yes | yes | yes |
| `scatter_relationship` | Relationship | gallery-backed | [preview](gallery/scatter_relationship.png) | yes | yes | yes | yes | yes | yes |
| `grouped_scatter` | Relationship | gallery-backed | [preview](gallery/grouped_scatter.png) | yes | yes | yes | yes | yes | yes |
| `density_scatter` | Relationship | preview available | [preview](gallery/density_scatter.png) | yes | yes | yes | yes | yes | no |
| `contour_scatter` | Relationship | cataloged | no | no | no | no | no | no | no |
| `regression_scatter` | Relationship | cataloged | no | no | no | no | no | no | no |
| `bubble_scatter` | Relationship | cataloged | no | no | no | no | no | no | no |
| `residual_scatter` | Relationship | cataloged | no | no | no | no | no | no | no |
| `heatmap_matrix` | Matrix | preview available | [preview](gallery/heatmap_matrix.png) | no | no | no | no | no | no |
| `clustered_heatmap` | Matrix | cataloged | no | no | no | no | no | no | no |
| `correlation_heatmap` | Matrix | cataloged | no | no | no | no | no | no | no |
| `correlation_bubble` | Matrix | cataloged | no | no | no | no | no | no | no |
| `double_triangle_heatmap` | Matrix | cataloged | no | no | no | no | no | no | no |
| `triangular_heatmap` | Matrix | cataloged | no | no | no | no | no | no | no |
| `bubble_matrix` | Matrix | cataloged | no | no | no | no | no | no | no |
| `grouped_bar` | Bar | preview available | [preview](gallery/grouped_bar.png) | no | no | no | no | no | no |
| `stacked_bar` | Bar | cataloged | no | no | no | no | no | no | no |
| `horizontal_bar` | Bar | cataloged | no | no | no | no | no | no | no |
| `diverging_bar` | Bar | cataloged | no | no | no | no | no | no | no |
| `grouped_error_bar` | Bar | cataloged | no | no | no | no | no | no | no |
| `floating_bar` | Bar | cataloged | no | no | no | no | no | no | no |
| `butterfly_comparison` | Bar | cataloged | no | no | no | no | no | no | no |
| `box_jitter` | Distribution | cataloged | no | no | no | no | no | no | no |
| `violin_plot` | Distribution | cataloged | no | no | no | no | no | no | no |
| `ridgeline_plot` | Distribution | cataloged | no | no | no | no | no | no | no |
| `histogram_distribution` | Distribution | cataloged | no | no | no | no | no | no | no |
| `density_curve` | Distribution | cataloged | no | no | no | no | no | no | no |
| `jitter_swarm` | Distribution | cataloged | no | no | no | no | no | no | no |
| `ecdf_curve` | Distribution | cataloged | no | no | no | no | no | no | no |
| `lollipop_ranking` | Ranking | cataloged | no | no | no | no | no | no | no |
| `dot_ranking` | Ranking | cataloged | no | no | no | no | no | no | no |
| `waffle_composition` | Composition | cataloged | no | no | no | no | no | no | no |
| `percent_stacked_bar` | Composition | cataloged | no | no | no | no | no | no | no |
| `pareto_chart` | Ranking | cataloged | no | no | no | no | no | no | no |
| `waterfall_contribution` | Ranking | cataloged | no | no | no | no | no | no | no |
| `radar_chart` | Multivariate | cataloged | no | no | no | no | no | no | no |
| `parallel_coordinates` | Multivariate | cataloged | no | no | no | no | no | no | no |
| `pca_scatter` | Multivariate | cataloged | no | no | no | no | no | no | no |
| `surface_3d` | Spatial | cataloged | no | no | no | no | no | no | no |
| `contour_map` | Spatial | cataloged | no | no | no | no | no | no | no |
| `quiver_vector` | Spatial | cataloged | no | no | no | no | no | no | no |
| `ternary_composition` | Composition | cataloged | no | no | no | no | no | no | no |
| `multi_panel_overview` | Layout | cataloged | no | no | no | no | no | no | no |
| `small_multiples` | Layout | cataloged | no | no | no | no | no | no | no |
| `annotated_callout` | Layout | cataloged | no | no | no | no | no | no | no |

## Notes

- `gallery-backed` means the key task lanes are marked done and a committed PNG preview exists.
- `preview available` means a committed PNG exists, but at least one support lane is still pending.
- `cataloged` means the scheme is part of the catalog and roadmap, but should be treated as less proven.
