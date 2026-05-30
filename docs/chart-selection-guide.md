# Chart Selection Guide

Start with the question, then check the data shape. A good plot should make the
main comparison or pattern easier to see, not just look more complex.

## Trend

Use trend schemes when order matters.

- One ordered numeric series: `line_trend`
- Several comparable series: `multi_line_comparison` (wide table with one
  ordered x-axis column and at least two numeric series columns)
- Mean with uncertainty: `confidence_band`
- Local event inside a long series: `zoomed_inset_line`
- Values above and below zero: `positive_negative_area`
- Phase or regime changes: `segmented_line`

When Not To Use: avoid trend plots when the x-axis order is arbitrary. A bar,
box, or ranking plot will usually be clearer.

## Relationship

Use relationship schemes when the question is about how two variables move
together.

- Simple x-y relation: `scatter_relationship`
- Groups in x-y data: `grouped_scatter`
- Dense overlapping points: `density_scatter` or `contour_scatter`
- Trend line needed: `regression_scatter`
- Third magnitude variable: `bubble_scatter`
- Model checking: `residual_scatter`

When Not To Use: avoid scatter plots for tiny category comparisons or already
aggregated rankings.

## Matrix

Use matrix schemes when both axes represent variables, samples, or categories.

- General numeric matrix: `heatmap_matrix`
- Rough grouping: `clustered_heatmap`
- Correlation: `correlation_heatmap` or `correlation_bubble`
- Pairwise comparison of two matrices: `double_triangle_heatmap`
- One half of a symmetric matrix: `triangular_heatmap`
- Magnitude as area: `bubble_matrix`

When Not To Use: avoid heatmaps when exact values or ordered top items matter
more than broad pattern recognition.

## Comparison

Use bar and distribution schemes when comparing groups.

- Category means or scores: `grouped_bar`
- Long labels: `horizontal_bar`
- Positive and negative category values: `diverging_bar`
- Values with uncertainty: `grouped_error_bar`
- Ranges or intervals: `floating_bar`
- Two-sided comparison: `butterfly_comparison`
- Raw observations by group: `box_jitter`, `jitter_swarm`, or `violin_plot`

When Not To Use: avoid bars when the distribution shape or individual samples
are the real story.

## Distribution

Use distribution schemes when spread, skew, tails, or sample-level variation
matters.

- One numeric variable: `histogram_distribution`
- Smooth density: `density_curve`
- Several distributions: `ridgeline_plot`
- Empirical cumulative view: `ecdf_curve`

When Not To Use: avoid distribution plots for two or three already summarized
numbers.

## Ranking

Use ranking schemes when order is the message.

- Sorted importance: `lollipop_ranking`
- Compact ordered scores: `dot_ranking`
- Contribution plus cumulative share: `pareto_chart`
- Stepwise contribution: `waterfall_contribution`

When Not To Use: avoid rankings when categories are nominal and order would
imply a false hierarchy.

## Composition

Use composition schemes for parts of a whole.

- Countable parts: `waffle_composition`
- Percent by group: `percent_stacked_bar`
- Three-part composition: `ternary_composition`

When Not To Use: avoid composition charts when totals differ in ways the viewer
must compare precisely.

## Multivariate And Spatial

Use these when the data has more structure than a single comparison.

- Few normalized metrics: `radar_chart`
- Many samples across metrics: `parallel_coordinates`
- Low-dimensional projection: `pca_scatter`
- Scalar field over x-y: `surface_3d` or `contour_map`
- Vector field: `quiver_vector`

When Not To Use: avoid high-dimensional figures when a simpler two-variable
plot answers the question.

## Paper Layout

Use layout schemes after the main story is clear.

- Several views in one figure: `multi_panel_overview`
- Same design repeated by group: `small_multiples`
- Highlight one point or event: `annotated_callout`

When Not To Use: avoid multi-panel figures as a way to hide weak plot choices.
Each panel should have a job.
