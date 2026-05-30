function files = mpExportFigure(fig, outputStem, formats)
%MPEXPORTFIGURE Export a figure to requested formats.

formats = lower(string(formats(:)));
formats(formats == "") = [];
[outDir, ~, ~] = fileparts(outputStem);
if strlength(string(outDir)) > 0 && ~exist(outDir, 'dir')
    mkdir(outDir);
end

files = strings(numel(formats), 1);
for k = 1:numel(formats)
    fmt = formats(k);
    outPath = string(outputStem) + "." + fmt;
    switch fmt
        case "png"
            exportgraphics(fig, outPath, 'Resolution', 180);
        case "pdf"
            exportgraphics(fig, outPath, 'ContentType', 'vector');
        case "svg"
            print(fig, outPath, '-dsvg');
        otherwise
            error('mpExportFigure:UnsupportedFormat', 'Unsupported format: %s', fmt);
    end
    files(k) = outPath;
end
end

