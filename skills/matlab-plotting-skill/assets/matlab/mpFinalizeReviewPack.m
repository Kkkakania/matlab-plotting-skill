function result = mpFinalizeReviewPack(dataPath, goalText, manifestPath, reviewPath, outputDir, formats, variableName)
%MPFINALIZEREVIEWPACK Apply a validated review and write comparison evidence.

if nargin < 7 || isempty(variableName)
    variableName = "";
end
if nargin < 6 || isempty(formats)
    formats = ["png", "svg"];
end

manifest = localReadJson(manifestPath, 'candidate manifest');
review = localReadJson(reviewPath, 'validated review');
localValidateInputs(manifest, review);

candidates = manifest.candidates;
candidateIds = string({candidates.id});
selectedIndex = find(candidateIds == string(review.selected_candidate), 1);
if isempty(selectedIndex)
    error('mpFinalizeReviewPack:UnknownCandidate', ...
        'Selected candidate is not present in the manifest.');
end
selected = candidates(selectedIndex);
beforeFiles = string(selected.files);
beforeIndex = find(endsWith(lower(beforeFiles), ".png"), 1);
if isempty(beforeIndex)
    error('mpFinalizeReviewPack:MissingPng', ...
        'Selected candidate must include a PNG for comparison evidence.');
end
beforeRelative = beforeFiles(beforeIndex);
beforePath = fullfile(string(outputDir), beforeRelative);
if ~isfile(beforePath)
    error('mpFinalizeReviewPack:MissingCandidate', ...
        'Selected candidate image is missing: %s', beforeRelative);
end

data = mpReadData(string(dataPath), string(variableName));
schema = mpInferDataSchema(data);
fig = mpRenderScheme(string(selected.scheme), data, schema, string(goalText));
figCleanup = onCleanup(@() close(fig));
appliedActions = mpApplyReviewFixes(fig, review);

formats = string(formats);
formats = unique([formats(:); "png"], 'stable');
finalDir = fullfile(string(outputDir), "final");
finalFiles = mpExportFigure(fig, fullfile(finalDir, string(selected.scheme)), formats);
clear figCleanup

finalPngIndex = find(endsWith(lower(finalFiles), ".png"), 1);
comparisonPath = fullfile(string(outputDir), "before_after.png");
localWriteComparison(beforePath, finalFiles(finalPngIndex), comparisonPath, selected.scheme);

afterRelative = strings(numel(finalFiles), 1);
for k = 1:numel(finalFiles)
    [~, name, extension] = fileparts(finalFiles(k));
    afterRelative(k) = "final/" + name + extension;
end

evidence = struct();
evidence.schema_version = "1.0";
evidence.workflow = "generate-review-repair-evidence";
evidence.goal = string(goalText);
evidence.data_file = localFileName(dataPath);
evidence.selected_candidate = string(review.selected_candidate);
evidence.selected_scheme = string(selected.scheme);
evidence.verdict = string(review.verdict);
evidence.reviewer = review.reviewer;
evidence.summary = string(review.summary);
evidence.scores = review.scores;
evidence.findings = review.findings;
evidence.applied_actions = appliedActions;
evidence.before_file = beforeRelative;
evidence.after_files = afterRelative;
evidence.comparison_file = "before_after.png";

evidenceJsonPath = fullfile(string(outputDir), "review_evidence.json");
localWriteJson(evidenceJsonPath, evidence);
evidenceMarkdownPath = fullfile(string(outputDir), "review_evidence.md");
localWriteMarkdown(evidenceMarkdownPath, evidence);

result = struct( ...
    'SelectedScheme', string(selected.scheme), ...
    'AppliedActions', appliedActions, ...
    'FinalFiles', finalFiles, ...
    'ComparisonPath', comparisonPath, ...
    'EvidenceJsonPath', evidenceJsonPath, ...
    'EvidenceMarkdownPath', evidenceMarkdownPath);
end

function value = localReadJson(pathValue, label)
if ~isfile(pathValue)
    error('mpFinalizeReviewPack:MissingInput', 'Missing %s: %s', label, pathValue);
end
try
    value = jsondecode(fileread(pathValue));
catch exception
    error('mpFinalizeReviewPack:InvalidJson', ...
        'Could not decode %s: %s', label, exception.message);
end
end

function localValidateInputs(manifest, review)
if ~isstruct(manifest) || ~isfield(manifest, 'schema_version') || ...
        string(manifest.schema_version) ~= "1.0" || ~isfield(manifest, 'candidates')
    error('mpFinalizeReviewPack:InvalidManifest', ...
        'Candidate manifest must use schema version 1.0 and include candidates.');
end
if ~isstruct(review) || ~isfield(review, 'schema_version') || ...
        string(review.schema_version) ~= "1.0" || ~isfield(review, 'validation') || ...
        ~isfield(review.validation, 'status') || string(review.validation.status) ~= "validated"
    error('mpFinalizeReviewPack:UnvalidatedReview', ...
        'Review must be schema version 1.0 and validated before finalization.');
end
required = ["selected_candidate", "verdict", "reviewer", "summary", ...
    "scores", "findings", "repair_actions"];
for k = 1:numel(required)
    if ~isfield(review, required(k))
        error('mpFinalizeReviewPack:InvalidReview', ...
            'Validated review is missing %s.', required(k));
    end
end
end

function localWriteComparison(beforePath, afterPath, outputPath, schemeName)
beforeImage = imread(beforePath);
afterImage = imread(afterPath);
comparison = figure('Visible', 'off', 'Color', 'w', 'Units', 'centimeters', ...
    'Position', [2 2 24 9]);
cleanup = onCleanup(@() close(comparison));
layout = tiledlayout(comparison, 1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
beforeAxes = nexttile(layout);
image(beforeAxes, beforeImage);
axis(beforeAxes, 'image', 'off');
beforeTitle = title(beforeAxes, 'Before review', 'FontWeight', 'bold');
beforeTitle.Color = [0.16 0.16 0.16];
afterAxes = nexttile(layout);
image(afterAxes, afterImage);
axis(afterAxes, 'image', 'off');
afterTitle = title(afterAxes, 'After validated repair', 'FontWeight', 'bold');
afterTitle.Color = [0.16 0.16 0.16];
schemeLabel = char(strrep(string(schemeName), "_", " "));
schemeLabel(1) = upper(schemeLabel(1));
mainTitle = sgtitle(comparison, schemeLabel, 'FontWeight', 'bold');
mainTitle.Color = [0.16 0.16 0.16];
exportgraphics(comparison, outputPath, 'Resolution', 180);
end

function localWriteJson(pathValue, value)
fid = fopen(pathValue, 'w');
if fid < 0
    error('mpFinalizeReviewPack:OpenFailed', 'Could not write evidence: %s', pathValue);
end
cleanup = onCleanup(@() fclose(fid));
fprintf(fid, '%s\n', jsonencode(value));
end

function localWriteMarkdown(pathValue, evidence)
fid = fopen(pathValue, 'w');
if fid < 0
    error('mpFinalizeReviewPack:OpenFailed', 'Could not write evidence: %s', pathValue);
end
cleanup = onCleanup(@() fclose(fid));
fprintf(fid, '# Plot Review Evidence\n\n');
fprintf(fid, '- Workflow: `generate -> review -> repair -> evidence`\n');
fprintf(fid, '- Selected candidate: `%s`\n', evidence.selected_candidate);
fprintf(fid, '- Selected scheme: `%s`\n', evidence.selected_scheme);
fprintf(fid, '- Review surface: `%s`\n', string(evidence.reviewer.surface));
fprintf(fid, '- Review model: `%s`\n', string(evidence.reviewer.model));
fprintf(fid, '- Verdict: `%s`\n', evidence.verdict);
fprintf(fid, '- Data file: `%s`\n', evidence.data_file);
fprintf(fid, '\n## Review Summary\n\n%s\n', evidence.summary);
fprintf(fid, '\n## Applied Repairs\n\n');
if isempty(evidence.applied_actions)
    fprintf(fid, '- None; the selected candidate was accepted as rendered.\n');
else
    for k = 1:numel(evidence.applied_actions)
        fprintf(fid, '- `%s`\n', evidence.applied_actions(k));
    end
end
fprintf(fid, '\n## Artifacts\n\n');
fprintf(fid, '- Before: `%s`\n', evidence.before_file);
for k = 1:numel(evidence.after_files)
    fprintf(fid, '- Final: `%s`\n', evidence.after_files(k));
end
fprintf(fid, '- Comparison: `%s`\n', evidence.comparison_file);
end

function fileName = localFileName(pathValue)
[~, name, extension] = fileparts(string(pathValue));
fileName = name + extension;
end
