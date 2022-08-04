function [] = saveJSON(data,output_file)
%SAVEJSON this take from BC-VARETA toolbox 08-04-2020 
%Modified by tperezdevelopment 12-04-2022
 
data = jsonencode(data, PrettyPrint=true);
fid = fopen(output_file, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid, data, 'char');
fclose(fid);
end

