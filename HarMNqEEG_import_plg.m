function [all_data] = HarMNqEEG_import_plg(filepath, all_data)
% This function will import and calculate all the steps for PLG format

%% declare statics variables
state='A';
lwin=2.56;

[~, data_code, ~]=fileparts(filepath);

%% Calling functions from old qeegt
[data, ~, ~, SAMPLING_FREQ, ~, ~, msg] = read_plgwindows([filepath filesep data_code], state, lwin);

if ~isempty(msg)
    error(msg);
end

nd=size(data,1);
nt=SAMPLING_FREQ*lwin; %% by default 200 Hz * 2.56 sec=512
ne=size(data,2)/nt;
all_data.data=reshape(data,[nd, nt, ne]);

all_data.sampling_freq=SAMPLING_FREQ;

%% Change in montage assuming the default montage
all_data.cnames={'Fp1'    'Fp2'    'F3'    'F4'    'C3'    'C4'    'P3'    'P4'    'O1'    'O2'    'F7'    'F8'    'T3'    'T4'    'T5'    'T6'    'Fz'    'Cz'    'Pz'}';

all_data.data_code=data_code;


end

