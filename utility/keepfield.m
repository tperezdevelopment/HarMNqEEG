function S=keepfield(S,fields)
if ischar(fields)|| isstring(fields)
    fields = {fields};
end
fields = setdiff(fieldnames(S), fields);
S = rmfield(S, fields);
end



