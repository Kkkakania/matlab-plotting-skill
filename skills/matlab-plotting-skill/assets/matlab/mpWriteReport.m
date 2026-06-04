function reportPath = mpWriteReport(outputDir, dataPath, goalText, schema, selection, files)
%MPWRITEREPORT Write a compact markdown render report.

if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

if strlength(string(dataPath)) > 0
    dataFile = localFileName(dataPath);
else
    dataFile = "synthetic demo data";
end
outputFiles = localFileNames(files);
selectionSignals = localSelectionSignals(schema, goalText);
scoreSnapshot = localScoreSnapshot(selection);
explanation = mpExplainSelection(schema, goalText, selection);

reportPath = fullfile(outputDir, 'render_report.md');
fid = fopen(reportPath, 'w');
if fid < 0
    error('mpWriteReport:OpenFailed', 'Could not write report: %s', reportPath);
end
cleaner = onCleanup(@() fclose(fid));

fprintf(fid, '# Render Report\n\n');
fprintf(fid, '- Selected scheme: `%s`\n', selection.Selected.Name);
fprintf(fid, '- Scheme family: `%s`\n', selection.Selected.Family);
fprintf(fid, '- Palette: `%s`\n', selection.Selected.Palette);
fprintf(fid, '- Goal: %s\n', string(goalText));
fprintf(fid, '- Data file: `%s`\n', dataFile);
fprintf(fid, '\n## Data Summary\n\n');
fprintf(fid, '- Kind: %s\n', schema.Kind);
fprintf(fid, '- Rows: %d\n', schema.RowCount);
fprintf(fid, '- Columns: %d\n', schema.ColumnCount);
fprintf(fid, '- Numeric columns: %d\n', schema.NumericCount);
fprintf(fid, '- Category columns: %d\n', schema.CategoryCount);
fprintf(fid, '- Time columns: %d\n', schema.TimeCount);
fprintf(fid, '\n## Selection Signals\n\n');
for k = 1:numel(selectionSignals)
    fprintf(fid, '- %s\n', selectionSignals(k));
end
fprintf(fid, '\n## Score Snapshot\n\n');
for k = 1:numel(scoreSnapshot)
    fprintf(fid, '- `%s` (%s): %.0f\n', ...
        string(scoreSnapshot(k).name), string(scoreSnapshot(k).family), scoreSnapshot(k).score);
end
fprintf(fid, '\n## Selection Explanation\n\n');
fprintf(fid, '- %s\n', string(explanation.selectedReason));
fprintf(fid, '- %s\n', string(explanation.caution));
for k = 1:numel(explanation.matchedRules)
    rule = explanation.matchedRules(k);
    fprintf(fid, '- %s: %s %s\n', string(rule.rule), string(rule.reason), string(rule.effect));
end
fprintf(fid, '\n## Alternatives\n\n');
for k = 1:numel(selection.Alternatives)
    fprintf(fid, '- `%s` - %s\n', selection.Alternatives(k).Name, selection.Alternatives(k).Task);
end
fprintf(fid, '\n## Outputs\n\n');
for k = 1:numel(outputFiles)
    fprintf(fid, '- `%s`\n', outputFiles(k));
end

jsonPath = fullfile(outputDir, 'render_report.json');
jsonFid = fopen(jsonPath, 'w');
if jsonFid < 0
    error('mpWriteReport:OpenFailed', 'Could not write report: %s', jsonPath);
end
jsonCleaner = onCleanup(@() fclose(jsonFid));

summary = struct();
summary.schema_version = '1.0';
summary.selectedScheme = char(selection.Selected.Name);
summary.schemeFamily = char(selection.Selected.Family);
summary.palette = char(selection.Selected.Palette);
summary.goal = char(string(goalText));
summary.dataFile = char(dataFile);
summary.dataSummary = struct( ...
    'kind', char(schema.Kind), ...
    'rows', schema.RowCount, ...
    'columns', schema.ColumnCount, ...
    'numericColumns', schema.NumericCount, ...
    'categoryColumns', schema.CategoryCount, ...
    'timeColumns', schema.TimeCount);
summary.selectionSignals = cellstr(selectionSignals);
summary.selectionExplanation = explanation;
summary.scoreSnapshot = scoreSnapshot;
summary.alternatives = localAlternatives(selection);
summary.outputs = cellstr(outputFiles);

fprintf(jsonFid, '%s\n', jsonencode(summary));
end

function snapshot = localScoreSnapshot(selection)
schemes = mpSchemeCatalog();
scores = selection.AllScores(:);
[~, order] = sort(scores, 'descend');
limit = min(5, numel(order));
snapshot = repmat(struct('name', '', 'family', '', 'score', 0), 1, limit);
for k = 1:limit
    idx = order(k);
    snapshot(k).name = char(schemes(idx).Name);
    snapshot(k).family = char(schemes(idx).Family);
    snapshot(k).score = scores(idx);
end
end

function signals = localSelectionSignals(schema, goalText)
signals = strings(0, 1);
signals(end + 1) = "data kind: " + string(schema.Kind);
signals(end + 1) = "numeric columns: " + string(schema.NumericCount);
signals(end + 1) = "category columns: " + string(schema.CategoryCount);
signals(end + 1) = "time columns: " + string(schema.TimeCount);
if schema.HasMatrix
    signals(end + 1) = "matrix-like data: yes";
end
if schema.HasPositiveNegative
    signals(end + 1) = "positive and negative values: yes";
end
if schema.HasPercent
    signals(end + 1) = "percent-like values: yes";
end

keywords = ["trend", "time", "series", "compare", "comparison", "method", ...
    "matrix", "heatmap", "percent", "composition", "share", "ranking", ...
    "distribution", "scatter", "zoom", "event", "paper", "panel"];
goal = lower(string(goalText));
hitMask = false(size(keywords));
for k = 1:numel(keywords)
    hitMask(k) = contains(goal, keywords(k));
end
hits = keywords(hitMask);
if ~isempty(hits)
    signals(end + 1) = "goal keywords: " + strjoin(unique(hits, 'stable'), ", ");
end
end

function fileName = localFileName(pathValue)
[~, name, ext] = fileparts(string(pathValue));
fileName = name + ext;
end

function fileNames = localFileNames(files)
fileNames = strings(numel(files), 1);
for k = 1:numel(files)
    fileNames(k) = localFileName(files(k));
end
end

function alternatives = localAlternatives(selection)
alternatives = repmat(struct('name', '', 'task', ''), 1, numel(selection.Alternatives));
for k = 1:numel(selection.Alternatives)
    alternatives(k).name = char(selection.Alternatives(k).Name);
    alternatives(k).task = char(selection.Alternatives(k).Task);
end
end
