function [all_data] = HarMNqEEG_read_subjects_metadata(subjects_metadata,data_code)
%% Reading subjects metatada

%% Checking metadata for data_code

[~,~,ext]=fileparts(subjects_metadata);

switch ext
    case '.csv'
        metadata_table = readtable(subjects_metadata);

    case '.tsv'
        metadata_table = readtable(subjects_metadata, 'FileType', 'text','Delimiter', '\t',...
            'TreatAsEmpty', {'N/A','n/a'});
    case '.mat'
        metadata_table=importdata(subjects_metadata);
end


[~, pos] = ismember({data_code},metadata_table.data_code);
if pos==0
    error([data_code ' not found in the subjects metadata file']);
end

%% Get the metada
try
    all_data.reference=char(metadata_table.reference(pos));
    if iscell(metadata_table.age(pos))
        all_data.age=str2double(strrep(cell2mat(metadata_table.age(pos)),',','.'));
    else %%is double
       all_data.age=metadata_table.age(pos);
    end   
    if isempty(metadata_table.sex(pos))
        all_data.sex={'U'};
    else
        all_data.sex=metadata_table.sex(pos);
    end
    all_data.country=char(metadata_table.country(pos));
    all_data.eeg_device=char(metadata_table.eeg_device(pos));
catch ME
    rethrow(ME);
end

end

