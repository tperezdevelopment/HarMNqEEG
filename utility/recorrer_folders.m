function [filenames,pathnames] = recorrer_folders(dirFolders)
if ~isfolder(dirFolders)
    error(['You should check the folder path: ' dirFolders ' is not a correct folder']);
end

listing=dir(dirFolders);
j=0;
for i=1:size(listing,1)
    if(~strcmp('.',listing(i).name) && ~strcmp('..',listing(i).name))
        j=j+1;
        filenames{j}=listing(i).name;  %#ok<*SAGROW>
        pathnames{j}=[listing(i).folder filesep listing(i).name];
    end
end
end

