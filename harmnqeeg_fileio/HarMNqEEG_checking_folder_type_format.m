function [type] = HarMNqEEG_checking_folder_type_format(filename)
% Checking format for folder data

[~,data_code,~] = fileparts(filename);
[~,pathnames] = recorrer_folders(filename);

if startsWith(data_code, 'sub-') % checking is bids
    if ~ismember('eeg', pathnames)
        error('The structure BIDS must be contain a eeg folder');
    end
    type='bids';
elseif ismember([data_code, '.PLG'], pathnames)  || ismember([data_code, '.plg'], pathnames)
    if ~ismember([data_code, '.WIN'], pathnames) && ~ismember([data_code, '.win'], pathnames)
        error('For this tool the plg must be contain .win file');
    end
    type='plg';
else
    error(['Please check your data for ' data_code ' subject folder. Must be a BIDS format or PLG']);
end


end

