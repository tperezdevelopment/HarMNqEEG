function [data, MONTAGE, Age, SAMPLING_FREQ, epoch_size, wins, mrks] = plg_read(basename, state, isPE, mrk, npoints)

% FUNCTION [data, MONTAGE, Age, SAMPLING_FREQ, epoch_size] = plg_read(basename, state);
% basename:   name of PLG file to read (without extension(s))
% state: EEG state. Example: 'A' -Eyes Closed; 'B' - Eyes Open; 'C' - Hyperventilation minute 1 and so on

% The function reads all epochs marked as analysis windows in the specified state ('A', 'B', 'C'). The epochs were previously marked by an expert using any of
% the EEG editors available.

% Output parameters:
% data: a matrix of Number_of_channels X Number_of_instants_of_times (bursts).
% MONTAGE: char array of channnels name
% Age: sunject's age
% SAMPLING_FREQ: sampling frequency in Hz
% epoch_size: the size of each epoch in data. sum(epoch_size) = size(data,2)
% wins: a matlab structure containing all windows marked in the PLG file, specifying: STATE, byte of start, byte of end
% mrks: a matlab structure containing the character name which identifies the mark and the byte where it is located in the PLG file.

%reading the Neuronic/Track Walker/www.cneuro.edu.cu EEG format

% Piotr J. Durka http://brain.fuw.edu.pl/~durka 2002.06.02

if ~exist('PE','var'), isPE = 0; end
if ~exist('mrk','var'), mrk = []; end
if ~exist('npoints','var'), npoints = []; end

data = []; MONTAGE = []; Age = []; SAMPLING_FREQ = []; epoch_size = []; wins = []; mrks = [];

if nargin<1
    return;
end

if isPE && ~isempty(state)
    disp('If parameter isPE is TRUE then state has to be [] and mrk a character between 0 and 9'); return
end

if isPE && isempty(mrk)
    disp('If parameter isPE is TRUE then mrk has to be a character between 0 and 9. Assumning 0');
    mrk = 0;
end

if isPE && isempty(npoints)
    disp('Parameter isPE is TRUE and windows size not specified. Assumning 512');
    noints = 512;
end

if nargin<2
    state = 'A';
end

[pp nn ee] = fileparts(basename);
basename = strrep(basename, ee, '');

pat_info = read_plgpat([basename '.pat']);
if isfield(pat_info, 'Age')
    Age = str2double(pat_info.Age);
else
    Age = [];
end

plgfname = [pp filesep nn '.xnf'];
if exist(plgfname, 'file')
    plg_info = plg_xmlread(plgfname);
    NUMBER_OF_CHANNELS =  plg_info.Record.Channels;
    MONTAGE = plg_info.Record.Montage;
    MONTAGE = strread(MONTAGE, '%s', 'delimiter', ' ');
    MONTAGE = strrep(MONTAGE, '~', '_');
    SAMPLING_FREQ = plg_info.Record.SamplingRate;
%     NUMBER_OF_SAMPLES_IN_FILE= plg_info.Record.Bursts;
    v = strtovect( plg_info.Calibration.M);
    v(1) = [];
    cdc = reshape(v, 2, NUMBER_OF_CHANNELS);
    w=plg_info.Window.A;
    if ~iscell(w)
         w = {w};
    end
    NUM_OF_WINDOWS = length(w);
    WIN_NAME = zeros(NUM_OF_WINDOWS,1);
    WIN_START = zeros(NUM_OF_WINDOWS,1);
    WIN_END = zeros(NUM_OF_WINDOWS,1);
    wnames = fields(plg_info.Title);
    wnames = str2double(strrep(wnames, 'A', ''));
    ind = find(wnames >= 'A'& wnames <= 'Z');
    wnames(ind) = char(wnames(ind));
    for k=1:NUM_OF_WINDOWS
        WIN_NAME(k) = w{k}(3);
        ii = find(ismember(wnames, WIN_NAME(k)));
        if ~isempty(ii)
            WIN_NAME(k) = wnames(ii);
        end
        WIN_START(k) = w{k}(1);
        WIN_END(k) =  WIN_START(k) + w{k}(3) - 1;
    end
    
else
%     %%%%%%% reading the age from *.PAT file (ASCII info) %%%%%
%     pat_filename=[basename '.PAT'];
%     fi=fopen(pat_filename, 'r');
%     if fi==-1
%         pat_filename=[basename '.pat'];
%         fi=fopen(pat_filename, 'r');
%         if fi==-1
%             error(sprintf('cannot open file  %s for reading', pat_filename))
%         end
%     end
%     tline=1;
%     while ~feof(fi) & tline~=-1
%         tline=fgets(fi);
%         if tline==-1
%             error('empty file???');
%         else
%             [is, tline]=strtok(tline);
%             switch is
%                 case 'Age'                      %Patient age
%                     [is, tline]=strtok(tline);   %skip & check '='
%                     if ~strcmp(is, '=')
%                         error(['missing ' is]);
%                     end
%                     [is, tline]=strtok(tline);   %skip & check '1'
%                     if ~strcmp(is, '1')
%                         error(['why not 1?']);
%                     end
%                     tline = strrep(tline, '_', ''); %to eliminate the _ characters, if present
%                     tline = deblank(tline); %removing tariling blanks
%                     Age = str2num(tline);
%                 otherwise
%                     %disp(['unused: ...' tline]);
%             end
%         end
%     end
%     fclose(fi);
%     %%%%%%%%%%%% END reading *.PAT file %%%%%%%%%%%%
%     
    %%%%%%% reading some data from *.INF file (ASCII info) %%%%%
    inf_filename=[basename '.INF'];
    fi=fopen(inf_filename, 'r');
    if fi==-1
        inf_filename=[basename '.inf'];
        fi=fopen(inf_filename, 'r');
        if fi==-1
            disp(sprintf('cannot open file  %s for reading', inf_filename)); return
        end
    end
    tline=1;
    while ~feof(fi) & tline~=-1
        tline=fgets(fi);
        if tline==-1
            error('empty file???');
        else
            [is, tline]=strtok(tline);
            switch is
                case 'PLGMontage'                %electrode names
                    [is, tline]=strtok(tline);   %skip & check '='
                    if ~strcmp(is, '=')
                        error(['missing ' is]);
                    end
                    [is, tline]=strtok(tline);
                    if NUMBER_OF_CHANNELS ~= str2num(is)
                        error('different number of channels and electrode names or channels after the montage in file');
                    end
                    
                    for i=1:NUMBER_OF_CHANNELS
                        [is, tline]=strtok(tline);
                        if isempty(is)
                            tline=fgets(fi);
                            [is, tline]=strtok(tline);
                        end
                        MONTAGE(i,:)=is;
                    end
                case 'PLGNC'                      %number of channels
                    [is, tline]=strtok(tline);   %skip & check '='
                    if ~strcmp(is, '=')
                        error(['missing ' is]);
                    end
                    [is, tline]=strtok(tline);   %skip & check '1'
                    if ~strcmp(is, '1')
                        error(['why not 1?']);
                    end
                    [is, tline]=strtok(tline);
                    NUMBER_OF_CHANNELS = str2num(is);
                case 'PLGNS'                      %number of channels
                    [is, tline]=strtok(tline);   %skip & check '='
                    if ~strcmp(is, '=')
                        error(['missing ' is]);
                    end
                    [is, tline]=strtok(tline);   %skip & check '1'
                    if ~strcmp(is, '1')
                        error(['why not 1?']);
                    end
                    [is, tline]=strtok(tline);
                    NUMBER_OF_SAMPLES_IN_FILE = str2num(is);
                case 'PLGSR(Hz)'                      %number of channels
                    [is, tline]=strtok(tline);   %skip & check '='
                    if ~strcmp(is, '=')
                        error(['missing ' is]);
                    end
                    [is, tline]=strtok(tline);   %skip & check '1'
                    if ~strcmp(is, '1')
                        error(['why not 1?']);
                    end
                    [is, tline]=strtok(tline);
                    SAMPLING_FREQ = str2num(is);
                otherwise
                    %disp(['unused: ...' tline]);
            end
        end
    end
    fclose(fi);
    %%%%%%%%%%%% END reading *.INF file %%%%%%%%%%%%
    
    
    %%%%% reading *.CDC file %%%%%%%%%%%%%%%%
    %% calibration & DC offset %%%%%%%%%%%%%%
    cdc_filename=[basename '.CDC'];
    fi=fopen(cdc_filename, 'r');
    if fi==-1
        cdc_filename=[basename '.cdc'];
        fi=fopen(cdc_filename, 'r');
        if fi==-1
            error(sprintf('cannot open file  %s for reading', cdc_filename))
        end
    end
    cdc=fread(fi, [2, NUMBER_OF_CHANNELS], 'float32');
    fclose(fi);
    %%%%%% END reading *.CDC file %%%%%%%%%%%
    
    if ~isPE
        %%%%%% reading marked windows from *.WIN file %%%%%%%%%%
        filename=[basename '.WIN'];
        fi=fopen(filename, 'r');
        if fi==-1
            filename=[basename '.win'];
            fi=fopen(filename, 'r');
            if fi==-1
                return;
                %         error(sprintf('cannot open file  %s for reading', filename))
            end
        end
        NUM_OF_WINDOWS=0;
        while ~feof(fi)
            c =fread(fi, 1, 'uint8');
            if feof(fi)
                break;
            end
            NUM_OF_WINDOWS=NUM_OF_WINDOWS+1;
            WIN_NAME(NUM_OF_WINDOWS) = c;
            WIN_START(NUM_OF_WINDOWS)=fread(fi, 1, 'integer*4');
            WIN_END(NUM_OF_WINDOWS)  =fread(fi, 1, 'integer*4');
        end
        fclose(fi);
        
        if NUM_OF_WINDOWS > 0
            wins.name = WIN_NAME;
            wins.start = WIN_START;
            wins.end = WIN_END;
        else
            wins = [];
        end
        
        %%for k=1:NUM_OF_WINDOWS
        %%    disp([WIN_NAME(k)  '  ' num2str(WIN_START(k)) '  ' num2str(WIN_END(k))  '  ' num2str(WIN_END(k) - WIN_START(k) + 1)]);
        %%end
        
        %% output to terminal -- comment out 3 following lines to turn off %%
        %for i=1:NUM_OF_WINDOWS
        %    disp(sprintf('%c(%03d) %d %d', WIN_NAME(i), WIN_NAME(i), WIN_START(i), WIN_END(i)));
        %end
        %%%%%% END  reading marked windows from *.WIN file %%%%%
    else %%reading the marks
        %%%%%% reading marked windows from *.mrk file %%%%%%%%%%
        filename=[basename '.MRK'];
        fi=fopen(filename, 'r');
        if fi==-1
            filename=[basename '.mrk'];
            fi=fopen(filename, 'r');
            if fi==-1
                return;
                %         error(sprintf('cannot open file  %s for reading', filename))
            end
        end
        NUM_OF_WINDOWS=0;
        while ~feof(fi)
            c =fread(fi, 1, 'char');
            if feof(fi)
                break;
            end
            start=fread(fi, 1, 'integer*4');
            if start - npoints > 1
                NUM_OF_WINDOWS=NUM_OF_WINDOWS+1;
                WIN_NAME(NUM_OF_WINDOWS) = c;
                WIN_START(NUM_OF_WINDOWS) = start - npoints + 1;
                WIN_END(NUM_OF_WINDOWS) = start;
            end
        end
        fclose(fi);
        
        if NUM_OF_WINDOWS > 0
            wins.name = WIN_NAME;
            wins.start = WIN_START;
            wins.end = WIN_END;
        else
            wins = [];
        end
        %%%%%% END  reading marks from *.MRK file %%%%%
    end
end    
    
%%%%% reading & calibrating data %%%%%%%%%%%%%%%%
data_filename=[basename '.PLG'];
datafile_handle=fopen(data_filename, 'r');
if datafile_handle==-1
    data_filename=[basename '.plg'];
    datafile_handle=fopen(data_filename, 'r');
    if datafile_handle==-1
        error(sprintf('cannot open file  %s for reading', data_filename));
    end
end

data = [];
epoch_size = [];
for w=1:NUM_OF_WINDOWS
    if WIN_NAME(w) == state
        fseek(datafile_handle, (WIN_START(w)-1)*NUMBER_OF_CHANNELS*2, 'bof');  %%El 2 es del sizeof de integer*2
        wdata=fread(datafile_handle, [NUMBER_OF_CHANNELS, WIN_END(w)-WIN_START(w)+1], 'integer*2');
        epoch_size = [epoch_size; WIN_END(w)-WIN_START(w)+1];
        for c=1:size(wdata,1)
            for p=1:size(wdata,2)
                wdata(c,p)=round((wdata(c,p).*cdc(1,c) - cdc(2,c)));
            end
        end
        data = [data wdata];
    end
end

fclose(datafile_handle);
%%%%%%% END reading & calibrating data %%%%%%%%%%%

if isPE
    mrks = wins; wins = [];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% END OF GENERAL READING ROUTINES %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
