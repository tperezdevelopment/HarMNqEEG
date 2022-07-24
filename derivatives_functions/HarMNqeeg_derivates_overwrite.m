function [jsonFile] = HarMNqeeg_derivates_overwrite(h5_file_full_path, jsonFile, dsetname, dtype, prec, data, DsetAttr)

%% init a few manually attributes
overw=true;
perc_compres = 7; 

%% Save new Data in .h5 file
HarMNqeeg_derivates_h5_builder(h5_file_full_path,dsetname,data,DsetAttr,dtype, overw, prec, perc_compres);


%% Save new info into json file
[jsonFile] = HarMNqeeg_derivates_json_builder(jsonFile,dsetname,dtype, DsetAttr);


end

