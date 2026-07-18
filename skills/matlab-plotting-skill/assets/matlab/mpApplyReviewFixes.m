function applied = mpApplyReviewFixes(fig, review)
%MPAPPLYREVIEWFIXES Apply a narrow, auditable set of figure repairs.

if ~isstruct(review) || ~isfield(review, 'repair_actions')
    error('mpApplyReviewFixes:InvalidReview', ...
        'Review must contain a repair_actions field.');
end

actions = review.repair_actions;
if isempty(actions)
    applied = strings(1, 0);
    return
end
if ~isstruct(actions) && ~iscell(actions)
    error('mpApplyReviewFixes:InvalidReview', ...
        'repair_actions must decode to an object array.');
end

applied = strings(1, numel(actions));
for k = 1:numel(actions)
    action = localActionAt(actions, k);
    if ~isstruct(action) || ~isfield(action, 'action')
        error('mpApplyReviewFixes:InvalidReview', ...
            'Each repair action must include an action name.');
    end
    actionName = string(action.action);
    switch actionName
        case "increase_font_size"
            value = localNumericValue(action, actionName);
            if value < 8 || value > 24
                error('mpApplyReviewFixes:InvalidValue', ...
                    'increase_font_size must be between 8 and 24.');
            end
            objects = findall(fig, '-property', 'FontSize');
            for objectIndex = 1:numel(objects)
                objects(objectIndex).FontSize = max(objects(objectIndex).FontSize, value);
            end
        case "enable_grid"
            axesObjects = findall(fig, 'Type', 'axes');
            for axesIndex = 1:numel(axesObjects)
                grid(axesObjects(axesIndex), 'on');
                axesObjects(axesIndex).GridAlpha = 0.22;
            end
        case "legend_best"
            legends = findall(fig, 'Type', 'legend');
            for legendIndex = 1:numel(legends)
                legends(legendIndex).Location = 'best';
            end
        case "enforce_zero_baseline"
            axesObjects = findall(fig, 'Type', 'axes');
            for axesIndex = 1:numel(axesObjects)
                limits = axesObjects(axesIndex).YLim;
                if all(isfinite(limits))
                    limits = [min(0, limits(1)), max(0, limits(2))];
                    if limits(1) == limits(2)
                        limits = limits + [-1, 1];
                    end
                    axesObjects(axesIndex).YLim = limits;
                end
            end
        case "high_contrast_palette"
            localApplyHighContrastPalette(fig);
        otherwise
            error('mpApplyReviewFixes:UnsupportedAction', ...
                'Unsupported repair action: %s', actionName);
    end
    applied(k) = actionName;
end
drawnow;
end

function action = localActionAt(actions, index)
if iscell(actions)
    action = actions{index};
else
    action = actions(index);
end
end

function value = localNumericValue(action, actionName)
if ~isfield(action, 'value') || ~isnumeric(action.value) || ~isscalar(action.value) || ...
        ~isfinite(action.value)
    error('mpApplyReviewFixes:InvalidValue', ...
        '%s requires one finite numeric value.', actionName);
end
value = double(action.value);
end

function localApplyHighContrastPalette(fig)
colors = [ ...
    0.000 0.447 0.698
    0.835 0.369 0.000
    0.000 0.620 0.451
    0.800 0.475 0.655
    0.337 0.706 0.914
    0.941 0.894 0.259
    0.000 0.000 0.000];

lines = flipud(findall(fig, 'Type', 'line'));
for k = 1:numel(lines)
    lines(k).Color = colors(mod(k - 1, size(colors, 1)) + 1, :);
end

scatters = flipud(findall(fig, 'Type', 'scatter'));
for k = 1:numel(scatters)
    scatters(k).CData = colors(mod(k - 1, size(colors, 1)) + 1, :);
end

axesObjects = findall(fig, 'Type', 'axes');
for k = 1:numel(axesObjects)
    axesObjects(k).XColor = [0.16 0.16 0.16];
    axesObjects(k).YColor = [0.16 0.16 0.16];
end
textObjects = findall(fig, 'Type', 'text');
for k = 1:numel(textObjects)
    textObjects(k).Color = [0.16 0.16 0.16];
end
legends = findall(fig, 'Type', 'legend');
for k = 1:numel(legends)
    legends(k).Color = [1 1 1];
    legends(k).TextColor = [0.16 0.16 0.16];
    legends(k).EdgeColor = [0.72 0.72 0.72];
end
end
