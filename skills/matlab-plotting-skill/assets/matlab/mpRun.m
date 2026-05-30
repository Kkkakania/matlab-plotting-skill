function result = mpRun(dataPath, goalText, outputDir, formats, schemeName, variableName)
%MPRUN Read data, select a plotting scheme, render, export, and report.

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
if nargin < 5 || isempty(schemeName)
    schemeName = "";
end
if nargin < 6 || isempty(variableName)
    variableName = "";
end

data = mpReadData(string(dataPath), string(variableName));
schema = mpInferDataSchema(data);
selection = chooseSelection(schema, string(goalText), string(schemeName));
fig = mpRenderScheme(selection.Selected.Name, data, schema, string(goalText));
files = mpExportFigure(fig, fullfile(string(outputDir), selection.Selected.Name), string(formats));
close(fig);

reportPath = mpWriteReport(string(outputDir), dataPath, goalText, schema, selection, files);

result = struct( ...
    'SelectedScheme', selection.Selected.Name, ...
    'Alternatives', string({selection.Alternatives.Name}), ...
    'Files', files, ...
    'ReportPath', reportPath);
end

function selection = chooseSelection(schema, goalText, schemeName)
autoSelection = mpSelectScheme(schema, goalText);
if strlength(schemeName) == 0
    selection = autoSelection;
    return
end

schemes = mpSchemeCatalog();
idx = find(string({schemes.Name}) == schemeName, 1);
if isempty(idx)
    error('mpRun:UnknownScheme', 'Unknown plotting scheme: %s', schemeName);
end

candidates = [autoSelection.Selected; autoSelection.Alternatives(:)];
keep = string({candidates.Name}) ~= schemeName;
selection = struct();
selection.Selected = schemes(idx);
selection.Score = NaN;
selection.Alternatives = candidates(keep);
selection.AllScores = autoSelection.AllScores;
end
