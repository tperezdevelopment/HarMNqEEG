function [all_data] = HarMNqEEG_read_data_fileio(filename, all_data)
% Read data with fileio from Fieltrip

[~,data_code,ext]=fileparts(filename);

if strcmp(ext, '.edf') || strcmp(ext, '.bdf') || strcmp(ext, '.set')

    all_data.data_code=data_code;

    %% Reading Header and  %% Reading eeg data
    try
        [hdr] = ft_read_header(filename);
        [dat] = ft_read_data(filename);
    catch ME
        disp( getReport( ME, 'extended', 'hyperlinks', 'on' ) );
    end

    switch ndims(dat)
        case 2
            if  strcmpi(ext, '.set')
                if isempty(hdr.nTrials)
                    error(['The data will be need number of epochs for ' data_code]);
                end
                nd=hdr.nChans;
                nt=hdr.orig.pnts; %% by default 200 Hz * 2.56 sec=512
                ne=size(data,2)/nt;
            else
                if hdr.orig.NRec<=0
                    error(['The data will be need number of epochs for ' data_code]);
                else
                    nd=hdr.nChans;
                    nt=hdr.Fs*hdr.orig.Dur; %% by default 200 Hz * 2.56 sec=512
                    ne=size(dat,2)/nt;
                end
            end
            all_data.data=reshape(dat,[nd, nt, ne]);
        case 3
            all_data.data=dat;

        otherwise
            error(['Check the data for ' data_code]);
    end


    all_data.sampling_freq=hdr.Fs;
    label=hdr.label; %% changing the montage
    label = strrep(label, 'P7', 'T3');
    label = strrep(label, 'P8', 'T4');
    label = strrep(label, 'T7', 'T5');
    label = strrep(label, 'T8', 'T6');
    all_data.cnames=label;

else
    error(['Unknow format. Check the format for ' data_code]);
end

end
