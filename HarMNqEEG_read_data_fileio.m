function [all_data] = HarMNqEEG_read_data_fileio(filename, metadata_table, pos)
% Read data with fileio from Fieltrip


%% Reading Header
try
    [hdr] = ft_read_header(filename);
catch ME
     disp( getReport( ME, 'extended', 'hyperlinks', 'on' ) );
end   
if hdr.orig.NRec<=0
    error('The data will be need number of epochs');
end

all_data.sampling_freq=hdr.Fs;
label=hdr.label; %% changing the montage
label = strrep(label, 'P7', 'T3');
label = strrep(label, 'P8', 'T4');
label = strrep(label, 'T7', 'T5');
label = strrep(label, 'T8', 'T6');
all_data.cnames=label;

%% Reading eeg data
[dat] = ft_read_data(filename);
number_epochs=hdr.orig.NRec*hdr.orig.Dur; %% this is for the duration is more than 1 sec
all_data.data=reshape(dat,[hdr.nChans,hdr.Fs, number_epochs]);


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

