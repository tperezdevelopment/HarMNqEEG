function [] = HarMNqeeg_derivates_h5_builder(h5_file_full_path,dsetname,data,DsetAttr,dtype, overw, prec, perc_compres)
%     Original code Author: Sc.D. Jorge F. Bosch-Bayard. Montreal Neurological Institute
%     Modified Tool Author: Eng. Tania Perez Ramirez <tperezdevelopment@gmail.com>. Cuban Center for Neurosciences
%     Copyright(c): 2022 Jorge F. Bosch-Bayard <oldgandalf@gmail.com>

if ~exist('overw', 'var'), overw = true; end

if isempty(dsetname)
    error(['Invalid dsetname: ' dsetname]);
elseif dsetname(1) ~= '/'
    dsetname = ['/' dsetname];
end

switch dtype
    case 'Hermitian'
        try
            if ~isreal(data)
                [data] = compress_hermitian(data);
            end
        catch ME
            rethrow(ME);
        end
    case 'Symmetric'
        try
            [data] = compress_symmetric(data);
        catch ME
            rethrow(ME);
        end
    case 'Complex_Matrix'
        sz = size(data);
        v = zeros(numel(data),2);
        v(:,1) = real(data(:));
        v(:,2) = imag(data(:));
        data = reshape(v, [sz 2]);
    case 'Real_Matrix'
        %% do not doing nothing
end

switch lower(prec)
    case 'double'
        data = double(data);
    case 'single'
        data = single(data);
    case 'int32'
        data = int32(data);
    otherwise
        error(['Sorry: data type ' prec 'not implemented yet']);
end


sz = size(data);
try
    h5create(h5_file_full_path,dsetname,sz,'Datatype',prec,'ChunkSize',sz,'Deflate',perc_compres);
    fid = H5F.open(h5_file_full_path,'H5F_ACC_RDWR','H5P_DEFAULT');
    if (fid > 0) && overw %%dsetname exists, now will overwrite existing content
        H5L.delete(fid,dsetname,'H5P_DEFAULT')
        H5F.close(fid)
    elseif (fid > 0) && ~overw %%dsetname exists, keeping existing. Exiting
        H5F.close(fid)
        return
    end
catch ME
    %dsetname does not exist. Continue to create it
    ex = ME;
    if strcmpi(ex.identifier, 'MATLAB:imagesci:h5create:datasetAlreadyExists')
        if overw %%dsetname exists, now will overwrite existing content
            fid = H5F.open(h5_file_full_path,'H5F_ACC_RDWR','H5P_DEFAULT');
            H5L.delete(fid,dsetname,'H5P_DEFAULT')
            H5F.close(fid)
            h5create(h5_file_full_path,dsetname,sz,'Datatype',prec,'ChunkSize',sz,'Deflate',perc_compres);
        else %%dsetname exists, keeping existing. Exiting
            H5F.close(fid)
            error([dsetname ' exists and not overwriting']);
        end
    else
        rethrow(ME);
    end
end

h5write(h5_file_full_path,dsetname,data);

if exist('DsetAttr', 'var') && ~isempty(DsetAttr)
    for k=1:size(DsetAttr,1)
        h5writeatt(h5_file_full_path,dsetname,DsetAttr{k,1}, DsetAttr{k,2});
    end
end

h5writeatt(h5_file_full_path,dsetname,'DataType', dtype);

if strcmpi(dtype,'Complex_Matrix')
    h5writeatt(h5_file_full_path,dsetname,'Storage', 'The first and second component of the last dimension are correspondingly the real and the imaginary parts of the matrix');
end
if strcmpi(dtype,'Hermitian')
    h5writeatt(h5_file_full_path,dsetname,'Storage', 'Optimized according the specification in https://github.com/tperezdevelopment/HarMNqEEG#harmnqeeg-output-description');
end

end

