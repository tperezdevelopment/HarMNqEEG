function [all_data] = HarMNqEEG_read_data_fileio(filename, all_data)
% Read data with fileio from Fieltrip

[~,data_code,ext]=fileparts(filename);

%     if strcmp(ext, '.eeg') || strcmp(ext, '.edf') || strcmp(ext, '.vhdr') || strcmp(ext, '.vmrk') ...
%             || strcmp(ext, '.set') || strcmp(ext, '.fdt') || strcmp(ext, '.bdf')

if strcmp(ext, '.edf') || strcmp(ext, '.bdf')
    %% Reading Header
    try
        [hdr] = ft_read_header(filename);
    catch ME
        disp( getReport( ME, 'extended', 'hyperlinks', 'on' ) );
    end


    switch lower(ext)
        case '.set'
            if isempty(hdr.orig.epoch)
                error('The data will be need number of epochs');
            else
                number_epochs=size(hdr.orig.epoch, 2);
            end
        otherwise
            if hdr.orig.NRec<=0
                error('The data will be need number of epochs');
            else
                number_epochs=hdr.orig.NRec*hdr.orig.Dur; %% this is for the duration is more than 1 sec
            end
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
    all_data.data=reshape(dat,[hdr.nChans,hdr.Fs, number_epochs]);

else
        error(['Unknow format. Check the format for ' data_code]);
end

