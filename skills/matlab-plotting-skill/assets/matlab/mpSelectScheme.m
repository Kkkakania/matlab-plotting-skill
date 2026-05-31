function selection = mpSelectScheme(schema, goalText)
%MPSELECTSCHEME Select one plotting scheme and a few alternatives.

schemes = mpSchemeCatalog();
goal = lower(string(goalText));
scores = zeros(numel(schemes), 1);

for k = 1:numel(schemes)
    s = schemes(k);
    haystack = lower(s.Name + " " + s.Family + " " + s.Task + " " + strjoin(s.Tags, " "));
    words = split(regexprep(goal, '[^a-z0-9_]+', ' '));
    words(words == "") = [];
    for w = 1:numel(words)
        if contains(haystack, words(w))
            scores(k) = scores(k) + 4;
        end
    end
    if contains(goal, s.Name)
        scores(k) = scores(k) + 100;
    end
end

if schema.TimeCount > 0
    scores = addFamily(scores, schemes, "trend", 24);
    scores(nameIndex(schemes, "line_trend")) = scores(nameIndex(schemes, "line_trend")) + 8;
    if schema.NumericCount >= 3
        scores(nameIndex(schemes, "multi_line_comparison")) = scores(nameIndex(schemes, "multi_line_comparison")) + 8;
    end
end
if any(contains(goal, ["trend", "time", "series", "signal"]))
    scores = addFamily(scores, schemes, "trend", 12);
    scores(nameIndex(schemes, "line_trend")) = scores(nameIndex(schemes, "line_trend")) + 8;
end
if schema.TimeCount > 0 && any(contains(goal, ["confidence", "uncertainty", "band", "interval", "bounds"]))
    scores(nameIndex(schemes, "confidence_band")) = scores(nameIndex(schemes, "confidence_band")) + 36;
end
if schema.TimeCount > 0 && schema.NumericCount >= 3 && ...
        any(contains(goal, ["compare", "comparison", "multiple", "methods", "series"]))
    scores(nameIndex(schemes, "multi_line_comparison")) = scores(nameIndex(schemes, "multi_line_comparison")) + 28;
end
if schema.HasMatrix
    scores = addFamily(scores, schemes, "matrix", 14);
end
if schema.CategoryCount > 0 && schema.NumericCount >= 1
    scores = addFamily(scores, schemes, "bar", 12);
    scores = addFamily(scores, schemes, "ranking", 9);
    scores = addFamily(scores, schemes, "distribution", 5);
end
if schema.CategoryCount > 0 && schema.NumericCount > 1
    scores(nameIndex(schemes, "grouped_bar")) = scores(nameIndex(schemes, "grouped_bar")) + 10;
    scores(nameIndex(schemes, "grouped_error_bar")) = scores(nameIndex(schemes, "grouped_error_bar")) + 6;
end
if schema.CategoryCount > 0 && schema.NumericCount >= 2 && ...
        any(contains(goal, ["scatter", "relationship", "group", "grouped", "cluster", "cohort"]))
    scores = addFamily(scores, schemes, "relationship", 10);
    scores(nameIndex(schemes, "grouped_scatter")) = scores(nameIndex(schemes, "grouped_scatter")) + 34;
end
if any(contains(goal, ["compare", "comparison", "method", "methods"]))
    scores = addFamily(scores, schemes, "bar", 8);
    scores(nameIndex(schemes, "grouped_bar")) = scores(nameIndex(schemes, "grouped_bar")) + 8;
end
if schema.NumericCount >= 2 && schema.CategoryCount == 0 && ~schema.HasMatrix
    scores = addFamily(scores, schemes, "relationship", 12);
end
if schema.RowCount > 400 && schema.NumericCount >= 2
    scores(nameIndex(schemes, "density_scatter")) = scores(nameIndex(schemes, "density_scatter")) + 8;
    scores(nameIndex(schemes, "contour_scatter")) = scores(nameIndex(schemes, "contour_scatter")) + 6;
end
if schema.HasPositiveNegative
    scores(nameIndex(schemes, "positive_negative_area")) = scores(nameIndex(schemes, "positive_negative_area")) + 8;
    scores(nameIndex(schemes, "diverging_bar")) = scores(nameIndex(schemes, "diverging_bar")) + 8;
end
if schema.TimeCount > 0 && schema.HasPositiveNegative && any(contains(goal, ...
        ["signed", "delta", "deviation", "residual", "zero", "positive", "negative", "net", "change"]))
    scores(nameIndex(schemes, "positive_negative_area")) = scores(nameIndex(schemes, "positive_negative_area")) + 32;
end
if schema.HasPercent || any(contains(goal, ["percent", "percentage", "composition", "share", "part", "whole"]))
    scores = addFamily(scores, schemes, "composition", 10);
end
if schema.TimeCount > 0 && any(contains(goal, ...
        ["zoom", "zoomed", "inset", "event", "detail", "local", "anomaly", "window", "highlight"]))
    scores(nameIndex(schemes, "zoomed_inset_line")) = scores(nameIndex(schemes, "zoomed_inset_line")) + 32;
end
if schema.TimeCount > 0 && any(contains(goal, ...
        ["segment", "segmented", "phase", "regime", "stage", "period", "transition"]))
    scores(nameIndex(schemes, "segmented_line")) = scores(nameIndex(schemes, "segmented_line")) + 36;
end
if any(contains(goal, ["paper", "panel", "overview", "layout"]))
    scores = addFamily(scores, schemes, "layout", 15);
end

if all(scores == 0)
    scores(nameIndex(schemes, "line_trend")) = 1;
end

[~, order] = sort(scores, 'descend');
selection = struct();
selection.Selected = schemes(order(1));
selection.Score = scores(order(1));
selection.Alternatives = schemes(order(2:min(4, numel(order))));
selection.AllScores = scores;
end

function scores = addFamily(scores, schemes, family, amount)
for k = 1:numel(schemes)
    if schemes(k).Family == family
        scores(k) = scores(k) + amount;
    end
end
end

function idx = nameIndex(schemes, name)
idx = find(string({schemes.Name}) == string(name), 1);
end
