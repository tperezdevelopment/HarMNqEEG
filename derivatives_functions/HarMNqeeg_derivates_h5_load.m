function [data, global_att, dset_att] = HarMNqeeg_derivates_h5_load(h5_filename, dsetname)
%     Original code Author: Sc.D. Jorge F. Bosch-Bayard. Montreal Neurological Institute
%     Modified Tool Author: Eng. Tania Perez Ramirez <tperezdevelopment@gmail.com>. Cuban Center for Neurosciences
%     Copyright(c): 2022 Jorge F. Bosch-Bayard <oldgandalf@gmail.com>


[~, ~, ee]=fileparts(h5_filename);
if ~strcmpi(ee, '.h5')
    h5_filename = [h5_filename '.h5'];
end

if ~exist(h5_filename, 'file')
    error([h5_filename ' does not exist']);
end

try
    att = h5info(h5_filename);
catch
    error([h5_filename ' is not a valid HDF5 file']);
end

global_att = [];
for k=1:length(att.Attributes)
    s = att.Attributes(k).Name;
    s = strrep(s, ' ', '_');
    s = strrep(s, '-', '_');
    s = strrep(s, ':', '_');
    global_att.(s) = att.Attributes(k).Value;
end

if ~exist('dsetname', 'var') || isempty(dsetname)
    error(['Check the dsetname attribute: ' dsetname ' not exist or is empty']);
end
sets = char({att.Datasets.Name}');
[iex, ipos] = ismember(dsetname, sets, 'rows');

if ~iex
    error([dsetname ' does not exist in ' h5_filename]);
end

dset_att = [];
for k=1:length(att.Datasets(ipos).Attributes)
    s = att.Datasets(ipos).Attributes(k).Name;
    s = strrep(s, ' ', '_');
    s = strrep(s, '-', '_');
    s = strrep(s, ':', '_');
    dset_att.(s) = att.Datasets(ipos).Attributes(k).Value;
end

try
    if dsetname(1) ~= '/', dsetname = ['/' dsetname]; end
catch
    error(['Invalid dsetname: ' dsetname]);
end

data = h5read(h5_filename,dsetname);
sz = size(data);

switch lower(dset_att.DataType)
    case 'complex_matrix'  %recreate the data as a complex matrix
        if sz(end) ~= 2            
            error( 'Data in file is not as expected. Pls, report the error to the providers');
        end
        ne = numel(data)./2;
        data = reshape(data, ne, 2);
        data = data(:,1) + 1i*data(:,2);
        sz(end) = [];
        data = reshape(data, sz);
    case 'hermitian'
        try
            [data]= decompress_hermitian(data);
        catch ME
            rethrow(ME);
        end
    case 'symmetric'
        try
            [data] = decompress_symmetric(data);
        catch ME
            rethrow(ME);
        end
    otherwise        
        error([dset_att.DataType ': Conversion not implemented']); 
end

end

