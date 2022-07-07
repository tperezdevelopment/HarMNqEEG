function [jsonFile] = HarMNqeeg_derivates_overwrite(h5_file_full_path,perc_compres, jsonFile, dsetname, dtype, prec, data, DsetAttr)

overw=true;

%% Save new Data in .h5 file
HarMNqeeg_derivates_h5_builder(h5_file_full_path,dsetname,data,DsetAttr,dtype, overw, prec, perc_compres);


%% Save new info into json file
[jsonFile] = HarMNqeeg_derivates_json_builder(jsonFile,dsetname,dtype, DsetAttr);


end

