function plan = mpPlan(dataPath, goalText, schemeName, variableName)
%MPPLAN Read data and plan a plotting scheme without rendering.

if nargin < 1
    dataPath = "";
end
if nargin < 2 || strlength(string(goalText)) == 0
    goalText = "choose the best scientific figure";
end
if nargin < 3 || isempty(schemeName)
    schemeName = "";
end
if nargin < 4 || isempty(variableName)
    variableName = "";
end

data = mpReadData(string(dataPath), string(variableName));
schema = mpInferDataSchema(data);
selection = localChooseSelection(schema, string(goalText), string(schemeName));

plan = struct( ...
    'schema_version', "1.0", ...
    'SelectedScheme', selection.Selected.Name, ...
    'SelectedFamily', selection.Selected.Family, ...
    'SelectedPalette', selection.Selected.Palette, ...
    'Alternatives', string({selection.Alternatives.Name}), ...
    'Schema', schema, ...
    'Explanation', mpExplainSelection(schema, string(goalText), selection), ...
    'ScoreSnapshot', localScoreSnapshot(selection));
end

function selection = localChooseSelection(schema, goalText, schemeName)
autoSelection = mpSelectScheme(schema, goalText);
if strlength(schemeName) == 0
    selection = autoSelection;
    return
end

schemes = mpSchemeCatalog();
idx = find(string({schemes.Name}) == schemeName, 1);
if isempty(idx)
    error('mpPlan:UnknownScheme', 'Unknown plotting scheme: %s', schemeName);
end

candidates = [autoSelection.Selected; autoSelection.Alternatives(:)];
keep = string({candidates.Name}) ~= schemeName;
selection = struct();
selection.Selected = schemes(idx);
selection.Score = NaN;
selection.Alternatives = candidates(keep);
selection.AllScores = autoSelection.AllScores;
end

function snapshot = localScoreSnapshot(selection)
schemes = mpSchemeCatalog();
scores = selection.AllScores(:);
[~, order] = sort(scores, 'descend');
limit = min(5, numel(order));
snapshot = repmat(struct('Name', "", 'Family', "", 'Score', 0), 1, limit);
for k = 1:limit
    idx = order(k);
    snapshot(k).Name = schemes(idx).Name;
    snapshot(k).Family = schemes(idx).Family;
    snapshot(k).Score = scores(idx);
end
end
