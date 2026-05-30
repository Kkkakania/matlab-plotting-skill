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
summary.alternatives = localAlternatives(selection);
summary.outputs = cellstr(outputFiles);

fprintf(jsonFid, '%s\n', jsonencode(summary));
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
