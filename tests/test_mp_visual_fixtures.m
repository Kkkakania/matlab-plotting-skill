function tests = test_mp_visual_fixtures
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
matlabDir = fullfile(root, 'skills', 'matlab-plotting-skill', 'assets', 'matlab');
addpath(genpath(matlabDir));

outDir = string(getenv('MP_VISUAL_FIXTURE_DIR'));
if strlength(outDir) == 0
    outDir = fullfile(tempdir, 'mp-visual-fixtures');
end
if exist(outDir, 'dir')
    rmdir(outDir, 's');
end
mkdir(outDir);
testCase.TestData.OutputDir = outDir;
end

function testRepresentativeRendererFixtures(testCase)
schemes = ["line_trend", "grouped_bar", "heatmap_matrix", "density_scatter"];
for k = 1:numel(schemes)
    scheme = schemes(k);
    fixtureDir = fullfile(testCase.TestData.OutputDir, scheme);
    mkdir(fixtureDir);

    data = mpDemoDataForScheme(scheme);
    schema = mpInferDataSchema(data);
    selection = localSelectionForScheme(scheme);
    fig = mpRenderScheme(scheme, data, schema, "visual fixture");
    files = mpExportFigure(fig, fullfile(fixtureDir, scheme), "png");
    close(fig);
    mpWriteReport(fixtureDir, "", "visual fixture", schema, selection, files);

    imagePath = fullfile(fixtureDir, scheme + ".png");
    verifyTrue(testCase, isfile(imagePath), scheme + " PNG should exist");
    fileInfo = dir(imagePath);
    verifyGreaterThan(testCase, fileInfo.bytes, 1024, scheme + " PNG should be non-empty");

    reportText = fileread(fullfile(fixtureDir, 'render_report.md'));
    verifyTrue(testCase, contains(reportText, "`" + scheme + "`"));

    jsonReport = jsondecode(fileread(fullfile(fixtureDir, 'render_report.json')));
    verifyEqual(testCase, string(jsonReport.selectedScheme), scheme);
    verifyTrue(testCase, any(contains(string(jsonReport.outputs), scheme + ".png")));
end
end

function selection = localSelectionForScheme(scheme)
catalog = mpSchemeCatalog();
idx = find(string({catalog.Name}) == scheme, 1);
if isempty(idx)
    error('test_mp_visual_fixtures:UnknownScheme', 'Unknown scheme: %s', scheme);
end
scores = zeros(numel(catalog), 1);
scores(idx) = 100;
altIdx = setdiff(1:numel(catalog), idx, 'stable');
selection = struct();
selection.Selected = catalog(idx);
selection.Score = scores(idx);
selection.Alternatives = catalog(altIdx(1:3));
selection.AllScores = scores;
end
