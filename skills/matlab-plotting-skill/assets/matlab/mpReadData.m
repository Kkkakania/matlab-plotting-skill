function data = mpReadData(dataPath, variableName)
%MPREADDATA Read CSV, Excel, MAT, or create a default demo table.

if nargin < 2 || isempty(variableName)
    variableName = "";
end

dataPath = string(dataPath);
variableName = string(variableName);
if strlength(dataPath) == 0
    data = mpDemoDataForScheme("line_trend");
    return
end

if ~isfile(dataPath)
    error('mpReadData:NotFound', 'Data file not found: %s', dataPath);
end

[~, ~, ext] = fileparts(dataPath);
ext = lower(string(ext));

switch ext
    case ".csv"
        data = readtable(dataPath);
    case {".xls", ".xlsx"}
        opts = detectImportOptions(dataPath);
        data = readtable(dataPath, opts);
    case ".mat"
        raw = load(dataPath);
        data = selectMatVariable(raw, variableName);
    otherwise
        error('mpReadData:UnsupportedFile', 'Unsupported data file: %s', dataPath);
end

if ext ~= ".mat" && strlength(variableName) > 0
    error('mpReadData:VariableOnlyForMat', '--var can only be used with MAT files.');
end
end

function value = selectMatVariable(raw, variableName)
names = string(fieldnames(raw));
usable = false(size(names));
for k = 1:numel(names)
    v = raw.(names(k));
    usable(k) = istable(v) || istimetable(v) || isnumeric(v) || isstruct(v);
end
names = names(usable);

if strlength(variableName) > 0
    if ~any(names == variableName)
        error('mpReadData:MatVariableNotFound', ...
            'MAT variable not found: %s. Candidate variables: %s', ...
            variableName, candidateSummary(raw, names));
    end
    value = unwrapMatValue(raw.(char(variableName)));
    return
end

if isempty(names)
    error('mpReadData:NoUsableMatVariable', ...
        'MAT file has no table, timetable, numeric matrix, numeric vector, or scalar struct variable.');
end

if numel(names) > 1
    tableLike = strings(0);
    for k = 1:numel(names)
        v = raw.(names(k));
        if istable(v) || istimetable(v)
            tableLike(end + 1) = names(k); %#ok<AGROW>
        end
    end
    if isscalar(tableLike)
        value = unwrapMatValue(raw.(char(tableLike(1))));
        return
    end
    error('mpReadData:AmbiguousMatFile', ...
        'MAT file is ambiguous. Candidate variables: %s', candidateSummary(raw, names));
end

value = unwrapMatValue(raw.(char(names(1))));
end

function value = unwrapMatValue(value)
if isstruct(value) && isscalar(value)
    fields = string(fieldnames(value));
    if isscalar(fields)
        value = value.(fields(1));
    end
end
end

function text = candidateSummary(raw, names)
items = strings(numel(names), 1);
for k = 1:numel(names)
    v = raw.(char(names(k)));
    items(k) = names(k) + " (" + describeMatValue(v) + ")";
end
text = strjoin(items, ', ');
end

function description = describeMatValue(value)
if istable(value) || istimetable(value)
    description = sprintf('%s %dx%d', class(value), height(value), width(value));
elseif isnumeric(value)
    dims = join(string(size(value)), "x");
    if isvector(value)
        description = sprintf('numeric vector %s', dims);
    else
        description = sprintf('numeric matrix %s', dims);
    end
elseif isstruct(value)
    description = sprintf('struct %dx%d', size(value, 1), size(value, 2));
else
    description = class(value);
end
description = string(description);
end
