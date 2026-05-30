function colors = mpPalette(kind, n)
%MPPALETTE Return clean default colors.

if nargin < 1 || strlength(string(kind)) == 0
    kind = "categorical";
end
if nargin < 2
    n = 8;
end

baseCategorical = [
    0.1216 0.4667 0.7059
    0.8392 0.1529 0.1569
    0.1725 0.6275 0.1725
    1.0000 0.4980 0.0549
    0.5804 0.4039 0.7412
    0.5490 0.3373 0.2941
    0.8902 0.4667 0.7608
    0.4980 0.4980 0.4980
    0.7373 0.7412 0.1333
    0.0902 0.7451 0.8118
];

kind = lower(string(kind));
switch kind
    case "diverging"
        anchors = [0.1922 0.2118 0.5843; 0.9686 0.9686 0.9686; 0.6980 0.0941 0.1686];
        colors = interpolateColors(anchors, n);
    case "sequential"
        anchors = [0.9294 0.9725 0.9843; 0.4039 0.6627 0.8118; 0.0314 0.2509 0.5059];
        colors = interpolateColors(anchors, n);
    case "neutral"
        colors = repmat(linspace(0.15, 0.75, n)', 1, 3);
    otherwise
        reps = ceil(n / size(baseCategorical, 1));
        colors = repmat(baseCategorical, reps, 1);
        colors = colors(1:n, :);
end
end

function colors = interpolateColors(anchors, n)
if n == 1
    colors = anchors(ceil(size(anchors, 1) / 2), :);
    return
end
x = linspace(0, 1, size(anchors, 1));
xi = linspace(0, 1, n);
colors = [interp1(x, anchors(:, 1), xi)', interp1(x, anchors(:, 2), xi)', interp1(x, anchors(:, 3), xi)'];
colors = max(0, min(1, colors));
end

