function fig = mpRenderScheme(schemeName, data, ~, ~)
%MPRENDERSCHEME Render one selected plotting scheme.

schemeName = string(schemeName);
scheme = findScheme(schemeName);
fig = figure('Visible', 'off', 'Color', 'w', 'Units', 'centimeters', ...
    'Position', [2 2 15 9]);

switch scheme.Family
    case "trend"
        renderTrend(fig, schemeName, data);
    case "relationship"
        renderRelationship(fig, schemeName, data);
    case "matrix"
        renderMatrix(fig, schemeName, data);
    case "bar"
        renderBar(fig, schemeName, data);
    case "distribution"
        renderDistribution(fig, schemeName, data);
    case {"ranking", "composition"}
        renderRankingComposition(fig, schemeName, data);
    case "multivariate"
        renderMultivariate(fig, schemeName, data);
    case "spatial"
        renderSpatial(fig, schemeName, data);
    case "layout"
        renderLayout(fig, schemeName, data);
    otherwise
        renderTrend(fig, "line_trend", data);
end

sgtitle(fig, titleCase(strrep(schemeName, "_", " ")), 'FontWeight', 'bold');
set(findall(fig, '-property', 'FontName'), 'FontName', 'Arial');
set(findall(fig, '-property', 'FontSize'), 'FontSize', 10);
drawnow;
end

function scheme = findScheme(name)
schemes = mpSchemeCatalog();
idx = find(string({schemes.Name}) == name, 1);
if isempty(idx)
    error('mpRenderScheme:UnknownScheme', 'Unknown plotting scheme: %s', name);
end
scheme = schemes(idx);
end

function renderTrend(fig, schemeName, data)
ax = axes(fig);
[x, y, names] = orderedSeries(data);
colors = mpPalette("categorical", max(3, size(y, 2)));
hold(ax, 'on');

switch schemeName
    case "step_trend"
        for k = 1:size(y, 2)
            stairs(ax, x, y(:, k), 'LineWidth', 1.4, 'Color', colors(k, :));
        end
    case "confidence_band"
        center = y(:, 1);
        spread = 0.15 * std(center) + 0.08 * abs(center);
        fill(ax, [x; flipud(x)], [center - spread; flipud(center + spread)], ...
            colors(1, :), 'FaceAlpha', 0.18, 'EdgeColor', 'none');
        plot(ax, x, center, 'LineWidth', 1.6, 'Color', colors(1, :));
    case "zoomed_inset_line"
        plot(ax, x, y(:, 1), 'LineWidth', 1.4, 'Color', colors(1, :));
        grid(ax, 'on');
        n = numel(x);
        idx = max(1, round(n * 0.55)):min(n, round(n * 0.78));
        rectangle(ax, 'Position', [x(idx(1)), min(y(idx, 1)), ...
            x(idx(end)) - x(idx(1)), range(y(idx, 1))], ...
            'EdgeColor', colors(2, :), 'LineWidth', 1.2);
        inset = axes(fig, 'Position', [0.57 0.53 0.30 0.30]);
        plot(inset, x(idx), y(idx, 1), 'LineWidth', 1.2, 'Color', colors(2, :));
        grid(inset, 'on');
        title(inset, 'Detail');
        styleAxes(inset);
    case "positive_negative_area"
        v = y(:, 1);
        area(ax, x, max(v, 0), 'FaceColor', colors(1, :), 'FaceAlpha', 0.5, 'EdgeColor', 'none');
        area(ax, x, min(v, 0), 'FaceColor', colors(2, :), 'FaceAlpha', 0.5, 'EdgeColor', 'none');
        yline(ax, 0, 'Color', [0.25 0.25 0.25]);
    case "segmented_line"
        segments = discretize((1:numel(x))', 3);
        for s = 1:3
            idx = segments == s;
            plot(ax, x(idx), y(idx, 1), 'LineWidth', 1.8, 'Color', colors(s, :));
        end
    otherwise
        for k = 1:size(y, 2)
            plot(ax, x, y(:, k), 'LineWidth', 1.4, 'Color', colors(k, :));
        end
end

xlabel(ax, names.x);
ylabel(ax, 'Value');
if size(y, 2) > 1 && schemeName == "multi_line_comparison"
    legend(ax, names.y, 'Location', 'best');
end
styleAxes(ax);
end

function renderRelationship(fig, schemeName, data)
ax = axes(fig);
[x, y, group, mag] = xyData(data);
colors = mpPalette("categorical", 5);
hold(ax, 'on');

switch schemeName
    case "grouped_scatter"
        cats = categories(categorical(group));
        for k = 1:numel(cats)
            idx = categorical(group) == cats{k};
            scatter(ax, x(idx), y(idx), 28, colors(k, :), 'filled', 'MarkerFaceAlpha', 0.72);
        end
        legend(ax, cats, 'Location', 'best');
    case "density_scatter"
        scatter(ax, x, y, 24, localDensity(x, y), 'filled');
        colormap(ax, mpPalette("sequential", 128));
        colorbar(ax);
    case "contour_scatter"
        scatter(ax, x, y, 12, [0.55 0.55 0.55], 'filled', 'MarkerFaceAlpha', 0.35);
        try
            [n, cx, cy] = histcounts2(x, y, 18);
            contour(ax, midpoints(cx), midpoints(cy), n', 6, 'LineWidth', 1.1);
        catch
            plot(ax, x, smoothdata(y, 'movmean', 9), 'LineWidth', 1.2, 'Color', colors(2, :));
        end
    case "regression_scatter"
        scatter(ax, x, y, 26, colors(1, :), 'filled', 'MarkerFaceAlpha', 0.62);
        p = polyfit(x, y, 1);
        xx = linspace(min(x), max(x), 80);
        plot(ax, xx, polyval(p, xx), 'LineWidth', 1.8, 'Color', colors(2, :));
    case "bubble_scatter"
        scatter(ax, x, y, 40 + 80 * normalize01(mag), mag, 'filled', 'MarkerFaceAlpha', 0.65);
        colormap(ax, mpPalette("sequential", 128));
        colorbar(ax);
    case "residual_scatter"
        p = polyfit(x, y, 1);
        residual = y - polyval(p, x);
        scatter(ax, x, residual, 28, residual, 'filled');
        yline(ax, 0, 'Color', [0.2 0.2 0.2]);
        colormap(ax, mpPalette("diverging", 128));
        colorbar(ax);
        ylabel(ax, 'Residual');
    otherwise
        scatter(ax, x, y, 28, colors(1, :), 'filled', 'MarkerFaceAlpha', 0.68);
end

xlabel(ax, 'X');
if schemeName ~= "residual_scatter"
    ylabel(ax, 'Y');
end
styleAxes(ax);
end

function renderMatrix(fig, schemeName, data)
ax = axes(fig);
m = matrixData(data);
colors = mpPalette("sequential", 128);

if contains(schemeName, "correlation")
    m = corrcoef(m);
    colors = mpPalette("diverging", 128);
end

switch schemeName
    case "clustered_heatmap"
        [~, order] = sort(sum(m, 2));
        m = m(order, :);
        if size(m, 2) == size(m, 1)
            m = m(:, order);
        end
        imagesc(ax, m);
    case "correlation_bubble"
        drawBubbleMatrix(ax, m, true);
    case "double_triangle_heatmap"
        drawDoubleTriangle(ax, m);
    case "triangular_heatmap"
        mask = tril(true(size(m)));
        m(~mask) = NaN;
        imagesc(ax, m, 'AlphaData', ~isnan(m));
    case "bubble_matrix"
        drawBubbleMatrix(ax, m, false);
    otherwise
        imagesc(ax, m);
end

axis(ax, 'tight');
axis(ax, 'ij');
colormap(ax, colors);
colorbar(ax);
xlabel(ax, 'Column');
ylabel(ax, 'Row');
styleAxes(ax);
end

function renderBar(fig, schemeName, data)
ax = axes(fig);
[labels, values] = categoryValues(data);
colors = mpPalette("categorical", max(3, size(values, 2)));
hold(ax, 'on');

switch schemeName
    case "stacked_bar"
        bar(ax, values, 'stacked');
        setBarColors(ax, colors);
    case "horizontal_bar"
        barh(ax, values(:, 1), 'FaceColor', colors(1, :));
        set(ax, 'YTick', 1:numel(labels), 'YTickLabel', labels);
        xlabel(ax, 'Value');
    case "diverging_bar"
        v = values(:, 1) - mean(values(:, 1));
        barh(ax, v, 'FaceColor', 'flat');
        bars = findobj(ax, 'Type', 'Bar');
        bars.CData = chooseDiverging(v);
        xline(ax, 0, 'Color', [0.25 0.25 0.25]);
        set(ax, 'YTick', 1:numel(labels), 'YTickLabel', labels);
    case "grouped_error_bar"
        b = bar(ax, values(:, 1:min(2, size(values, 2))));
        setBarColors(ax, colors);
        for k = 1:numel(b)
            errorbar(ax, b(k).XEndPoints, b(k).YEndPoints, 0.08 * abs(b(k).YEndPoints) + 0.2, ...
                'k', 'LineStyle', 'none', 'LineWidth', 0.8);
        end
    case "floating_bar"
        low = min(values(:, 1), values(:, min(2, size(values, 2))));
        high = max(values(:, 1), values(:, min(2, size(values, 2))));
        bar(ax, high - low, 'BaseValue', 0, 'FaceColor', colors(1, :));
        for k = 1:numel(low)
            rectangle(ax, 'Position', [k - 0.32, low(k), 0.64, high(k) - low(k)], ...
                'FaceColor', colors(2, :), 'EdgeColor', 'none');
        end
    case "butterfly_comparison"
        v1 = values(:, 1);
        v2 = values(:, min(2, size(values, 2)));
        barh(ax, -v1, 'FaceColor', colors(1, :));
        barh(ax, v2, 'FaceColor', colors(2, :));
        xline(ax, 0, 'Color', [0.25 0.25 0.25]);
        set(ax, 'YTick', 1:numel(labels), 'YTickLabel', labels);
    otherwise
        bar(ax, values);
        setBarColors(ax, colors);
end

if ~ismember(schemeName, ["horizontal_bar", "diverging_bar", "butterfly_comparison"])
    set(ax, 'XTick', 1:numel(labels), 'XTickLabel', labels);
    xtickangle(ax, 25);
end
ylabel(ax, 'Value');
styleAxes(ax);
end

function renderDistribution(fig, schemeName, data)
ax = axes(fig);
[group, value] = groupedValues(data);
colors = mpPalette("categorical", numel(categories(group)));
cats = categories(group);
hold(ax, 'on');

switch schemeName
    case {"box_jitter", "jitter_swarm"}
        for k = 1:numel(cats)
            idx = group == cats{k};
            vals = value(idx);
            q = simplePercentiles(vals, [25 50 75]);
            whisk = simplePercentiles(vals, [5 95]);
            rectangle(ax, 'Position', [k - 0.22, q(1), 0.44, q(3) - q(1)], ...
                'FaceColor', [0.86 0.86 0.86], 'EdgeColor', [0.25 0.25 0.25]);
            plot(ax, [k - 0.22 k + 0.22], [q(2) q(2)], 'Color', [0.15 0.15 0.15], 'LineWidth', 1.2);
            plot(ax, [k k], whisk, 'Color', [0.3 0.3 0.3], 'LineWidth', 0.9);
            scatter(ax, k + 0.12 * randn(sum(idx), 1), value(idx), 14, colors(k, :), ...
                'filled', 'MarkerFaceAlpha', 0.45);
        end
        set(ax, 'XTick', 1:numel(cats), 'XTickLabel', cats);
    case "violin_plot"
        for k = 1:numel(cats)
            idx = group == cats{k};
            [xi, f] = simpleDensity(value(idx), 28);
            f = 0.35 * f / max(f);
            fill(ax, [k - f, fliplr(k + f)], [xi, fliplr(xi)], colors(k, :), ...
                'FaceAlpha', 0.35, 'EdgeColor', colors(k, :));
        end
        set(ax, 'XTick', 1:numel(cats), 'XTickLabel', cats);
    case "ridgeline_plot"
        for k = 1:numel(cats)
            idx = group == cats{k};
            [xi, f] = simpleDensity(value(idx), 32);
            plot(ax, xi, f + k, 'LineWidth', 1.2, 'Color', colors(k, :));
            fill(ax, [xi, fliplr(xi)], [f + k, k * ones(size(f))], colors(k, :), ...
                'FaceAlpha', 0.18, 'EdgeColor', 'none');
        end
        set(ax, 'YTick', 1:numel(cats), 'YTickLabel', cats);
        xlabel(ax, 'Value');
    case "histogram_distribution"
        histogram(ax, value, 18, 'FaceColor', colors(1, :), 'EdgeColor', 'none');
    case "density_curve"
        [xi, f] = simpleDensity(value, 36);
        plot(ax, xi, f, 'LineWidth', 1.6, 'Color', colors(1, :));
        fill(ax, [xi, fliplr(xi)], [f, zeros(size(f))], colors(1, :), ...
            'FaceAlpha', 0.16, 'EdgeColor', 'none');
    case "ecdf_curve"
        for k = 1:numel(cats)
            idx = group == cats{k};
            x = sort(value(idx));
            f = (1:numel(x))' / max(1, numel(x));
            plot(ax, x, f, 'LineWidth', 1.4, 'Color', colors(k, :));
        end
        legend(ax, cats, 'Location', 'best');
    otherwise
        histogram(ax, value, 18);
end

ylabel(ax, 'Value');
styleAxes(ax);
end

function renderRankingComposition(fig, schemeName, data)
ax = axes(fig);
[labels, values] = categoryValues(data);
v = values(:, 1);
colors = mpPalette("categorical", max(numel(v), 4));
hold(ax, 'on');

switch schemeName
    case {"lollipop_ranking", "dot_ranking"}
        [v, order] = sort(v, 'ascend');
        labels = labels(order);
        for k = 1:numel(v)
            plot(ax, [0 v(k)], [k k], 'Color', [0.65 0.65 0.65], 'LineWidth', 1.2);
        end
        scatter(ax, v, 1:numel(v), 54, colors(1:numel(v), :), 'filled');
        set(ax, 'YTick', 1:numel(labels), 'YTickLabel', labels);
    case "waffle_composition"
        shares = v / sum(v);
        counts = max(0, round(100 * shares));
        counts(1) = counts(1) + (100 - sum(counts));
        drawWaffle(ax, counts, labels, colors);
    case "percent_stacked_bar"
        pct = values ./ sum(values, 2);
        bar(ax, pct, 'stacked');
        ylim(ax, [0 1]);
        setBarColors(ax, colors);
    case "pareto_chart"
        [v, order] = sort(v, 'descend');
        labels = labels(order);
        yyaxis(ax, 'left');
        bar(ax, v, 'FaceColor', colors(1, :));
        ylabel(ax, 'Value');
        yyaxis(ax, 'right');
        plot(ax, cumsum(v) / sum(v), '-o', 'LineWidth', 1.2, 'Color', colors(2, :));
        ylim(ax, [0 1]);
        set(ax, 'XTick', 1:numel(labels), 'XTickLabel', labels);
    case "waterfall_contribution"
        cumulative = [0; cumsum(v(1:end-1))];
        for k = 1:numel(v)
            rectangle(ax, 'Position', [k - 0.35, cumulative(k), 0.7, v(k)], ...
                'FaceColor', colors(mod(k - 1, size(colors, 1)) + 1, :), 'EdgeColor', 'none');
        end
        xlim(ax, [0.5 numel(v) + 0.5]);
        set(ax, 'XTick', 1:numel(labels), 'XTickLabel', labels);
    case "ternary_composition"
        vals = values(:, 1:min(3, size(values, 2)));
        vals = vals ./ sum(vals, 2);
        x = vals(:, 2) + 0.5 * vals(:, 3);
        y = sqrt(3) / 2 * vals(:, 3);
        plot(ax, [0 1 0.5 0], [0 0 sqrt(3)/2 0], 'k-', 'LineWidth', 1);
        scatter(ax, x, y, 60, colors(1:size(vals, 1), :), 'filled');
        axis(ax, 'equal');
        axis(ax, 'off');
    otherwise
        bar(ax, v, 'FaceColor', colors(1, :));
        set(ax, 'XTick', 1:numel(labels), 'XTickLabel', labels);
end

styleAxes(ax);
end

function renderMultivariate(fig, schemeName, data)
m = matrixData(data);
colors = mpPalette("categorical", size(m, 1));

switch schemeName
    case "radar_chart"
        ax = polaraxes(fig);
        n = size(m, 2);
        theta = linspace(0, 2 * pi, n + 1);
        hold(ax, 'on');
        for k = 1:min(size(m, 1), 6)
            r = [normalize01(m(k, :)), normalize01(m(k, 1))];
            polarplot(ax, theta, r, 'LineWidth', 1.2, 'Color', colors(k, :));
        end
    case "pca_scatter"
        ax = axes(fig);
        m = zscore(m);
        [~, ~, v] = svd(m, 'econ');
        score = m * v(:, 1:2);
        scatter(ax, score(:, 1), score(:, 2), 45, colors(1:size(score, 1), :), 'filled');
        xlabel(ax, 'Component 1');
        ylabel(ax, 'Component 2');
        styleAxes(ax);
    otherwise
        ax = axes(fig);
        plot(ax, normalize01(m')', 'LineWidth', 1.1);
        xlabel(ax, 'Metric');
        ylabel(ax, 'Normalized value');
        styleAxes(ax);
end
end

function renderSpatial(fig, schemeName, data)
ax = axes(fig);
m = matrixData(data);
colors = mpPalette("sequential", 128);

switch schemeName
    case "surface_3d"
        surf(ax, m, 'EdgeColor', 'none');
        view(ax, 45, 28);
        zlabel(ax, 'Z');
    case "quiver_vector"
        [gx, gy] = gradient(m);
        quiver(ax, gx, gy, 'Color', [0.15 0.25 0.35]);
        axis(ax, 'ij');
    otherwise
        contourf(ax, m, 12, 'LineColor', 'none');
end

colormap(ax, colors);
colorbar(ax);
xlabel(ax, 'X');
ylabel(ax, 'Y');
styleAxes(ax);
end

function renderLayout(fig, schemeName, data)
tiledlayout(fig, 2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

nexttile;
renderTrendPanel(gca, data);
nexttile;
renderMatrixPanel(gca, data);
nexttile;
renderBarPanel(gca, data);
nexttile;
renderRelationshipPanel(gca, data, schemeName);
end

function [x, y, names] = orderedSeries(data)
[m, numericNames] = numericMatrix(data);
if isempty(m)
    m = (1:20)';
end
if size(m, 2) == 1
    x = (1:size(m, 1))';
    y = m(:, 1);
elseif size(m, 2) >= 2
    x = m(:, 1);
    y = m(:, 2:end);
else
    x = (1:numel(m))';
    y = m(:);
end
if numel(unique(x)) < numel(x)
    x = (1:size(y, 1))';
end
names = struct();
names.x = "Index";
if numel(numericNames) >= size(y, 2)
    names.y = numericNames(end - size(y, 2) + 1:end);
else
    names.y = "Series " + string(1:size(y, 2));
end
end

function [x, y, group, mag] = xyData(data)
[m, ~] = numericMatrix(data);
if size(m, 2) < 2
    m = [(1:size(m, 1))', m(:, 1)];
end
x = m(:, 1);
y = m(:, 2);
if size(m, 2) >= 3
    mag = abs(m(:, 3));
else
    mag = abs(y);
end
group = categorical(repmat("A", size(x)));
if istable(data)
    for k = 1:width(data)
        col = data.(k);
        if iscategorical(col) || isstring(col) || iscellstr(col)
            group = categorical(col);
            return
        end
    end
end
end

function [labels, values] = categoryValues(data)
[m, ~] = numericMatrix(data);
if isempty(m)
    m = (1:5)';
end
if istable(data)
    labels = [];
    for k = 1:width(data)
        col = data.(k);
        if iscategorical(col) || isstring(col) || iscellstr(col)
            labels = string(col);
            break
        end
    end
    if isempty(labels)
        labels = "C" + string(1:size(m, 1));
    end
else
    labels = "C" + string(1:size(m, 1));
end
values = m;
if size(values, 2) > 4
    values = values(:, 1:4);
end
end

function [group, value] = groupedValues(data)
[m, ~] = numericMatrix(data);
value = m(:, min(1, size(m, 2)));
group = categorical(repmat("A", numel(value), 1));
if istable(data)
    for k = 1:width(data)
        col = data.(k);
        if iscategorical(col) || isstring(col) || iscellstr(col)
            group = categorical(col);
            return
        end
    end
end
end

function m = matrixData(data)
[m, ~] = numericMatrix(data);
if isempty(m)
    m = peaks(10);
end
if isvector(m)
    n = ceil(sqrt(numel(m)));
    padded = nan(n * n, 1);
    padded(1:numel(m)) = m(:);
    m = reshape(padded, n, n);
end
end

function [m, names] = numericMatrix(data)
names = strings(1, 0);
if istimetable(data)
    data = timetable2table(data);
end
if istable(data)
    cols = {};
    for k = 1:width(data)
        col = data.(k);
        if isnumeric(col) || islogical(col)
            cols{end + 1} = double(col(:)); %#ok<AGROW>
            names(end + 1) = string(data.Properties.VariableNames{k}); %#ok<AGROW>
        end
    end
    if isempty(cols)
        m = [];
    else
        m = horzcat(cols{:});
    end
elseif isnumeric(data) || islogical(data)
    m = double(data);
    names = "value" + string(1:size(m, 2));
else
    m = [];
end
end

function d = localDensity(x, y)
edgesX = linspace(min(x), max(x), 22);
edgesY = linspace(min(y), max(y), 22);
[n, ~, ~, bx, by] = histcounts2(x, y, edgesX, edgesY);
d = ones(size(x));
for k = 1:numel(x)
    if bx(k) > 0 && by(k) > 0
        d(k) = n(bx(k), by(k));
    end
end
end

function out = normalize01(v)
v = double(v);
if all(isnan(v), 'all') || max(v, [], 'all') == min(v, [], 'all')
    out = zeros(size(v));
else
    out = (v - min(v, [], 'all')) ./ (max(v, [], 'all') - min(v, [], 'all'));
end
end

function y = midpoints(x)
y = (x(1:end-1) + x(2:end)) / 2;
end

function drawBubbleMatrix(ax, m, signedColors)
[r, c] = ndgrid(1:size(m, 1), 1:size(m, 2));
sizes = 25 + 180 * normalize01(abs(m(:)));
if signedColors
    scatter(ax, c(:), r(:), sizes, m(:), 'filled');
    colormap(ax, mpPalette("diverging", 128));
else
    scatter(ax, c(:), r(:), sizes, abs(m(:)), 'filled');
    colormap(ax, mpPalette("sequential", 128));
end
axis(ax, 'ij');
end

function drawDoubleTriangle(ax, m)
n = min(size(m));
m = m(1:n, 1:n);
hold(ax, 'on');
for row = 1:n
    for col = 1:n
        left = col - 0.5;
        right = col + 0.5;
        top = row - 0.5;
        bottom = row + 0.5;
        patch(ax, [left right right], [top top bottom], m(row, col), ...
            'EdgeColor', 'w', 'LineWidth', 0.35);
        patch(ax, [left left right], [top bottom bottom], -m(row, col), ...
            'EdgeColor', 'w', 'LineWidth', 0.35);
    end
end
xlim(ax, [0.5 n + 0.5]);
ylim(ax, [0.5 n + 0.5]);
axis(ax, 'ij');
colormap(ax, mpPalette("diverging", 128));
end

function setBarColors(ax, colors)
bars = findobj(ax, 'Type', 'Bar');
for k = 1:numel(bars)
    bars(k).FaceColor = colors(mod(k - 1, size(colors, 1)) + 1, :);
end
end

function colors = chooseDiverging(v)
neg = [0.1922 0.2118 0.5843];
pos = [0.6980 0.0941 0.1686];
colors = repmat(pos, numel(v), 1);
colors(v < 0, :) = repmat(neg, sum(v < 0), 1);
end

function drawWaffle(ax, counts, labels, colors)
counts = counts(:);
total = sum(counts);
idx = repelem((1:numel(counts))', counts);
idx = idx(1:min(total, 100));
hold(ax, 'on');
for k = 1:numel(idx)
    [row, col] = ind2sub([10 10], k);
    rectangle(ax, 'Position', [col, 11 - row, 0.88, 0.88], ...
        'FaceColor', colors(idx(k), :), 'EdgeColor', 'w');
end
axis(ax, 'equal');
axis(ax, 'off');
handles = gobjects(numel(labels), 1);
for k = 1:numel(labels)
    handles(k) = scatter(ax, NaN, NaN, 36, colors(k, :), 'filled');
end
legend(ax, handles, labels, 'Location', 'eastoutside');
end

function renderTrendPanel(ax, data)
[x, y] = orderedSeries(data);
plot(ax, x, y(:, 1), 'LineWidth', 1.1);
title(ax, 'Trend');
styleAxes(ax);
end

function renderMatrixPanel(ax, data)
imagesc(ax, matrixData(data));
title(ax, 'Matrix');
styleAxes(ax);
end

function renderBarPanel(ax, data)
[labels, values] = categoryValues(data);
bar(ax, values(:, 1));
set(ax, 'XTick', 1:numel(labels), 'XTickLabel', labels);
title(ax, 'Comparison');
styleAxes(ax);
end

function renderRelationshipPanel(ax, data, schemeName)
[x, y] = xyData(data);
scatter(ax, x, y, 20, 'filled');
if schemeName == "annotated_callout"
    [~, idx] = max(y);
    text(ax, x(idx), y(idx), "  peak", 'FontWeight', 'bold');
end
title(ax, 'Relationship');
styleAxes(ax);
end

function styleAxes(ax)
grid(ax, 'on');
box(ax, 'on');
ax.LineWidth = 0.8;
ax.GridAlpha = 0.18;
ax.Color = 'w';
end

function q = simplePercentiles(v, p)
v = sort(v(:));
if isempty(v)
    q = nan(size(p));
    return
end
pos = 1 + (numel(v) - 1) * p(:)' / 100;
lo = floor(pos);
hi = ceil(pos);
frac = pos - lo;
q = v(lo)' .* (1 - frac) + v(hi)' .* frac;
end

function [x, f] = simpleDensity(v, bins)
v = v(:);
if numel(unique(v)) < 2
    x = linspace(v(1) - 1, v(1) + 1, bins);
    f = ones(size(x));
    return
end
edges = linspace(min(v), max(v), bins + 1);
counts = histcounts(v, edges, 'Normalization', 'pdf');
x = midpoints(edges);
kernel = [1 2 3 2 1] / 9;
f = conv(counts, kernel, 'same');
end

function out = titleCase(s)
parts = split(string(s));
for k = 1:numel(parts)
    p = char(parts(k));
    if ~isempty(p)
        parts(k) = string([upper(p(1)), p(2:end)]);
    end
end
out = strjoin(parts, " ");
end
