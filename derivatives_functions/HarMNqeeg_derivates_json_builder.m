function [jsonFile] = HarMNqeeg_derivates_json_builder(jsonFile,dsetname,dtype, DsetAttr)

%% Adding Attributes to jsonFile
jsonFile.(dsetname).DataType=convertCharsToStrings(dtype);

if strcmpi(dtype,'Complex_Matrix')
    jsonFile.(dsetname).Storage="The first and second component of the last dimension are correspondingly the real and the imaginary parts of the matrix";
end
if strcmpi(dtype,'Hermitian')
    jsonFile.(dsetname).Storage= "Optimized according the specification in https://portal.hdfgroup.org/display/HDF5/HDF5";
end

if exist('DsetAttr', 'var') && ~isempty(DsetAttr)
    for k=1:size(DsetAttr,1)
      jsonFile.(dsetname).(DsetAttr{k,1})=convertCharsToStrings(DsetAttr{k,2});
    end
end


end

