function result = mpRun(dataPath, goalText, outputDir, formats)
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

data = mpReadData(string(dataPath));
schema = mpInferDataSchema(data);
selection = mpSelectScheme(schema, string(goalText));
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

