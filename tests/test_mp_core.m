function tests = test_mp_core
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
matlabDir = fullfile(root, 'skills', 'matlab-plotting-skill', 'assets', 'matlab');
addpath(genpath(matlabDir));
testCase.TestData.Root = root;
end

function testCatalogHasFiftySchemes(testCase)
schemes = mpSchemeCatalog();
verifyEqual(testCase, numel(schemes), 50);
verifyTrue(testCase, any(string({schemes.Name}) == "line_trend"));
verifyTrue(testCase, any(string({schemes.Name}) == "annotated_callout"));
end

function testSelectionForTimeSeries(testCase)
data = mpReadData(fullfile(testCase.TestData.Root, 'examples', 'data', 'time_series.csv'));
schema = mpInferDataSchema(data);
selection = mpSelectScheme(schema, "show a time trend");
verifyEqual(testCase, selection.Selected.Family, "trend");
end

function testLineTrendDemoDataSupportsSchemaAndRender(testCase)
data = mpDemoDataForScheme("line_trend");
verifyTrue(testCase, istable(data));
verifyTrue(testCase, all(ismember(["time", "signal"], string(data.Properties.VariableNames))));
schema = mpInferDataSchema(data);
verifyEqual(testCase, schema.TimeCount, 1);
selection = mpSelectScheme(schema, "show a time trend");
verifyEqual(testCase, string(selection.Selected.Name), "line_trend");
fig = mpRenderScheme("line_trend", data, schema, "demo data");
cleanup = onCleanup(@() close(fig));
verifyNotEmpty(testCase, findobj(fig, 'Type', 'line'));
end

function testMultiLineComparisonDemoDataSupportsWideSeriesRender(testCase)
data = mpDemoDataForScheme("multi_line_comparison");
verifyTrue(testCase, istable(data));
verifyTrue(testCase, all(ismember(["time", "signal", "comparison"], string(data.Properties.VariableNames))));
schema = mpInferDataSchema(data);
verifyEqual(testCase, schema.TimeCount, 1);
verifyGreaterThanOrEqual(testCase, schema.NumericCount, 3);
fig = mpRenderScheme("multi_line_comparison", data, schema, "demo data");
cleanup = onCleanup(@() close(fig));
lines = findobj(fig, 'Type', 'line');
verifyGreaterThanOrEqual(testCase, numel(lines), 2);
end

function testConfidenceBandDemoDataSupportsUncertaintyRender(testCase)
data = mpDemoDataForScheme("confidence_band");
verifyTrue(testCase, istable(data));
verifyTrue(testCase, all(ismember(["time", "center", "lower", "upper"], string(data.Properties.VariableNames))));
verifyTrue(testCase, all(data.lower <= data.center));
verifyTrue(testCase, all(data.center <= data.upper));
schema = mpInferDataSchema(data);
verifyEqual(testCase, schema.TimeCount, 1);
verifyGreaterThanOrEqual(testCase, schema.NumericCount, 4);
fig = mpRenderScheme("confidence_band", data, schema, "demo data");
cleanup = onCleanup(@() close(fig));
verifyNotEmpty(testCase, findobj(fig, 'Type', 'line'));
verifyNotEmpty(testCase, findobj(fig, 'Type', 'patch'));
end

function testZoomedInsetLineDemoDataSupportsLocalDetailRender(testCase)
data = mpDemoDataForScheme("zoomed_inset_line");
verifyTrue(testCase, istable(data));
verifyTrue(testCase, all(ismember(["time", "signal"], string(data.Properties.VariableNames))));
verifyGreaterThanOrEqual(testCase, height(data), 150);
eventWindow = data.time >= 105 & data.time <= 130;
baselineWindow = data.time >= 35 & data.time <= 60;
verifyGreaterThan(testCase, max(data.signal(eventWindow)), max(data.signal(baselineWindow)) + 0.35);
schema = mpInferDataSchema(data);
verifyEqual(testCase, schema.TimeCount, 1);
fig = mpRenderScheme("zoomed_inset_line", data, schema, "demo data");
cleanup = onCleanup(@() close(fig));
verifyGreaterThanOrEqual(testCase, numel(findobj(fig, 'Type', 'axes')), 2);
verifyNotEmpty(testCase, findobj(fig, 'Type', 'rectangle'));
end

function testLineTrendSelectionRulePrefersTimeSeries(testCase)
data = mpDemoDataForScheme("line_trend");
schema = mpInferDataSchema(data);
selection = mpSelectScheme(schema, "show a time trend");
names = string({mpSchemeCatalog().Name});
lineScore = selection.AllScores(names == "line_trend");
scatterScore = selection.AllScores(names == "scatter_relationship");
verifyEqual(testCase, string(selection.Selected.Name), "line_trend");
verifyGreaterThan(testCase, lineScore, scatterScore);
end

function testMultiLineComparisonSelectionRulePrefersWideTimeSeries(testCase)
data = mpDemoDataForScheme("multi_line_comparison");
schema = mpInferDataSchema(data);
selection = mpSelectScheme(schema, "compare multiple time series");
names = string({mpSchemeCatalog().Name});
multiLineScore = selection.AllScores(names == "multi_line_comparison");
lineScore = selection.AllScores(names == "line_trend");
verifyEqual(testCase, string(selection.Selected.Name), "multi_line_comparison");
verifyGreaterThan(testCase, multiLineScore, lineScore);
end

function testConfidenceBandSelectionRulePrefersUncertaintyGoal(testCase)
data = mpDemoDataForScheme("confidence_band");
schema = mpInferDataSchema(data);
selection = mpSelectScheme(schema, "show confidence band with uncertainty bounds");
names = string({mpSchemeCatalog().Name});
confidenceScore = selection.AllScores(names == "confidence_band");
lineScore = selection.AllScores(names == "line_trend");
verifyEqual(testCase, string(selection.Selected.Name), "confidence_band");
verifyGreaterThan(testCase, confidenceScore, lineScore);
end

function testSelectionForMethodComparison(testCase)
data = mpReadData(fullfile(testCase.TestData.Root, 'examples', 'data', 'method_scores.csv'));
schema = mpInferDataSchema(data);
selection = mpSelectScheme(schema, "compare methods");
verifyTrue(testCase, any(selection.Selected.Family == ["bar", "ranking"]));
end

function testRunCreatesOutputs(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-output');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'time_series.csv');
result = mpRun(dataPath, "show time trend", outDir, "png");
verifyTrue(testCase, isfile(result.Files(1)));
verifyTrue(testCase, isfile(fullfile(outDir, 'render_report.md')));
end

function testPlanOnlySelectsWithoutRendering(testCase)
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'time_series.csv');
plan = mpPlan(dataPath, "show a time trend", "", "");
verifyEqual(testCase, string(plan.SelectedScheme), "line_trend");
verifyTrue(testCase, any(string(plan.Alternatives) == "multi_line_comparison"));
verifyEqual(testCase, plan.Schema.TimeCount, 1);
verifyEqual(testCase, string(plan.ScoreSnapshot(1).Name), "line_trend");
end

function testInspectDataSummarizesSchema(testCase)
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'time_series.csv');
inspection = mpInspectData(dataPath, "");
verifyEqual(testCase, string(inspection.FileName), "time_series.csv");
verifyEqual(testCase, string(inspection.Schema.Kind), "table");
verifyEqual(testCase, inspection.Schema.TimeCount, 1);
verifyEqual(testCase, inspection.Schema.NumericCount, 2);
verifyTrue(testCase, any(string(inspection.Schema.VariableNames) == "signal"));
end

function testReportDoesNotExposeAbsoluteDataPath(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-report-privacy');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'time_series.csv');
mpRun(dataPath, "show time trend", outDir, "png");
reportText = fileread(fullfile(outDir, 'render_report.md'));
verifyFalse(testCase, contains(reportText, testCase.TestData.Root));
verifyFalse(testCase, contains(reportText, outDir));
verifyTrue(testCase, contains(reportText, 'time_series.csv'));
verifyTrue(testCase, contains(reportText, 'line_trend.png'));
end

function testRunCreatesMachineReadableReport(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-json-report');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'time_series.csv');
mpRun(dataPath, "show time trend", outDir, "png");
jsonPath = fullfile(outDir, 'render_report.json');
verifyTrue(testCase, isfile(jsonPath));
report = jsondecode(fileread(jsonPath));
verifyEqual(testCase, string(report.selectedScheme), "line_trend");
verifyEqual(testCase, string(report.dataFile), "time_series.csv");
verifyFalse(testCase, contains(fileread(jsonPath), outDir));
end

function testReportIncludesSelectionSignals(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-selection-signals');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'time_series.csv');
mpRun(dataPath, "show time trend", outDir, "png");
reportText = fileread(fullfile(outDir, 'render_report.md'));
verifyTrue(testCase, contains(reportText, 'Selection Signals'));
verifyTrue(testCase, contains(reportText, 'time columns: 1'));
verifyTrue(testCase, contains(reportText, 'goal keywords: trend, time'));
verifyTrue(testCase, contains(reportText, 'Score Snapshot'));
verifyTrue(testCase, contains(reportText, '`line_trend`'));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyTrue(testCase, any(contains(string(jsonReport.selectionSignals), 'time columns: 1')));
verifyTrue(testCase, any(contains(string(jsonReport.selectionSignals), 'goal keywords: trend, time')));
verifyEqual(testCase, string(jsonReport.scoreSnapshot(1).name), "line_trend");
end

function testExplicitSchemeOverridesAutomaticSelection(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-explicit-scheme');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'time_series.csv');
result = mpRun(dataPath, "show a time trend", outDir, "png", "heatmap_matrix");
verifyEqual(testCase, result.SelectedScheme, "heatmap_matrix");
verifyTrue(testCase, isfile(fullfile(outDir, 'heatmap_matrix.png')));
end

function testLineTrendExplicitSchemeCreatesDeterministicOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-explicit-line-trend');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'method_scores.csv');
result = mpRun(dataPath, "force a simple line view", outDir, "png", "line_trend");
verifyEqual(testCase, result.SelectedScheme, "line_trend");
verifyTrue(testCase, isfile(fullfile(outDir, 'line_trend.png')));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyEqual(testCase, string(jsonReport.selectedScheme), "line_trend");
end

function testMultiLineComparisonExplicitSchemeCreatesDeterministicOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-explicit-multi-line');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'multi_series.csv');
result = mpRun(dataPath, "compare multiple time series", outDir, "png", "multi_line_comparison");
verifyEqual(testCase, result.SelectedScheme, "multi_line_comparison");
verifyTrue(testCase, isfile(fullfile(outDir, 'multi_line_comparison.png')));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyEqual(testCase, string(jsonReport.selectedScheme), "multi_line_comparison");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "multi_line_comparison.png")));
end

function testConfidenceBandExplicitSchemeCreatesDeterministicOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-explicit-confidence-band');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'confidence_band.csv');
result = mpRun(dataPath, "show uncertainty bounds", outDir, "png", "confidence_band");
verifyEqual(testCase, result.SelectedScheme, "confidence_band");
verifyTrue(testCase, isfile(fullfile(outDir, 'confidence_band.png')));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyEqual(testCase, string(jsonReport.selectedScheme), "confidence_band");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "confidence_band.png")));
end

function testConfidenceBandPngRenderOutputIsNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-confidence-band-png');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'confidence_band.csv');
mpRun(dataPath, "show uncertainty bounds", outDir, "png", "confidence_band");
pngPath = fullfile(outDir, 'confidence_band.png');
verifyTrue(testCase, isfile(pngPath));
fileInfo = dir(pngPath);
verifyGreaterThan(testCase, fileInfo.bytes, 0);
end

function testConfidenceBandVectorRenderOutputsAreNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-confidence-band-vector');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'confidence_band.csv');
mpRun(dataPath, "show uncertainty bounds", outDir, ["svg", "pdf"], "confidence_band");
for extension = ["svg", "pdf"]
    outputPath = fullfile(outDir, "confidence_band." + extension);
    verifyTrue(testCase, isfile(outputPath));
    fileInfo = dir(outputPath);
    verifyGreaterThan(testCase, fileInfo.bytes, 0);
end
end

function testConfidenceBandReportsNameSchemeAndOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-confidence-band-report');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'confidence_band.csv');
mpRun(dataPath, "show uncertainty bounds", outDir, "png", "confidence_band");
markdownReport = fileread(fullfile(outDir, 'render_report.md'));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyTrue(testCase, contains(markdownReport, '`confidence_band`'));
verifyTrue(testCase, contains(markdownReport, 'confidence_band.png'));
verifyEqual(testCase, string(jsonReport.selectedScheme), "confidence_band");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "confidence_band.png")));
end

function testMultiLineComparisonPngRenderOutputIsNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-multi-line-png');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'multi_series.csv');
mpRun(dataPath, "compare multiple time series", outDir, "png", "multi_line_comparison");
pngPath = fullfile(outDir, 'multi_line_comparison.png');
verifyTrue(testCase, isfile(pngPath));
fileInfo = dir(pngPath);
verifyGreaterThan(testCase, fileInfo.bytes, 0);
end

function testMultiLineComparisonVectorRenderOutputsAreNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-multi-line-vector');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'multi_series.csv');
mpRun(dataPath, "compare multiple time series", outDir, ["svg", "pdf"], "multi_line_comparison");
for extension = ["svg", "pdf"]
    outputPath = fullfile(outDir, "multi_line_comparison." + extension);
    verifyTrue(testCase, isfile(outputPath));
    fileInfo = dir(outputPath);
    verifyGreaterThan(testCase, fileInfo.bytes, 0);
end
end

function testMultiLineComparisonReportsNameSchemeAndOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-multi-line-report');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'multi_series.csv');
mpRun(dataPath, "compare multiple time series", outDir, "png", "multi_line_comparison");
markdownReport = fileread(fullfile(outDir, 'render_report.md'));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyTrue(testCase, contains(markdownReport, '`multi_line_comparison`'));
verifyTrue(testCase, contains(markdownReport, 'multi_line_comparison.png'));
verifyEqual(testCase, string(jsonReport.selectedScheme), "multi_line_comparison");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "multi_line_comparison.png")));
end

function testLineTrendPngRenderOutputIsNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-line-trend-png');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'time_series.csv');
mpRun(dataPath, "show a time trend", outDir, "png", "line_trend");
pngPath = fullfile(outDir, 'line_trend.png');
verifyTrue(testCase, isfile(pngPath));
fileInfo = dir(pngPath);
verifyGreaterThan(testCase, fileInfo.bytes, 0);
end

function testLineTrendVectorRenderOutputsAreNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-line-trend-vector');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'time_series.csv');
mpRun(dataPath, "show a time trend", outDir, ["svg", "pdf"], "line_trend");
for extension = ["svg", "pdf"]
    outputPath = fullfile(outDir, "line_trend." + extension);
    verifyTrue(testCase, isfile(outputPath));
    fileInfo = dir(outputPath);
    verifyGreaterThan(testCase, fileInfo.bytes, 0);
end
end

function testLineTrendReportsNameSchemeAndOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-line-trend-report');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'time_series.csv');
mpRun(dataPath, "show a time trend", outDir, "png", "line_trend");
markdownReport = fileread(fullfile(outDir, 'render_report.md'));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyTrue(testCase, contains(markdownReport, '`line_trend`'));
verifyTrue(testCase, contains(markdownReport, 'line_trend.png'));
verifyEqual(testCase, string(jsonReport.selectedScheme), "line_trend");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "line_trend.png")));
end

function testUnknownExplicitSchemeErrors(testCase)
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'time_series.csv');
verifyError(testCase, @() mpRun(dataPath, "show a time trend", tempdir, "png", "not_a_scheme"), ...
    'mpRun:UnknownScheme');
end

function testMatInput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-mat');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
matrixData = peaks(8); %#ok<NASGU>
matPath = fullfile(tempdir, 'mp_skill_matrix_input.mat');
save(matPath, 'matrixData');
data = mpReadData(matPath);
schema = mpInferDataSchema(data);
selection = mpSelectScheme(schema, "matrix heatmap");
verifyEqual(testCase, selection.Selected.Family, "matrix");
end

function testMatInputAmbiguousVariablesErrorsWithCandidates(testCase)
matrixData = peaks(8); %#ok<NASGU>
vectorData = (1:8)'; %#ok<NASGU>
matPath = fullfile(tempdir, 'mp_skill_ambiguous_input.mat');
save(matPath, 'matrixData', 'vectorData');
try
    mpReadData(matPath);
    verifyFail(testCase, 'Ambiguous MAT input should require explicit selection.');
catch err
    verifyEqual(testCase, err.identifier, 'mpReadData:AmbiguousMatFile');
    verifyTrue(testCase, contains(err.message, 'matrixData'));
    verifyTrue(testCase, contains(err.message, 'vectorData'));
end
end

function testMatInputWithExplicitVariable(testCase)
matrixData = peaks(8); %#ok<NASGU>
vectorData = (1:8)'; %#ok<NASGU>
matPath = fullfile(tempdir, 'mp_skill_explicit_var_input.mat');
save(matPath, 'matrixData', 'vectorData');
data = mpReadData(matPath, "matrixData");
verifyEqual(testCase, size(data), [8 8]);
end

function testExcelInput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-xlsx');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
tbl = table((1:5)', [2; 4; 5; 7; 8], 'VariableNames', {'time', 'signal'});
xlsxPath = fullfile(tempdir, 'mp_skill_time_input.xlsx');
writetable(tbl, xlsxPath);
data = mpReadData(xlsxPath);
schema = mpInferDataSchema(data);
verifyGreaterThanOrEqual(testCase, schema.NumericCount, 2);
end
