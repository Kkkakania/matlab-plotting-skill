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

inspection = struct();
inspection.FileName = localFileName(dataPath);
inspection.VariableName = variableName;
inspection.Schema = schema;
end

function fileName = localFileName(pathValue)
if strlength(string(pathValue)) == 0
    fileName = "synthetic demo data";
    return
end
[~, name, ext] = fileparts(string(pathValue));
fileName = name + ext;
end
