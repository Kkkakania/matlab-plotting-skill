function reportPath = mpWriteReport(outputDir, dataPath, goalText, schema, selection, files)
%MPWRITEREPORT Write a compact markdown render report.

if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

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
if strlength(string(dataPath)) > 0
    fprintf(fid, '- Data file: `%s`\n', string(dataPath));
else
    fprintf(fid, '- Data file: synthetic demo data\n');
end
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
for k = 1:numel(files)
    fprintf(fid, '- `%s`\n', files(k));
end
end

