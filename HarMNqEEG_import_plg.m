function [all_data] = HarMNqEEG_import_plg(filepath, metadata_table, pos)
% This function will import and calculate all the steps for PLG format

%% declare statics variables
state='A';
lwin=2.56;

[~, data_code, ~]=fileparts(filepath);

%% Calling functions from old qeegt
[data, MONTAGE, ~, SAMPLING_FREQ, epoch_size, ~, msg] = read_plgwindows([filepath filesep data_code], state, lwin);

if ~isempty(msg)
   error(msg);
end    

nd=size(data,1);
nt=size(data,2)/size(epoch_size,1);
ne=size(epoch_size,1);
all_data.data=reshape(data,[nd, nt, ne]);

all_data.sampling_freq=SAMPLING_FREQ;
all_data.cnames=MONTAGE;

all_data.data_code=data_code;


%% Get the metada
try
    all_data.reference=char(metadata_table.reference(pos));
    all_data.age=double(metadata_table.age(pos));
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

