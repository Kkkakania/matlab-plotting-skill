function result = mpBuildCandidatePack(dataPath, goalText, outputDir, formats, candidateCount, variableName)
%MPBUILDCANDIDATEPACK Render ranked alternatives for Codex visual review.

if nargin < 1
    dataPath = "";
end
if nargin < 2 || strlength(string(goalText)) == 0
    goalText = "choose the best scientific figure";
end
if nargin < 3 || strlength(string(outputDir)) == 0
    outputDir = "figures";
end
if nargin < 4 || isempty(formats)
    formats = ["png", "svg"];
end
if nargin < 5 || isempty(candidateCount)
    candidateCount = 3;
end
if nargin < 6 || isempty(variableName)
    variableName = "";
end

validateattributes(candidateCount, {'numeric'}, {'scalar', 'integer', '>=', 2, '<=', 5});
outputDir = string(outputDir);
formats = string(formats);
formats = formats(:);
data = mpReadData(string(dataPath), string(variableName));
schema = mpInferDataSchema(data);
selection = mpSelectScheme(schema, string(goalText));
schemes = mpSchemeCatalog();
[~, order] = sort(selection.AllScores(:), 'descend');
order = order(1:min(candidateCount, numel(order)));

candidatesDir = fullfile(outputDir, "candidates");
if ~exist(candidatesDir, 'dir')
    mkdir(candidatesDir);
end

emptyCandidate = struct( ...
    'id', "", ...
    'rank', 0, ...
    'scheme', "", ...
    'family', "", ...
    'selection_score', 0, ...
    'task', "", ...
    'palette', "", ...
    'files', strings(0, 1));
candidates = repmat(emptyCandidate, 1, numel(order));

for k = 1:numel(order)
    schemeIndex = order(k);
    scheme = schemes(schemeIndex);
    candidateId = "candidate-" + compose('%02d', k);
    stemName = candidateId + "__" + scheme.Name;
    fig = mpRenderScheme(scheme.Name, data, schema, string(goalText));
    cleaner = onCleanup(@() close(fig));
    exported = mpExportFigure(fig, fullfile(candidatesDir, stemName), formats);
    clear cleaner

    relativeFiles = strings(numel(exported), 1);
    for fileIndex = 1:numel(exported)
        [~, fileName, extension] = fileparts(exported(fileIndex));
        relativeFiles(fileIndex) = "candidates/" + fileName + extension;
    end

    candidates(k) = struct( ...
        'id', candidateId, ...
        'rank', k, ...
        'scheme', scheme.Name, ...
        'family', scheme.Family, ...
        'selection_score', selection.AllScores(schemeIndex), ...
        'task', scheme.Task, ...
        'palette', scheme.Palette, ...
        'files', relativeFiles);
end

manifest = struct();
manifest.schema_version = "1.0";
manifest.workflow = "codex-visual-review";
manifest.goal = string(goalText);
manifest.data_file = localFileName(dataPath);
manifest.data_summary = struct( ...
    'kind', schema.Kind, ...
    'rows', schema.RowCount, ...
    'columns', schema.ColumnCount, ...
    'numeric_columns', schema.NumericCount, ...
    'category_columns', schema.CategoryCount, ...
    'time_columns', schema.TimeCount);
manifest.candidates = candidates;

manifestPath = fullfile(outputDir, "candidate_manifest.json");
fid = fopen(manifestPath, 'w');
if fid < 0
    error('mpBuildCandidatePack:OpenFailed', 'Could not write manifest: %s', manifestPath);
end
cleaner = onCleanup(@() fclose(fid));
fprintf(fid, '%s\n', jsonencode(manifest));

result = struct( ...
    'ManifestPath', manifestPath, ...
    'Candidates', candidates);
end

function fileName = localFileName(pathValue)
if strlength(string(pathValue)) == 0
    fileName = "synthetic demo data";
    return
end
[~, name, extension] = fileparts(string(pathValue));
fileName = name + extension;
end
