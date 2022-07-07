function dest=copyfield(src,dest,fields,isOverride)
if nargin<4 || isempty(isOverride)
    isOverride = true;
end
if ~(nargin<3 || isempty(fields))
    src=keepfield(src,fields);
end
names = fieldnames(dest)';
values = struct2cell(dest)';
if isOverride
    names = [names,fieldnames(src)'];
    values = [values,struct2cell(src)'];
else
    names = [fieldnames(src)',names];
    values = [struct2cell(src)',values];
end
[s,idx] = sort(names(:));
idx(strcmp(s((1:end-1)'),s((2:end)'))) = [];%delete first of two same field
dest = cell2struct(values(idx),names(idx),2);

end


