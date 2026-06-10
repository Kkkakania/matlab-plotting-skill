function explanation = mpExplainSelection(schema, goalText, selection)
%MPEXPLAINSELECTION Build a compact explanation for scheme selection.

goal = lower(string(goalText));
signals = localSchemaSignals(schema);
keywords = localGoalKeywords(goal);
rules = localMatchedRules(schema, goal);
warnings = localWarnings(schema, goal);

if isempty(rules)
    rules = struct('rule', "fallback", ...
        'reason', "No strong schema or goal rule matched.", ...
        'effect', "The selector falls back to a simple trend view.");
end

explanation = struct();
explanation.selectedReason = "Selected `" + string(selection.Selected.Name) + ...
    "` because it had the strongest rule score for the detected data shape and goal text.";
explanation.schemaSignals = signals;
explanation.goalKeywords = keywords;
explanation.matchedRules = rules;
explanation.warnings = warnings;
explanation.caution = "Scores are deterministic selection hints, not a statistical quality measure.";
end

function signals = localSchemaSignals(schema)
signals = strings(0, 1);
signals(end + 1) = "kind=" + string(schema.Kind);
signals(end + 1) = "rows=" + string(schema.RowCount);
signals(end + 1) = "numeric_columns=" + string(schema.NumericCount);
signals(end + 1) = "category_columns=" + string(schema.CategoryCount);
signals(end + 1) = "time_columns=" + string(schema.TimeCount);
if schema.HasMatrix
    signals(end + 1) = "matrix_like=yes";
end
if schema.HasPositiveNegative
    signals(end + 1) = "positive_negative_values=yes";
end
if schema.HasPercent
    signals(end + 1) = "percent_like_values=yes";
end
end

function keywords = localGoalKeywords(goal)
vocabulary = ["trend", "time", "series", "compare", "comparison", "method", ...
    "methods", "confidence", "uncertainty", "band", "matrix", "heatmap", ...
    "percent", "composition", "share", "ranking", "distribution", "scatter", ...
    "relationship", "density", "contour", "regression", "fit", "bubble", ...
    "zoom", "event", "segment", "phase", "paper", "panel"];
hitMask = false(size(vocabulary));
for k = 1:numel(vocabulary)
    hitMask(k) = contains(goal, vocabulary(k));
end
keywords = unique(vocabulary(hitMask), 'stable');
end

function rules = localMatchedRules(schema, goal)
rules = repmat(struct('rule', "", 'reason', "", 'effect', ""), 0, 1);

if schema.TimeCount > 0
    rules(end + 1) = localRule("time-series data", ...
        "At least one time-like column was detected.", ...
        "Trend schemes receive a strong score boost.");
end
if schema.TimeCount > 0 && schema.NumericCount >= 3
    rules(end + 1) = localRule("wide time-series data", ...
        "The table has a time column and several numeric columns.", ...
        "`multi_line_comparison` becomes a stronger candidate.");
end
if schema.TimeCount > 0 && any(contains(goal, ["confidence", "uncertainty", "band", "interval", "bounds"]))
    rules(end + 1) = localRule("uncertainty goal", ...
        "The goal asks for confidence, uncertainty, intervals, or bounds.", ...
        "`confidence_band` receives a targeted score boost.");
end
if schema.HasMatrix
    rules(end + 1) = localRule("matrix-like data", ...
        "The input looks like a matrix or grid.", ...
        "Matrix and heatmap schemes receive a score boost.");
end
if schema.CategoryCount > 0 && schema.NumericCount >= 1
    rules(end + 1) = localRule("category plus numeric data", ...
        "The table mixes categorical and numeric columns.", ...
        "Bar, ranking, and distribution schemes become candidates.");
end
if schema.NumericCount >= 2 && schema.CategoryCount == 0 && ~schema.HasMatrix
    rules(end + 1) = localRule("two numeric variables", ...
        "The data has multiple numeric columns without categories.", ...
        "Relationship schemes such as scatter plots receive a score boost.");
end
if schema.RowCount > 400 && schema.NumericCount >= 2
    rules(end + 1) = localRule("dense numeric samples", ...
        "The data has many rows and at least two numeric columns.", ...
        "`density_scatter` and `contour_scatter` become stronger candidates.");
end
if any(contains(goal, ["regression", "trend line", "fit", "fitted", "linear", "slope"]))
    rules(end + 1) = localRule("regression goal", ...
        "The goal asks for a fitted line, slope, or regression.", ...
        "`regression_scatter` receives a targeted score boost.");
end
if schema.NumericCount >= 3 && any(contains(goal, ["bubble", "magnitude", "size", "sized", "weight", "third variable", "third numeric"]))
    rules(end + 1) = localRule("third numeric variable", ...
        "The goal asks for magnitude or size and the data has enough numeric columns.", ...
        "`bubble_scatter` receives a targeted score boost.");
end
if schema.HasPositiveNegative
    rules(end + 1) = localRule("signed values", ...
        "Positive and negative numeric values were detected.", ...
        "Signed-area and diverging-bar schemes receive a score boost.");
end
if schema.HasPercent || any(contains(goal, ["percent", "percentage", "composition", "share", "part", "whole"]))
    rules(end + 1) = localRule("part-to-whole goal", ...
        "The data or goal suggests percentages, shares, or composition.", ...
        "Composition schemes receive a score boost.");
end
if schema.TimeCount > 0 && any(contains(goal, ["zoom", "zoomed", "inset", "event", "detail", "local", "anomaly", "window", "highlight"]))
    rules(end + 1) = localRule("local event goal", ...
        "The goal asks for a highlighted event, window, or local detail.", ...
        "`zoomed_inset_line` receives a targeted score boost.");
end
if schema.TimeCount > 0 && any(contains(goal, ["segment", "segmented", "phase", "regime", "stage", "period", "transition"]))
    rules(end + 1) = localRule("phase or segment goal", ...
        "The goal asks for phases, regimes, stages, or transitions.", ...
        "`segmented_line` receives a targeted score boost.");
end
end

function warnings = localWarnings(schema, goal)
warnings = strings(0, 1);

thinTimeSeries = schema.TimeCount > 0 && schema.NumericCount <= 2;
if thinTimeSeries && any(contains(goal, ["panel", "panels", "layout", "multiples", "small multiples"]))
    warnings(end + 1) = "Panel/layout goal may be trivial with this data shape; add grouping variables or multiple measures before using a multi-panel scheme.";
end

if thinTimeSeries && any(contains(goal, ["outlier", "outliers"]))
    warnings(end + 1) = "Outlier goal needs explicit outlier evidence or thresholds; this planner can highlight a local event but does not prove which points are outliers.";
end
end

function rule = localRule(name, reason, effect)
rule = struct('rule', string(name), 'reason', string(reason), 'effect', string(effect));
end
