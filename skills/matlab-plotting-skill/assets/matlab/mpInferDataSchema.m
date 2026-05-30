function schema = mpInferDataSchema(data)
%MPINFERDATASCHEMA Infer enough structure to choose a plotting scheme.

schema = struct();
schema.Kind = "unknown";
schema.RowCount = 0;
schema.ColumnCount = 0;
schema.NumericCount = 0;
schema.CategoryCount = 0;
schema.TimeCount = 0;
schema.HasMatrix = false;
schema.HasPositiveNegative = false;
schema.HasPercent = false;
schema.VariableNames = strings(1, 0);

if istimetable(data)
    data = timetable2table(data);
end

if istable(data)
    schema.Kind = "table";
    schema.RowCount = height(data);
    schema.ColumnCount = width(data);
    schema.VariableNames = string(data.Properties.VariableNames);
    numericMask = false(1, width(data));
    categoryMask = false(1, width(data));
    timeMask = false(1, width(data));
    values = [];
    for k = 1:width(data)
        col = data.(k);
        name = lower(string(data.Properties.VariableNames{k}));
        numericMask(k) = isnumeric(col) || islogical(col);
        categoryMask(k) = iscategorical(col) || isstring(col) || iscellstr(col) || islogical(col);
        timeMask(k) = isdatetime(col) || isduration(col) || any(name == ["time", "date", "year", "month", "day", "step", "sample"]);
        if numericMask(k)
            values = [values; double(col(:))]; %#ok<AGROW>
        end
    end
    schema.NumericCount = sum(numericMask);
    schema.CategoryCount = sum(categoryMask);
    schema.TimeCount = sum(timeMask);
    schema.HasMatrix = schema.NumericCount >= 3 && schema.CategoryCount == 0 && schema.RowCount >= 3;
    schema.HasPositiveNegative = any(values < 0, 'all') && any(values > 0, 'all');
    schema.HasPercent = ~isempty(values) && all(values >= 0 & values <= 1, 'all');
    return
end

if isnumeric(data) || islogical(data)
    data = double(data);
    schema.Kind = "numeric";
    schema.RowCount = size(data, 1);
    schema.ColumnCount = size(data, 2);
    schema.NumericCount = schema.ColumnCount;
    schema.HasMatrix = ismatrix(data) && min(size(data)) > 1;
    schema.HasPositiveNegative = any(data < 0, 'all') && any(data > 0, 'all');
    schema.HasPercent = all(data(:) >= 0 & data(:) <= 1);
    schema.VariableNames = "value" + string(1:schema.ColumnCount);
    return
end
end

