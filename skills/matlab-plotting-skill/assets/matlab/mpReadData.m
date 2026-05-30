function data = mpReadData(dataPath)
%MPREADDATA Read CSV, Excel, MAT, or create a default demo table.

dataPath = string(dataPath);
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
        data = selectMatVariable(raw);
    otherwise
        error('mpReadData:UnsupportedFile', 'Unsupported data file: %s', dataPath);
end
end

function value = selectMatVariable(raw)
names = string(fieldnames(raw));
usable = false(size(names));
for k = 1:numel(names)
    v = raw.(names(k));
    usable(k) = istable(v) || istimetable(v) || isnumeric(v) || isstruct(v);
end
names = names(usable);

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
        value = raw.(tableLike(1));
        return
    end
    error('mpReadData:AmbiguousMatFile', ...
        'MAT file is ambiguous. Candidate variables: %s', strjoin(names, ', '));
end

value = raw.(names(1));
if isstruct(value) && isscalar(value)
    fields = string(fieldnames(value));
    if isscalar(fields)
        value = value.(fields(1));
    end
end
end
