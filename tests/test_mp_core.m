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
