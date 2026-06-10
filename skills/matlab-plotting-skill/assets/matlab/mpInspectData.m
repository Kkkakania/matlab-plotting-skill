function inspection = mpInspectData(dataPath, variableName)
%MPINSPECTDATA Read data and return schema metadata without selecting a plot.

if nargin < 1
    dataPath = "";
end
if nargin < 2 || isempty(variableName)
    variableName = "";
end

dataPath = string(dataPath);
variableName = string(variableName);
data = mpReadData(dataPath, variableName);
schema = mpInferDataSchema(data);
fileName = localFileName(dataPath);
roleHint = localRoleHint(schema);

inspection = struct();
inspection.schema_version = "1.0";
inspection.FileName = fileName;
inspection.VariableName = variableName;
inspection.Schema = schema;
inspection.RoleHint = roleHint;
inspection.NextCommandHint = localNextCommandHint(fileName, roleHint);
end

function fileName = localFileName(pathValue)
if strlength(string(pathValue)) == 0
    fileName = "synthetic demo data";
    return
end
[~, name, ext] = fileparts(string(pathValue));
fileName = name + ext;
end

function hint = localRoleHint(schema)
if schema.TimeCount >= 1 && schema.NumericCount <= 2
    hint = "looks like a single time series";
elseif schema.TimeCount >= 1 && schema.NumericCount > 2
    hint = "looks like multiple time-aligned series";
elseif schema.HasMatrix
    hint = "looks like a numeric matrix or wide numeric table";
elseif schema.CategoryCount >= 1 && schema.NumericCount >= 1
    hint = "looks like a category-value table";
elseif schema.NumericCount >= 2
    hint = "looks like a numeric relationship table";
else
    hint = "needs a plotting goal before choosing a chart";
end
end

function hint = localNextCommandHint(fileName, roleHint)
dataToken = localDataToken(fileName);
goal = localGoalForRole(roleHint);
quote = string(char(34));
hint = "Try: ./scripts/render_with_matlab.sh --plan-only --data " + ...
    dataToken + " --goal " + quote + goal + quote;
end

function dataToken = localDataToken(fileName)
fileName = string(fileName);
if strlength(fileName) == 0 || fileName == "synthetic demo data" || ...
        any(contains(fileName, [" ", "'", string(char(34))]))
    dataToken = "<data-file>";
else
    dataToken = fileName;
end
end

function goal = localGoalForRole(roleHint)
switch string(roleHint)
    case "looks like a single time series"
        goal = "show a time trend";
    case "looks like multiple time-aligned series"
        goal = "compare time series";
    case "looks like a numeric matrix or wide numeric table"
        goal = "show a matrix heatmap";
    case "looks like a category-value table"
        goal = "compare categories";
    case "looks like a numeric relationship table"
        goal = "show the relationship";
    otherwise
        goal = "show the main pattern";
end
end
