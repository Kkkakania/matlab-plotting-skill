function data = mpDemoDataForScheme(schemeName)
%MPDEMODATAFORSCHEME Create synthetic data for any bundled scheme.

schemeName = string(schemeName);
rng(42);

if any(contains(schemeName, ["heatmap", "matrix", "bubble_matrix", "correlation"]))
    x = peaks(12);
    data = x + 0.2 * randn(size(x));
    return
end

if any(contains(schemeName, ["scatter", "pca"]))
    n = 180;
    x = linspace(-2, 2, n)';
    data = table(x, 0.7 * x + 0.45 * randn(n, 1), ...
        categorical(repmat(["A"; "B"; "C"], 60, 1)), abs(randn(n, 1)) + 0.5, ...
        'VariableNames', {'x', 'y', 'group', 'magnitude'});
    return
end

if any(contains(schemeName, ["box", "violin", "ridgeline", "histogram", "density", "jitter", "ecdf"]))
    group = categorical(repelem(["A"; "B"; "C"; "D"], 50));
    [~, ~, gidx] = unique(string(group));
    value = randn(200, 1) + double(gidx) * 0.35;
    data = table(group, value, 'VariableNames', {'group', 'value'});
    return
end

if any(contains(schemeName, ["bar", "ranking", "lollipop", "pareto", "waterfall", "waffle", "composition", "ternary"]))
    data = table(categorical(["Alpha"; "Beta"; "Gamma"; "Delta"; "Epsilon"]), ...
        [18; 25; 13; 30; 14], [9; 14; 8; 17; 11], [0.20; 0.25; 0.15; 0.28; 0.12], ...
        'VariableNames', {'category', 'valueA', 'valueB', 'share'});
    return
end

if any(contains(schemeName, ["radar", "parallel"]))
    data = array2table(rand(6, 5), 'VariableNames', "metric" + string(1:5));
    data.group = categorical("sample" + string((1:6)'));
    return
end

if any(contains(schemeName, ["surface", "contour_map", "quiver"]))
    [x, y] = meshgrid(linspace(-2, 2, 18));
    data = sin(x) .* cos(y);
    return
end

t = (1:120)';
data = table(t, sin(t / 9) + 0.03 * t + 0.12 * randn(size(t)), ...
    cos(t / 12) + 0.02 * t, 'VariableNames', {'time', 'signal', 'comparison'});
end
