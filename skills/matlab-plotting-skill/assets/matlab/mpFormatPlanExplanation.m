function text = mpFormatPlanExplanation(plan)
%MPFORMATPLANEXPLANATION Format a plan explanation for CLI output.

lineCount = 14 + numel(plan.Explanation.schemaSignals) + ...
    numel(plan.Explanation.matchedRules) + numel(plan.ScoreSnapshot);
if ~isempty(plan.Explanation.goalKeywords)
    lineCount = lineCount + 3;
end
lines = strings(lineCount, 1);
idx = 0;

idx = idx + 1; lines(idx) = "Selection explanation";
idx = idx + 1; lines(idx) = "Selected scheme: " + string(plan.SelectedScheme);
idx = idx + 1; lines(idx) = "Selected family: " + string(plan.SelectedFamily);
idx = idx + 1; lines(idx) = "Palette: " + string(plan.SelectedPalette);
idx = idx + 1; lines(idx) = "";
idx = idx + 1; lines(idx) = "Why this scheme:";
idx = idx + 1; lines(idx) = "- " + string(plan.Explanation.selectedReason);
idx = idx + 1; lines(idx) = "- " + string(plan.Explanation.caution);
idx = idx + 1; lines(idx) = "";
idx = idx + 1; lines(idx) = "Schema signals:";
for k = 1:numel(plan.Explanation.schemaSignals)
    idx = idx + 1; lines(idx) = "- " + string(plan.Explanation.schemaSignals(k));
end

if ~isempty(plan.Explanation.goalKeywords)
    idx = idx + 1; lines(idx) = "";
    idx = idx + 1; lines(idx) = "Goal keywords:";
    idx = idx + 1; lines(idx) = "- " + strjoin(string(plan.Explanation.goalKeywords), ", ");
end

idx = idx + 1; lines(idx) = "";
idx = idx + 1; lines(idx) = "Matched rules:";
for k = 1:numel(plan.Explanation.matchedRules)
    rule = plan.Explanation.matchedRules(k);
    idx = idx + 1; lines(idx) = "- " + string(rule.rule) + ": " + string(rule.reason) + " " + string(rule.effect);
end

idx = idx + 1; lines(idx) = "";
idx = idx + 1; lines(idx) = "Top score snapshot:";
for k = 1:numel(plan.ScoreSnapshot)
    item = plan.ScoreSnapshot(k);
    idx = idx + 1; lines(idx) = "- " + string(item.Name) + " (" + string(item.Family) + "): " + string(item.Score);
end

lines = lines(1:idx);
text = strjoin(lines, newline);
end
