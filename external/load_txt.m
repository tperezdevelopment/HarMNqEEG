function [eeg, ok] = load_txt(eeg_fname)
% From : Qeegt toolbox
% Author: Sc.D. Jorge F. Bosch-Bayard. Montreal Neurological Institute


eeg = [];
ok = 0;
try
    fid = fopen(eeg_fname, 'r');
    nlines = 0;
    while ~feof(fid)
        txt = fgetl(fid); nlines = nlines+1;
        [desc, rest] = strtok(txt, '=');
        if isempty(rest) %no encontro el signo igual. O es un error o ya vienen los datos
            if ~all(isfield(eeg, {'age', 'montage', 'nchannels', 'SAMPLING_FREQ', 'epoch_size'}))
                return
            end
            nlines = nlines-1;
            fclose(fid);
            eeg.data = textread(eeg_fname, '%f', 'headerlines', nlines);
            nvt = length(eeg.data) ./ eeg.nchannels;
            eeg.data = reshape(eeg.data, eeg.nchannels, nvt);
            ok = 1;
        else
            rest(1) = '';
            rest = strtrim(rest);
            desc = lower(desc);
            switch lower(desc)
                case {'name', 'sex'}
                case 'sampling_freq'
                    rest = str2num(rest);
                    desc = 'SAMPLING_FREQ';
                case {'age', 'epoch_size', 'nchannels'}
                    rest = str2num(rest);
                case 'montage'
                    if ~isfield(eeg, 'nchannels')
                        fclose(fid);
                        return
                    end
                    mtg = cell(eeg.nchannels, 1);
                    for k=1:eeg.nchannels
                        mtg{k} = fgetl(fid); nlines = nlines+1;
                        mtg{k} = strrep(mtg{k}, '_', ' ');
                        mtg{k} = strtrim(mtg{k});
                    end
                    rest = char(mtg);
                otherwise
                    return
            end
            eeg.(desc) = rest;
        end
    end
    fclose(fid);
catch
    return
end
