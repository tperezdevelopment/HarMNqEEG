function [all_data] = HarMNqEEG_import_txt(filepath, metadata_table, pos)
% This function will import txt data

[~, data_code, ~]=fileparts(filepath);

%% Calling functions from old qeegt
[data_txt] = load_txt(filepath);

nd=size(data_txt.data,1);
nt=data_txt.epoch_size; %% by default 200 Hz * 2.56 sec=512
ne=size(data_txt.data,2)/nt;
all_data.data=reshape(data_txt.data,[nd, nt, ne]);

all_data.sampling_freq=data_txt.SAMPLING_FREQ;

%% Change in montage assuming the default montage
channels=cellstr(string(data_txt.montage));
if strcmp(channels(1), '1  -REF')
    all_data.cnames={'Fp1'    'Fp2'    'F3'    'F4'    'C3'    'C4'    'P3'    'P4'    'O1'    'O2'    'F7'    'F8'    'T3'    'T4'    'T5'    'T6'    'Fz'    'Cz'    'Pz'}';
else 
    all_data.cnames=channels;
end
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

