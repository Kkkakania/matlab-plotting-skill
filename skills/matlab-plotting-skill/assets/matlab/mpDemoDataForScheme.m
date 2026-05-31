function data = mpDemoDataForScheme(schemeName)
%MPDEMODATAFORSCHEME Create synthetic data for any bundled scheme.

schemeName = string(schemeName);
rng(42);

if any(contains(schemeName, ["heatmap", "matrix", "bubble_matrix", "correlation"]))
    x = peaks(12);
    data = x + 0.2 * randn(size(x));
    return
end

if schemeName == "grouped_scatter"
    nPerGroup = 70;
    groupNames = ["low"; "mid"; "high"];
    group = categorical(repelem(groupNames, nPerGroup), groupNames);
    [~, ~, groupIndex] = unique(string(group));
    x = randn(numel(group), 1) * 0.55 + double(groupIndex) * 0.8 - 1.6;
    y = 0.55 * x + double(groupIndex) * 0.42 + 0.34 * randn(numel(group), 1);
    magnitude = abs(y - mean(y)) + 0.35;
    data = table(x, y, group, magnitude, ...
        'VariableNames', {'x', 'y', 'group', 'magnitude'});
    return
end

if schemeName == "density_scatter"
    n = 720;
    cluster = randi(3, n, 1);
    centers = [-1.15 -0.75; 0.20 0.15; 1.05 0.85];
    x = centers(cluster, 1) + 0.42 * randn(n, 1);
    y = centers(cluster, 2) + 0.55 * randn(n, 1) + 0.35 * x;
    data = table(x, y, 'VariableNames', {'x', 'y'});
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

if schemeName == "confidence_band"
    t = (1:80)';
    center = 0.35 * sin(t / 8) + 0.015 * t;
    spread = 0.12 + 0.03 * cos(t / 10);
    data = table(t, center, center - spread, center + spread, ...
        'VariableNames', {'time', 'center', 'lower', 'upper'});
    return
end

if schemeName == "positive_negative_area"
    t = (1:120)';
    delta = 0.55 * sin(t / 8) + 0.22 * cos(t / 19) - 0.08 * sin(t / 3);
    data = table(t, delta, 'VariableNames', {'time', 'delta'});
    return
end

if schemeName == "segmented_line"
    t = (1:150)';
    phase = strings(size(t));
    phase(t <= 50) = "baseline";
    phase(t > 50 & t <= 100) = "intervention";
    phase(t > 100) = "recovery";
    signal = zeros(size(t));
    signal(t <= 50) = 0.18 + 0.012 * t(t <= 50) + 0.08 * sin(t(t <= 50) / 7);
    mid = t > 50 & t <= 100;
    signal(mid) = 1.05 + 0.026 * (t(mid) - 50) + 0.10 * sin(t(mid) / 6);
    late = t > 100;
    signal(late) = 2.20 - 0.010 * (t(late) - 100) + 0.09 * sin(t(late) / 8);
    data = table(t, signal, categorical(phase), ...
        'VariableNames', {'time', 'signal', 'phase'});
    return
end

if schemeName == "zoomed_inset_line"
    t = (1:180)';
    localEvent = 0.85 * exp(-((t - 118) / 9) .^ 2);
    signal = 0.012 * t + 0.42 * sin(t / 15) + localEvent + 0.035 * randn(size(t));
    data = table(t, signal, 'VariableNames', {'time', 'signal'});
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
