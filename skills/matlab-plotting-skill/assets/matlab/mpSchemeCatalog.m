function schemes = mpSchemeCatalog()
%MPSCHEMECATALOG Return all supported plotting schemes.

data = {
    "line_trend", "trend", "One ordered numeric series", ["trend", "time", "line"], "categorical"
    "multi_line_comparison", "trend", "Several comparable numeric series", ["trend", "line", "comparison"], "categorical"
    "confidence_band", "trend", "Mean with uncertainty band", ["trend", "uncertainty"], "categorical"
    "zoomed_inset_line", "trend", "Long trend with local detail", ["trend", "inset", "zoom"], "categorical"
    "positive_negative_area", "trend", "Signed change around zero", ["trend", "change", "signed"], "diverging"
    "segmented_line", "trend", "Trend with phase changes", ["trend", "phase"], "categorical"
    "scatter_relationship", "relationship", "Two continuous variables", ["scatter", "relationship"], "categorical"
    "grouped_scatter", "relationship", "Two variables with groups", ["scatter", "group"], "categorical"
    "density_scatter", "relationship", "Dense x-y samples", ["scatter", "density"], "sequential"
    "contour_scatter", "relationship", "Local density contours", ["scatter", "contour"], "sequential"
    "regression_scatter", "relationship", "Scatter with regression line", ["scatter", "regression"], "categorical"
    "bubble_scatter", "relationship", "x-y with magnitude", ["scatter", "bubble"], "sequential"
    "residual_scatter", "relationship", "Residual pattern check", ["scatter", "residual"], "diverging"
    "heatmap_matrix", "matrix", "Numeric matrix values", ["matrix", "heatmap"], "sequential"
    "clustered_heatmap", "matrix", "Matrix with rough grouping", ["matrix", "cluster"], "sequential"
    "correlation_heatmap", "matrix", "Correlation matrix", ["matrix", "correlation"], "diverging"
    "correlation_bubble", "matrix", "Correlation as bubbles", ["matrix", "correlation", "bubble"], "diverging"
    "double_triangle_heatmap", "matrix", "Two matrices in one square", ["matrix", "triangle", "comparison"], "diverging"
    "triangular_heatmap", "matrix", "One triangle of a matrix", ["matrix", "triangle"], "sequential"
    "bubble_matrix", "matrix", "Matrix magnitude by bubble size", ["matrix", "bubble"], "sequential"
    "grouped_bar", "bar", "Grouped category comparison", ["bar", "comparison"], "categorical"
    "stacked_bar", "bar", "Stacked category composition", ["bar", "stacked"], "categorical"
    "horizontal_bar", "bar", "Bars with long labels", ["bar", "horizontal"], "categorical"
    "diverging_bar", "bar", "Positive and negative bars", ["bar", "diverging", "signed"], "diverging"
    "grouped_error_bar", "bar", "Grouped bars with uncertainty", ["bar", "error", "uncertainty"], "categorical"
    "floating_bar", "bar", "Ranges and intervals", ["bar", "range"], "sequential"
    "butterfly_comparison", "bar", "Two-sided comparison", ["bar", "butterfly", "comparison"], "diverging"
    "box_jitter", "distribution", "Distribution and observations", ["box", "distribution"], "categorical"
    "violin_plot", "distribution", "Smooth distribution shape", ["violin", "distribution"], "categorical"
    "ridgeline_plot", "distribution", "Many distributions", ["ridgeline", "distribution"], "sequential"
    "histogram_distribution", "distribution", "One numeric distribution", ["histogram", "distribution"], "sequential"
    "density_curve", "distribution", "Smooth numeric density", ["density", "distribution"], "sequential"
    "jitter_swarm", "distribution", "Grouped observations", ["jitter", "swarm"], "categorical"
    "ecdf_curve", "distribution", "Empirical cumulative distribution", ["ecdf", "distribution"], "categorical"
    "lollipop_ranking", "ranking", "Sorted importance", ["ranking", "lollipop"], "categorical"
    "dot_ranking", "ranking", "Compact ordered scores", ["ranking", "dot"], "categorical"
    "waffle_composition", "composition", "Countable parts of a whole", ["composition", "waffle"], "categorical"
    "percent_stacked_bar", "composition", "Percent composition by group", ["composition", "percent", "stacked"], "categorical"
    "pareto_chart", "ranking", "Contribution and cumulative share", ["pareto", "ranking"], "categorical"
    "waterfall_contribution", "ranking", "Stepwise contribution", ["waterfall", "contribution"], "diverging"
    "radar_chart", "multivariate", "Few normalized metrics", ["radar", "profile"], "categorical"
    "parallel_coordinates", "multivariate", "Many samples across metrics", ["parallel", "multivariate"], "categorical"
    "pca_scatter", "multivariate", "Low-dimensional projection", ["pca", "scatter"], "categorical"
    "surface_3d", "spatial", "Smooth z over x-y", ["surface", "3d"], "sequential"
    "contour_map", "spatial", "2D scalar field", ["contour", "map"], "sequential"
    "quiver_vector", "spatial", "Vector field", ["quiver", "vector"], "diverging"
    "ternary_composition", "composition", "Three-part composition", ["ternary", "composition"], "categorical"
    "multi_panel_overview", "layout", "Several views in one figure", ["layout", "panel"], "categorical"
    "small_multiples", "layout", "Repeated panels by group", ["layout", "multiples"], "categorical"
    "annotated_callout", "layout", "Highlight a point or event", ["layout", "annotation"], "categorical"
};

schemes = repmat(struct('Name', "", 'Family', "", 'Task', "", 'Tags', strings(1, 0), ...
    'Palette', ""), size(data, 1), 1);
for k = 1:size(data, 1)
    schemes(k).Name = data{k, 1};
    schemes(k).Family = data{k, 2};
    schemes(k).Task = data{k, 3};
    schemes(k).Tags = data{k, 4};
    schemes(k).Palette = data{k, 5};
end
end
