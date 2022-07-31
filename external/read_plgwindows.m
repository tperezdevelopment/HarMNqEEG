function [data, MONTAGE, age, SAMPLING_FREQ, epoch_size, wins, msg] = read_plgwindows(plgname, state, lwin)
%plgname: nombre del PLG, con el path, sin el .PLG
%state: un caracter. ejemplo, 'A'
%lwin en seg, ejemplo: 0.005 (5 msec)

msg = ''; data = []; MONTAGE = []; age = []; SAMPLING_FREQ = []; epoch_size = []; wins = [];
[nn, ee, pp] = getfname(plgname);
try
    isPE = 0; mrk = []; npoints = [];
    [data, MONTAGE, age, SAMPLING_FREQ, epoch_size, wins, mrks] = plg_read([pp filesep nn], state, isPE, mrk, npoints);
catch
    msg =['Error reading file ' pp filesep nn '. Please check if the file exists and there are windows marked'];
    data = []; MONTAGE = []; nt = []; sp = []; return
end
if isempty(data),
    msg = ['Error loading file ' pp filesep nn '. No windows found'];
    MONTAGE = []; nt = []; sp = []; return
end
sp = 1 ./ SAMPLING_FREQ;
nt = floor(lwin / sp);  %numero de ventanas de analisis
if nt > size(data,2)
    msg = ['Error loading file ' pp filesep nn '. Size of analysis windows too big'];
    data = []; MONTAGE = []; nt = []; sp = []; return
end
MONTAGE = char(MONTAGE);

quitar = [];
csum = cumsum([1; epoch_size]);
for k=1:length(epoch_size)
    if isempty(quitar)
        quitar = [csum(k)+nt*floor(epoch_size(k)/nt):csum(k+1)-1]';
    else
        quitar = [quitar; [csum(k)+nt*floor(epoch_size(k)/nt):csum(k+1)-1]'];
    end
end
data(:,quitar) = [];
