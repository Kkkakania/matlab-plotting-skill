function report = mpSmokeTest(outputDir, formats)
%MPSMOKETEST Render every scheme with synthetic data.

if nargin < 1 || strlength(string(outputDir)) == 0
    outputDir = "figures/smoke";
end
if nargin < 2 || isempty(formats)
    formats = "png";
end

schemes = mpSchemeCatalog();
passed = false(numel(schemes), 1);
message = strings(numel(schemes), 1);

for k = 1:numel(schemes)
    try
        data = mpDemoDataForScheme(schemes(k).Name);
        schema = mpInferDataSchema(data);
        fig = mpRenderScheme(schemes(k).Name, data, schema, "smoke test");
        files = mpExportFigure(fig, fullfile(string(outputDir), schemes(k).Name), formats);
        close(fig);
        passed(k) = all(isfile(files));
    catch err
        message(k) = string(err.message);
    end
end

report = table(string({schemes.Name})', passed, message, ...
    'VariableNames', {'Scheme', 'Passed', 'Message'});
disp(report);
assert(all(passed), 'mpSmokeTest:Failed', 'Some plotting schemes failed.');
end

