function tests = test_mp_core
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
matlabDir = fullfile(root, 'skills', 'matlab-plotting-skill', 'assets', 'matlab');
addpath(genpath(matlabDir));
testCase.TestData.Root = root;
end

function testCatalogHasFiftyOneSchemes(testCase)
schemes = mpSchemeCatalog();
verifyEqual(testCase, numel(schemes), 51);
verifyTrue(testCase, any(string({schemes.Name}) == "line_trend"));
verifyTrue(testCase, any(string({schemes.Name}) == "stacked_time_series"));
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

function testStackedTimeSeriesDemoDataSupportsSharedAxisRender(testCase)
data = mpDemoDataForScheme("stacked_time_series");
verifyTrue(testCase, istable(data));
verifyTrue(testCase, all(ismember(["time", "voltage", "current", "power"], string(data.Properties.VariableNames))));
schema = mpInferDataSchema(data);
verifyEqual(testCase, schema.TimeCount, 1);
verifyGreaterThanOrEqual(testCase, schema.NumericCount, 4);
fig = mpRenderScheme("stacked_time_series", data, schema, "demo data");
cleanup = onCleanup(@() close(fig));
axesObjects = findobj(fig, 'Type', 'axes');
verifyGreaterThanOrEqual(testCase, numel(axesObjects), 3);
verifyGreaterThanOrEqual(testCase, numel(findobj(fig, 'Type', 'line')), 3);
end

function testStackedTimeSeriesUsesUnitAwareAxisLabels(testCase)
t = (0:4)';
voltage = 220 + [0; 1; -1; 2; 0];
current = 10 + [0; 0.5; -0.2; 0.3; 0.1];
power = voltage .* current / 1000;
loss = [12; 10; 14; 11; 13];
data = table(t, voltage, current, power, loss, ...
    'VariableNames', {'time_s', 'voltage_V', 'current_A', 'power_kW', 'loss_mW'});
schema = mpInferDataSchema(data);
fig = mpRenderScheme("stacked_time_series", data, schema, "unit-aware labels");
cleanup = onCleanup(@() close(fig));

axesObjects = findobj(fig, 'Type', 'axes');
yLabels = strings(1, numel(axesObjects));
xLabels = strings(1, numel(axesObjects));
for k = 1:numel(axesObjects)
    yLabels(k) = string(axesObjects(k).YLabel.String);
    xLabels(k) = string(axesObjects(k).XLabel.String);
end

verifyTrue(testCase, any(yLabels == "Voltage (V)"));
verifyTrue(testCase, any(yLabels == "Current (A)"));
verifyTrue(testCase, any(yLabels == "Power (kW)"));
verifyTrue(testCase, any(yLabels == "Loss (mW)"));
verifyTrue(testCase, any(xLabels == "Time (s)"));
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

function testPositiveNegativeAreaDemoDataSupportsSignedRender(testCase)
data = mpDemoDataForScheme("positive_negative_area");
verifyTrue(testCase, istable(data));
verifyTrue(testCase, all(ismember(["time", "delta"], string(data.Properties.VariableNames))));
verifyTrue(testCase, any(data.delta > 0));
verifyTrue(testCase, any(data.delta < 0));
schema = mpInferDataSchema(data);
verifyEqual(testCase, schema.TimeCount, 1);
verifyTrue(testCase, schema.HasPositiveNegative);
fig = mpRenderScheme("positive_negative_area", data, schema, "demo data");
cleanup = onCleanup(@() close(fig));
verifyNotEmpty(testCase, findobj(fig, 'Type', 'area'));
end

function testSegmentedLineDemoDataSupportsPhaseRender(testCase)
data = mpDemoDataForScheme("segmented_line");
verifyTrue(testCase, istable(data));
verifyTrue(testCase, all(ismember(["time", "signal", "phase"], string(data.Properties.VariableNames))));
verifyGreaterThanOrEqual(testCase, height(data), 120);
verifyGreaterThanOrEqual(testCase, numel(categories(data.phase)), 3);
verifyTrue(testCase, data.signal(100) > data.signal(50));
schema = mpInferDataSchema(data);
verifyEqual(testCase, schema.TimeCount, 1);
verifyEqual(testCase, schema.CategoryCount, 1);
fig = mpRenderScheme("segmented_line", data, schema, "demo data");
cleanup = onCleanup(@() close(fig));
verifyGreaterThanOrEqual(testCase, numel(findobj(fig, 'Type', 'line')), 3);
end

function testScatterRelationshipDemoDataSupportsXyRender(testCase)
data = mpDemoDataForScheme("scatter_relationship");
verifyTrue(testCase, istable(data));
verifyTrue(testCase, all(ismember(["x", "y"], string(data.Properties.VariableNames))));
schema = mpInferDataSchema(data);
verifyGreaterThanOrEqual(testCase, schema.NumericCount, 2);
verifyGreaterThanOrEqual(testCase, schema.RowCount, 100);
fig = mpRenderScheme("scatter_relationship", data, schema, "demo data");
cleanup = onCleanup(@() close(fig));
verifyNotEmpty(testCase, findobj(fig, 'Type', 'scatter'));
end

function testGroupedScatterDemoDataSupportsGroupedXyRender(testCase)
data = mpDemoDataForScheme("grouped_scatter");
verifyTrue(testCase, istable(data));
verifyTrue(testCase, all(ismember(["x", "y", "group"], string(data.Properties.VariableNames))));
verifyGreaterThanOrEqual(testCase, numel(categories(data.group)), 3);
schema = mpInferDataSchema(data);
verifyGreaterThanOrEqual(testCase, schema.NumericCount, 2);
verifyEqual(testCase, schema.CategoryCount, 1);
fig = mpRenderScheme("grouped_scatter", data, schema, "demo data");
cleanup = onCleanup(@() close(fig));
verifyGreaterThanOrEqual(testCase, numel(findobj(fig, 'Type', 'scatter')), 3);
verifyNotEmpty(testCase, findobj(fig, 'Type', 'legend'));
end

function testDensityScatterDemoDataSupportsDenseXyRender(testCase)
data = mpDemoDataForScheme("density_scatter");
verifyTrue(testCase, istable(data));
verifyTrue(testCase, all(ismember(["x", "y"], string(data.Properties.VariableNames))));
verifyGreaterThanOrEqual(testCase, height(data), 500);
schema = mpInferDataSchema(data);
verifyGreaterThanOrEqual(testCase, schema.NumericCount, 2);
fig = mpRenderScheme("density_scatter", data, schema, "demo data");
cleanup = onCleanup(@() close(fig));
verifyNotEmpty(testCase, findobj(fig, 'Type', 'scatter'));
verifyNotEmpty(testCase, findobj(fig, 'Type', 'colorbar'));
end

function testContourScatterDemoDataSupportsLocalStructureRender(testCase)
data = mpDemoDataForScheme("contour_scatter");
verifyTrue(testCase, istable(data));
verifyTrue(testCase, all(ismember(["x", "y"], string(data.Properties.VariableNames))));
verifyGreaterThanOrEqual(testCase, height(data), 450);
schema = mpInferDataSchema(data);
verifyGreaterThanOrEqual(testCase, schema.NumericCount, 2);
fig = mpRenderScheme("contour_scatter", data, schema, "demo data");
cleanup = onCleanup(@() close(fig));
verifyNotEmpty(testCase, findobj(fig, 'Type', 'scatter'));
verifyGreaterThan(testCase, numel(findall(fig)), 12);
end

function testRegressionScatterDemoDataSupportsTrendLineRender(testCase)
data = mpDemoDataForScheme("regression_scatter");
verifyTrue(testCase, istable(data));
verifyTrue(testCase, all(ismember(["x", "y"], string(data.Properties.VariableNames))));
schema = mpInferDataSchema(data);
verifyGreaterThanOrEqual(testCase, schema.NumericCount, 2);
fig = mpRenderScheme("regression_scatter", data, schema, "demo data");
cleanup = onCleanup(@() close(fig));
verifyNotEmpty(testCase, findobj(fig, 'Type', 'scatter'));
verifyNotEmpty(testCase, findobj(fig, 'Type', 'line'));
end

function testBubbleScatterDemoDataSupportsMagnitudeRender(testCase)
data = mpDemoDataForScheme("bubble_scatter");
verifyTrue(testCase, istable(data));
verifyTrue(testCase, all(ismember(["x", "y", "magnitude"], string(data.Properties.VariableNames))));
schema = mpInferDataSchema(data);
verifyGreaterThanOrEqual(testCase, schema.NumericCount, 3);
fig = mpRenderScheme("bubble_scatter", data, schema, "demo data");
cleanup = onCleanup(@() close(fig));
verifyNotEmpty(testCase, findobj(fig, 'Type', 'scatter'));
verifyNotEmpty(testCase, findobj(fig, 'Type', 'colorbar'));
end

function testCandidatePackWritesRankedRelativeManifest(testCase)
outputDir = string(tempname);
mkdir(outputDir);
cleanup = onCleanup(@() rmdir(outputDir, 's'));
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'multi_series.csv');

result = mpBuildCandidatePack(dataPath, "compare three methods over time", ...
    outputDir, "png", 3, "");

verifyEqual(testCase, string(result.ManifestPath), fullfile(outputDir, "candidate_manifest.json"));
verifyTrue(testCase, isfile(result.ManifestPath));
manifest = jsondecode(fileread(result.ManifestPath));
verifyEqual(testCase, string(manifest.schema_version), "1.0");
verifyEqual(testCase, string(manifest.workflow), "codex-visual-review");
verifyEqual(testCase, numel(manifest.candidates), 3);
verifyEqual(testCase, string({manifest.candidates.id}), ...
    ["candidate-01", "candidate-02", "candidate-03"]);
verifyEqual(testCase, string(manifest.candidates(1).scheme), "multi_line_comparison");
for k = 1:numel(manifest.candidates)
    files = string(manifest.candidates(k).files);
    verifyTrue(testCase, all(startsWith(files, "candidates/")));
    verifyFalse(testCase, any(startsWith(files, "/")));
    verifyTrue(testCase, all(isfile(fullfile(outputDir, files))));
end
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

function testStackedTimeSeriesSelectionRulePrefersSharedAxisGoal(testCase)
data = mpDemoDataForScheme("stacked_time_series");
schema = mpInferDataSchema(data);
selection = mpSelectScheme(schema, "show stacked synchronized voltage current power signals on one shared time axis");
names = string({mpSchemeCatalog().Name});
stackedScore = selection.AllScores(names == "stacked_time_series");
multiLineScore = selection.AllScores(names == "multi_line_comparison");
lineScore = selection.AllScores(names == "line_trend");
verifyEqual(testCase, string(selection.Selected.Name), "stacked_time_series");
verifyGreaterThan(testCase, stackedScore, multiLineScore);
verifyGreaterThan(testCase, stackedScore, lineScore);
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

function testZoomedInsetLineSelectionRulePrefersLocalEventGoal(testCase)
data = mpDemoDataForScheme("zoomed_inset_line");
schema = mpInferDataSchema(data);
selection = mpSelectScheme(schema, "show a zoomed inset for the local anomaly window");
names = string({mpSchemeCatalog().Name});
zoomScore = selection.AllScores(names == "zoomed_inset_line");
lineScore = selection.AllScores(names == "line_trend");
verifyEqual(testCase, string(selection.Selected.Name), "zoomed_inset_line");
verifyGreaterThan(testCase, zoomScore, lineScore);
end

function testPositiveNegativeAreaSelectionRulePrefersSignedChangeGoal(testCase)
data = mpDemoDataForScheme("positive_negative_area");
schema = mpInferDataSchema(data);
selection = mpSelectScheme(schema, "show signed delta around zero over time");
names = string({mpSchemeCatalog().Name});
areaScore = selection.AllScores(names == "positive_negative_area");
lineScore = selection.AllScores(names == "line_trend");
barScore = selection.AllScores(names == "diverging_bar");
verifyEqual(testCase, string(selection.Selected.Name), "positive_negative_area");
verifyGreaterThan(testCase, areaScore, lineScore);
verifyGreaterThan(testCase, areaScore, barScore);
end

function testSegmentedLineSelectionRulePrefersPhaseGoal(testCase)
data = mpDemoDataForScheme("segmented_line");
schema = mpInferDataSchema(data);
selection = mpSelectScheme(schema, "show phase and regime changes over time");
names = string({mpSchemeCatalog().Name});
segmentedScore = selection.AllScores(names == "segmented_line");
lineScore = selection.AllScores(names == "line_trend");
verifyEqual(testCase, string(selection.Selected.Name), "segmented_line");
verifyGreaterThan(testCase, segmentedScore, lineScore);
end

function testScatterRelationshipSelectionRulePrefersTwoNumericVariables(testCase)
x = linspace(-2, 2, 120)';
y = 0.65 * x + 0.25 * sin(3 * x);
data = table(x, y, 'VariableNames', {'x', 'y'});
schema = mpInferDataSchema(data);
selection = mpSelectScheme(schema, "show the relationship between two numeric variables");
names = string({mpSchemeCatalog().Name});
scatterScore = selection.AllScores(names == "scatter_relationship");
densityScore = selection.AllScores(names == "density_scatter");
verifyEqual(testCase, string(selection.Selected.Name), "scatter_relationship");
verifyGreaterThanOrEqual(testCase, scatterScore, densityScore);
end

function testGroupedScatterSelectionRulePrefersGroupedXyGoal(testCase)
data = mpDemoDataForScheme("grouped_scatter");
schema = mpInferDataSchema(data);
selection = mpSelectScheme(schema, "show grouped scatter relationship by group");
names = string({mpSchemeCatalog().Name});
groupedScatterScore = selection.AllScores(names == "grouped_scatter");
groupedBarScore = selection.AllScores(names == "grouped_bar");
scatterScore = selection.AllScores(names == "scatter_relationship");
verifyEqual(testCase, string(selection.Selected.Name), "grouped_scatter");
verifyGreaterThan(testCase, groupedScatterScore, groupedBarScore);
verifyGreaterThan(testCase, groupedScatterScore, scatterScore);
end

function testDensityScatterSelectionRulePrefersDenseSamples(testCase)
data = mpDemoDataForScheme("density_scatter");
schema = mpInferDataSchema(data);
selection = mpSelectScheme(schema, "show dense overlapping x-y samples");
names = string({mpSchemeCatalog().Name});
densityScore = selection.AllScores(names == "density_scatter");
scatterScore = selection.AllScores(names == "scatter_relationship");
verifyEqual(testCase, string(selection.Selected.Name), "density_scatter");
verifyGreaterThan(testCase, densityScore, scatterScore);
end

function testContourScatterSelectionRulePrefersLocalDensityContours(testCase)
data = mpDemoDataForScheme("contour_scatter");
schema = mpInferDataSchema(data);
selection = mpSelectScheme(schema, "show local density contours for overlapping points");
names = string({mpSchemeCatalog().Name});
contourScore = selection.AllScores(names == "contour_scatter");
densityScore = selection.AllScores(names == "density_scatter");
verifyEqual(testCase, string(selection.Selected.Name), "contour_scatter");
verifyGreaterThan(testCase, contourScore, densityScore);
end

function testRegressionScatterSelectionRulePrefersTrendLineGoal(testCase)
data = mpDemoDataForScheme("regression_scatter");
schema = mpInferDataSchema(data);
selection = mpSelectScheme(schema, "show an x-y regression trend line with fitted slope");
names = string({mpSchemeCatalog().Name});
regressionScore = selection.AllScores(names == "regression_scatter");
scatterScore = selection.AllScores(names == "scatter_relationship");
verifyEqual(testCase, string(selection.Selected.Name), "regression_scatter");
verifyGreaterThan(testCase, regressionScore, scatterScore);
end

function testBubbleScatterSelectionRulePrefersMagnitudeGoal(testCase)
data = mpDemoDataForScheme("bubble_scatter");
schema = mpInferDataSchema(data);
selection = mpSelectScheme(schema, "show x-y relationship with bubble size for magnitude");
names = string({mpSchemeCatalog().Name});
bubbleScore = selection.AllScores(names == "bubble_scatter");
scatterScore = selection.AllScores(names == "scatter_relationship");
verifyEqual(testCase, string(selection.Selected.Name), "bubble_scatter");
verifyGreaterThan(testCase, bubbleScore, scatterScore);
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
verifyTrue(testCase, isfield(plan, 'Explanation'));
verifyTrue(testCase, contains(string(plan.Explanation.selectedReason), "line_trend"));
verifyTrue(testCase, any(contains(string(plan.Explanation.schemaSignals), "time_columns=1")));
verifyEqual(testCase, string(plan.ScoreSnapshot(1).Name), "line_trend");
end

function testPlanExplanationFormatsForCli(testCase)
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'time_series.csv');
plan = mpPlan(dataPath, "show a time trend", "", "");
text = mpFormatPlanExplanation(plan);
verifyTrue(testCase, contains(text, "Selection explanation"));
verifyTrue(testCase, contains(text, "Selected scheme: line_trend"));
verifyTrue(testCase, contains(text, "Matched rules:"));
verifyTrue(testCase, contains(text, "time-series data"));
verifyTrue(testCase, contains(text, "Top score snapshot:"));
end

function testPlanWarnsWhenPanelGoalHasThinTimeSeries(testCase)
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'time_series.csv');
plan = mpPlan(dataPath, "show this in three small panels", "", "");
verifyTrue(testCase, isfield(plan.Explanation, 'warnings'));
verifyTrue(testCase, any(contains(string(plan.Explanation.warnings), "Panel/layout goal may be trivial")));
text = mpFormatPlanExplanation(plan);
verifyTrue(testCase, contains(text, "Warnings:"));
verifyTrue(testCase, contains(text, "Panel/layout goal may be trivial"));
end

function testPlanWarnsWhenOutlierGoalNeedsSupport(testCase)
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'time_series.csv');
plan = mpPlan(dataPath, "highlight outliers", "", "");
verifyTrue(testCase, isfield(plan.Explanation, 'warnings'));
verifyTrue(testCase, any(contains(string(plan.Explanation.warnings), "Outlier goal needs explicit outlier evidence")));
text = mpFormatPlanExplanation(plan);
verifyTrue(testCase, contains(text, "Warnings:"));
verifyTrue(testCase, contains(text, "Outlier goal needs explicit outlier evidence"));
end

function testInspectDataSummarizesSchema(testCase)
dataPath = fullfile(testCase.TestData.Root, 'examples', 'data', 'time_series.csv');
inspection = mpInspectData(dataPath, "");
verifyEqual(testCase, string(inspection.FileName), "time_series.csv");
verifyEqual(testCase, string(inspection.Schema.Kind), "table");
verifyEqual(testCase, inspection.Schema.TimeCount, 1);
verifyEqual(testCase, inspection.Schema.NumericCount, 2);
verifyTrue(testCase, any(string(inspection.Schema.VariableNames) == "signal"));
verifyEqual(testCase, string(inspection.RoleHint), "looks like a single time series");
verifyTrue(testCase, contains(string(inspection.NextCommandHint), "--plan-only"));
verifyTrue(testCase, contains(string(inspection.NextCommandHint), "--data time_series.csv"));
verifyTrue(testCase, contains(string(inspection.NextCommandHint), 'show a time trend'));
verifyFalse(testCase, contains(string(inspection.NextCommandHint), testCase.TestData.Root));
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
verifyEqual(testCase, string(report.schema_version), "1.0");
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
verifyTrue(testCase, contains(reportText, 'Selection Explanation'));
verifyTrue(testCase, contains(reportText, 'time columns: 1'));
verifyTrue(testCase, contains(reportText, 'goal keywords: trend, time'));
verifyTrue(testCase, contains(reportText, 'Score Snapshot'));
verifyTrue(testCase, contains(reportText, '`line_trend`'));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyTrue(testCase, any(contains(string(jsonReport.selectionSignals), 'time columns: 1')));
verifyTrue(testCase, any(contains(string(jsonReport.selectionSignals), 'goal keywords: trend, time')));
verifyTrue(testCase, isfield(jsonReport, 'selectionExplanation'));
verifyTrue(testCase, contains(string(jsonReport.selectionExplanation.selectedReason), "line_trend"));
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

function testZoomedInsetLineExplicitSchemeCreatesDeterministicOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-explicit-zoomed-inset');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_zoomed_inset_input.csv');
writetable(mpDemoDataForScheme("zoomed_inset_line"), dataPath);
result = mpRun(dataPath, "show a zoomed local event", outDir, "png", "zoomed_inset_line");
verifyEqual(testCase, result.SelectedScheme, "zoomed_inset_line");
verifyTrue(testCase, isfile(fullfile(outDir, 'zoomed_inset_line.png')));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyEqual(testCase, string(jsonReport.selectedScheme), "zoomed_inset_line");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "zoomed_inset_line.png")));
end

function testPositiveNegativeAreaExplicitSchemeCreatesDeterministicOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-explicit-positive-negative');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_positive_negative_input.csv');
writetable(mpDemoDataForScheme("positive_negative_area"), dataPath);
result = mpRun(dataPath, "show signed change around zero", outDir, "png", "positive_negative_area");
verifyEqual(testCase, result.SelectedScheme, "positive_negative_area");
verifyTrue(testCase, isfile(fullfile(outDir, 'positive_negative_area.png')));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyEqual(testCase, string(jsonReport.selectedScheme), "positive_negative_area");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "positive_negative_area.png")));
end

function testSegmentedLineExplicitSchemeCreatesDeterministicOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-explicit-segmented-line');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_segmented_line_input.csv');
writetable(mpDemoDataForScheme("segmented_line"), dataPath);
result = mpRun(dataPath, "show phase changes over time", outDir, "png", "segmented_line");
verifyEqual(testCase, result.SelectedScheme, "segmented_line");
verifyTrue(testCase, isfile(fullfile(outDir, 'segmented_line.png')));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyEqual(testCase, string(jsonReport.selectedScheme), "segmented_line");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "segmented_line.png")));
end

function testScatterRelationshipExplicitSchemeCreatesDeterministicOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-explicit-scatter-relationship');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_scatter_relationship_input.csv');
writetable(mpDemoDataForScheme("scatter_relationship"), dataPath);
result = mpRun(dataPath, "show x-y relationship", outDir, "png", "scatter_relationship");
verifyEqual(testCase, result.SelectedScheme, "scatter_relationship");
verifyTrue(testCase, isfile(fullfile(outDir, 'scatter_relationship.png')));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyEqual(testCase, string(jsonReport.selectedScheme), "scatter_relationship");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "scatter_relationship.png")));
end

function testScatterRelationshipPngRenderOutputIsNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-scatter-relationship-png');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_scatter_relationship_png_input.csv');
writetable(mpDemoDataForScheme("scatter_relationship"), dataPath);
mpRun(dataPath, "show x-y relationship", outDir, "png", "scatter_relationship");
pngPath = fullfile(outDir, 'scatter_relationship.png');
verifyTrue(testCase, isfile(pngPath));
fileInfo = dir(pngPath);
verifyGreaterThan(testCase, fileInfo.bytes, 0);
end

function testScatterRelationshipVectorRenderOutputsAreNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-scatter-relationship-vector');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_scatter_relationship_vector_input.csv');
writetable(mpDemoDataForScheme("scatter_relationship"), dataPath);
mpRun(dataPath, "show x-y relationship", outDir, ["svg", "pdf"], "scatter_relationship");
for extension = ["svg", "pdf"]
    outputPath = fullfile(outDir, "scatter_relationship." + extension);
    verifyTrue(testCase, isfile(outputPath));
    fileInfo = dir(outputPath);
    verifyGreaterThan(testCase, fileInfo.bytes, 0);
end
end

function testScatterRelationshipReportsNameSchemeAndOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-scatter-relationship-report');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_scatter_relationship_report_input.csv');
writetable(mpDemoDataForScheme("scatter_relationship"), dataPath);
mpRun(dataPath, "show x-y relationship", outDir, "png", "scatter_relationship");
markdownReport = fileread(fullfile(outDir, 'render_report.md'));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyTrue(testCase, contains(markdownReport, '`scatter_relationship`'));
verifyTrue(testCase, contains(markdownReport, 'scatter_relationship.png'));
verifyEqual(testCase, string(jsonReport.selectedScheme), "scatter_relationship");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "scatter_relationship.png")));
end

function testGroupedScatterExplicitSchemeCreatesDeterministicOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-explicit-grouped-scatter');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_grouped_scatter_input.csv');
writetable(mpDemoDataForScheme("grouped_scatter"), dataPath);
result = mpRun(dataPath, "show grouped x-y relationship", outDir, "png", "grouped_scatter");
verifyEqual(testCase, result.SelectedScheme, "grouped_scatter");
verifyTrue(testCase, isfile(fullfile(outDir, 'grouped_scatter.png')));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyEqual(testCase, string(jsonReport.selectedScheme), "grouped_scatter");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "grouped_scatter.png")));
end

function testGroupedScatterPngRenderOutputIsNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-grouped-scatter-png');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_grouped_scatter_png_input.csv');
writetable(mpDemoDataForScheme("grouped_scatter"), dataPath);
mpRun(dataPath, "show grouped x-y relationship", outDir, "png", "grouped_scatter");
pngPath = fullfile(outDir, 'grouped_scatter.png');
verifyTrue(testCase, isfile(pngPath));
fileInfo = dir(pngPath);
verifyGreaterThan(testCase, fileInfo.bytes, 0);
end

function testGroupedScatterVectorRenderOutputsAreNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-grouped-scatter-vector');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_grouped_scatter_vector_input.csv');
writetable(mpDemoDataForScheme("grouped_scatter"), dataPath);
mpRun(dataPath, "show grouped x-y relationship", outDir, ["svg", "pdf"], "grouped_scatter");
for extension = ["svg", "pdf"]
    outputPath = fullfile(outDir, "grouped_scatter." + extension);
    verifyTrue(testCase, isfile(outputPath));
    fileInfo = dir(outputPath);
    verifyGreaterThan(testCase, fileInfo.bytes, 0);
end
end

function testGroupedScatterReportsNameSchemeAndOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-grouped-scatter-report');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_grouped_scatter_report_input.csv');
writetable(mpDemoDataForScheme("grouped_scatter"), dataPath);
mpRun(dataPath, "show grouped x-y relationship", outDir, "png", "grouped_scatter");
markdownReport = fileread(fullfile(outDir, 'render_report.md'));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyTrue(testCase, contains(markdownReport, '`grouped_scatter`'));
verifyTrue(testCase, contains(markdownReport, 'grouped_scatter.png'));
verifyEqual(testCase, string(jsonReport.selectedScheme), "grouped_scatter");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "grouped_scatter.png")));
end

function testDensityScatterExplicitSchemeCreatesDeterministicOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-explicit-density-scatter');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_density_scatter_input.csv');
writetable(mpDemoDataForScheme("density_scatter"), dataPath);
result = mpRun(dataPath, "show dense x-y samples", outDir, "png", "density_scatter");
verifyEqual(testCase, result.SelectedScheme, "density_scatter");
verifyTrue(testCase, isfile(fullfile(outDir, 'density_scatter.png')));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyEqual(testCase, string(jsonReport.selectedScheme), "density_scatter");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "density_scatter.png")));
end

function testDensityScatterPngRenderOutputIsNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-density-scatter-png');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_density_scatter_png_input.csv');
writetable(mpDemoDataForScheme("density_scatter"), dataPath);
mpRun(dataPath, "show dense x-y samples", outDir, "png", "density_scatter");
pngPath = fullfile(outDir, 'density_scatter.png');
verifyTrue(testCase, isfile(pngPath));
fileInfo = dir(pngPath);
verifyGreaterThan(testCase, fileInfo.bytes, 0);
end

function testDensityScatterVectorRenderOutputsAreNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-density-scatter-vector');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_density_scatter_vector_input.csv');
writetable(mpDemoDataForScheme("density_scatter"), dataPath);
mpRun(dataPath, "show dense x-y samples", outDir, ["svg", "pdf"], "density_scatter");
for extension = ["svg", "pdf"]
    outputPath = fullfile(outDir, "density_scatter." + extension);
    verifyTrue(testCase, isfile(outputPath));
    fileInfo = dir(outputPath);
    verifyGreaterThan(testCase, fileInfo.bytes, 0);
end
end

function testDensityScatterReportsNameSchemeAndOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-density-scatter-report');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_density_scatter_report_input.csv');
writetable(mpDemoDataForScheme("density_scatter"), dataPath);
mpRun(dataPath, "show dense x-y samples", outDir, "png", "density_scatter");
markdownReport = fileread(fullfile(outDir, 'render_report.md'));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyTrue(testCase, contains(markdownReport, '`density_scatter`'));
verifyTrue(testCase, contains(markdownReport, 'density_scatter.png'));
verifyEqual(testCase, string(jsonReport.selectedScheme), "density_scatter");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "density_scatter.png")));
end

function testContourScatterExplicitSchemeCreatesDeterministicOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-explicit-contour-scatter');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_contour_scatter_input.csv');
writetable(mpDemoDataForScheme("contour_scatter"), dataPath);
result = mpRun(dataPath, "show local density contours", outDir, "png", "contour_scatter");
verifyEqual(testCase, result.SelectedScheme, "contour_scatter");
verifyTrue(testCase, isfile(fullfile(outDir, 'contour_scatter.png')));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyEqual(testCase, string(jsonReport.selectedScheme), "contour_scatter");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "contour_scatter.png")));
end

function testContourScatterPngRenderOutputIsNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-contour-scatter-png');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_contour_scatter_png_input.csv');
writetable(mpDemoDataForScheme("contour_scatter"), dataPath);
mpRun(dataPath, "show local density contours", outDir, "png", "contour_scatter");
pngPath = fullfile(outDir, 'contour_scatter.png');
verifyTrue(testCase, isfile(pngPath));
fileInfo = dir(pngPath);
verifyGreaterThan(testCase, fileInfo.bytes, 0);
end

function testContourScatterVectorRenderOutputsAreNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-contour-scatter-vector');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_contour_scatter_vector_input.csv');
writetable(mpDemoDataForScheme("contour_scatter"), dataPath);
mpRun(dataPath, "show local density contours", outDir, ["svg", "pdf"], "contour_scatter");
for extension = ["svg", "pdf"]
    outputPath = fullfile(outDir, "contour_scatter." + extension);
    verifyTrue(testCase, isfile(outputPath));
    fileInfo = dir(outputPath);
    verifyGreaterThan(testCase, fileInfo.bytes, 0);
end
end

function testContourScatterReportsNameSchemeAndOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-contour-scatter-report');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_contour_scatter_report_input.csv');
writetable(mpDemoDataForScheme("contour_scatter"), dataPath);
mpRun(dataPath, "show local density contours", outDir, "png", "contour_scatter");
markdownReport = fileread(fullfile(outDir, 'render_report.md'));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyTrue(testCase, contains(markdownReport, '`contour_scatter`'));
verifyTrue(testCase, contains(markdownReport, 'contour_scatter.png'));
verifyEqual(testCase, string(jsonReport.selectedScheme), "contour_scatter");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "contour_scatter.png")));
end

function testRegressionScatterExplicitSchemeCreatesDeterministicOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-explicit-regression-scatter');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_regression_scatter_input.csv');
writetable(mpDemoDataForScheme("regression_scatter"), dataPath);
result = mpRun(dataPath, "show a regression trend line", outDir, "png", "regression_scatter");
verifyEqual(testCase, result.SelectedScheme, "regression_scatter");
verifyTrue(testCase, isfile(fullfile(outDir, 'regression_scatter.png')));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyEqual(testCase, string(jsonReport.selectedScheme), "regression_scatter");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "regression_scatter.png")));
end

function testRegressionScatterPngRenderOutputIsNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-regression-scatter-png');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_regression_scatter_png_input.csv');
writetable(mpDemoDataForScheme("regression_scatter"), dataPath);
mpRun(dataPath, "show a regression trend line", outDir, "png", "regression_scatter");
pngPath = fullfile(outDir, 'regression_scatter.png');
verifyTrue(testCase, isfile(pngPath));
fileInfo = dir(pngPath);
verifyGreaterThan(testCase, fileInfo.bytes, 0);
end

function testRegressionScatterVectorRenderOutputsAreNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-regression-scatter-vector');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_regression_scatter_vector_input.csv');
writetable(mpDemoDataForScheme("regression_scatter"), dataPath);
mpRun(dataPath, "show a regression trend line", outDir, ["svg", "pdf"], "regression_scatter");
for extension = ["svg", "pdf"]
    outputPath = fullfile(outDir, "regression_scatter." + extension);
    verifyTrue(testCase, isfile(outputPath));
    fileInfo = dir(outputPath);
    verifyGreaterThan(testCase, fileInfo.bytes, 0);
end
end

function testRegressionScatterReportsNameSchemeAndOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-regression-scatter-report');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_regression_scatter_report_input.csv');
writetable(mpDemoDataForScheme("regression_scatter"), dataPath);
mpRun(dataPath, "show a regression trend line", outDir, "png", "regression_scatter");
markdownReport = fileread(fullfile(outDir, 'render_report.md'));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyTrue(testCase, contains(markdownReport, '`regression_scatter`'));
verifyTrue(testCase, contains(markdownReport, 'regression_scatter.png'));
verifyEqual(testCase, string(jsonReport.selectedScheme), "regression_scatter");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "regression_scatter.png")));
end

function testBubbleScatterExplicitSchemeCreatesDeterministicOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-explicit-bubble-scatter');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_bubble_scatter_input.csv');
writetable(mpDemoDataForScheme("bubble_scatter"), dataPath);
result = mpRun(dataPath, "show bubble magnitude relationship", outDir, "png", "bubble_scatter");
verifyEqual(testCase, result.SelectedScheme, "bubble_scatter");
verifyTrue(testCase, isfile(fullfile(outDir, 'bubble_scatter.png')));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyEqual(testCase, string(jsonReport.selectedScheme), "bubble_scatter");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "bubble_scatter.png")));
end

function testBubbleScatterPngRenderOutputIsNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-bubble-scatter-png');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_bubble_scatter_png_input.csv');
writetable(mpDemoDataForScheme("bubble_scatter"), dataPath);
mpRun(dataPath, "show bubble magnitude relationship", outDir, "png", "bubble_scatter");
pngPath = fullfile(outDir, 'bubble_scatter.png');
verifyTrue(testCase, isfile(pngPath));
fileInfo = dir(pngPath);
verifyGreaterThan(testCase, fileInfo.bytes, 0);
end

function testBubbleScatterVectorRenderOutputsAreNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-bubble-scatter-vector');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_bubble_scatter_vector_input.csv');
writetable(mpDemoDataForScheme("bubble_scatter"), dataPath);
mpRun(dataPath, "show bubble magnitude relationship", outDir, ["svg", "pdf"], "bubble_scatter");
for extension = ["svg", "pdf"]
    outputPath = fullfile(outDir, "bubble_scatter." + extension);
    verifyTrue(testCase, isfile(outputPath));
    fileInfo = dir(outputPath);
    verifyGreaterThan(testCase, fileInfo.bytes, 0);
end
end

function testBubbleScatterReportsNameSchemeAndOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-bubble-scatter-report');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_bubble_scatter_report_input.csv');
writetable(mpDemoDataForScheme("bubble_scatter"), dataPath);
mpRun(dataPath, "show bubble magnitude relationship", outDir, "png", "bubble_scatter");
markdownReport = fileread(fullfile(outDir, 'render_report.md'));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyTrue(testCase, contains(markdownReport, '`bubble_scatter`'));
verifyTrue(testCase, contains(markdownReport, 'bubble_scatter.png'));
verifyEqual(testCase, string(jsonReport.selectedScheme), "bubble_scatter");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "bubble_scatter.png")));
end

function testSegmentedLinePngRenderOutputIsNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-segmented-line-png');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_segmented_line_png_input.csv');
writetable(mpDemoDataForScheme("segmented_line"), dataPath);
mpRun(dataPath, "show phase changes over time", outDir, "png", "segmented_line");
pngPath = fullfile(outDir, 'segmented_line.png');
verifyTrue(testCase, isfile(pngPath));
fileInfo = dir(pngPath);
verifyGreaterThan(testCase, fileInfo.bytes, 0);
end

function testSegmentedLineVectorRenderOutputsAreNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-segmented-line-vector');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_segmented_line_vector_input.csv');
writetable(mpDemoDataForScheme("segmented_line"), dataPath);
mpRun(dataPath, "show phase changes over time", outDir, ["svg", "pdf"], "segmented_line");
for extension = ["svg", "pdf"]
    outputPath = fullfile(outDir, "segmented_line." + extension);
    verifyTrue(testCase, isfile(outputPath));
    fileInfo = dir(outputPath);
    verifyGreaterThan(testCase, fileInfo.bytes, 0);
end
end

function testSegmentedLineReportsNameSchemeAndOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-segmented-line-report');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_segmented_line_report_input.csv');
writetable(mpDemoDataForScheme("segmented_line"), dataPath);
mpRun(dataPath, "show phase changes over time", outDir, "png", "segmented_line");
markdownReport = fileread(fullfile(outDir, 'render_report.md'));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyTrue(testCase, contains(markdownReport, '`segmented_line`'));
verifyTrue(testCase, contains(markdownReport, 'segmented_line.png'));
verifyEqual(testCase, string(jsonReport.selectedScheme), "segmented_line");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "segmented_line.png")));
end

function testPositiveNegativeAreaPngRenderOutputIsNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-positive-negative-png');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_positive_negative_png_input.csv');
writetable(mpDemoDataForScheme("positive_negative_area"), dataPath);
mpRun(dataPath, "show signed change around zero", outDir, "png", "positive_negative_area");
pngPath = fullfile(outDir, 'positive_negative_area.png');
verifyTrue(testCase, isfile(pngPath));
fileInfo = dir(pngPath);
verifyGreaterThan(testCase, fileInfo.bytes, 0);
end

function testPositiveNegativeAreaVectorRenderOutputsAreNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-positive-negative-vector');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_positive_negative_vector_input.csv');
writetable(mpDemoDataForScheme("positive_negative_area"), dataPath);
mpRun(dataPath, "show signed change around zero", outDir, ["svg", "pdf"], "positive_negative_area");
for extension = ["svg", "pdf"]
    outputPath = fullfile(outDir, "positive_negative_area." + extension);
    verifyTrue(testCase, isfile(outputPath));
    fileInfo = dir(outputPath);
    verifyGreaterThan(testCase, fileInfo.bytes, 0);
end
end

function testPositiveNegativeAreaReportsNameSchemeAndOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-positive-negative-report');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_positive_negative_report_input.csv');
writetable(mpDemoDataForScheme("positive_negative_area"), dataPath);
mpRun(dataPath, "show signed change around zero", outDir, "png", "positive_negative_area");
markdownReport = fileread(fullfile(outDir, 'render_report.md'));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyTrue(testCase, contains(markdownReport, '`positive_negative_area`'));
verifyTrue(testCase, contains(markdownReport, 'positive_negative_area.png'));
verifyEqual(testCase, string(jsonReport.selectedScheme), "positive_negative_area");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "positive_negative_area.png")));
end

function testZoomedInsetLinePngRenderOutputIsNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-zoomed-inset-png');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_zoomed_inset_png_input.csv');
writetable(mpDemoDataForScheme("zoomed_inset_line"), dataPath);
mpRun(dataPath, "show a zoomed local event", outDir, "png", "zoomed_inset_line");
pngPath = fullfile(outDir, 'zoomed_inset_line.png');
verifyTrue(testCase, isfile(pngPath));
fileInfo = dir(pngPath);
verifyGreaterThan(testCase, fileInfo.bytes, 0);
end

function testZoomedInsetLineVectorRenderOutputsAreNonEmpty(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-zoomed-inset-vector');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_zoomed_inset_vector_input.csv');
writetable(mpDemoDataForScheme("zoomed_inset_line"), dataPath);
mpRun(dataPath, "show a zoomed local event", outDir, ["svg", "pdf"], "zoomed_inset_line");
for extension = ["svg", "pdf"]
    outputPath = fullfile(outDir, "zoomed_inset_line." + extension);
    verifyTrue(testCase, isfile(outputPath));
    fileInfo = dir(outputPath);
    verifyGreaterThan(testCase, fileInfo.bytes, 0);
end
end

function testZoomedInsetLineReportsNameSchemeAndOutput(testCase)
outDir = fullfile(tempdir, 'mp-skill-test-zoomed-inset-report');
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
dataPath = fullfile(tempdir, 'mp_skill_zoomed_inset_report_input.csv');
writetable(mpDemoDataForScheme("zoomed_inset_line"), dataPath);
mpRun(dataPath, "show a zoomed local event", outDir, "png", "zoomed_inset_line");
markdownReport = fileread(fullfile(outDir, 'render_report.md'));
jsonReport = jsondecode(fileread(fullfile(outDir, 'render_report.json')));
verifyTrue(testCase, contains(markdownReport, '`zoomed_inset_line`'));
verifyTrue(testCase, contains(markdownReport, 'zoomed_inset_line.png'));
verifyEqual(testCase, string(jsonReport.selectedScheme), "zoomed_inset_line");
verifyTrue(testCase, any(contains(string(jsonReport.outputs), "zoomed_inset_line.png")));
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
