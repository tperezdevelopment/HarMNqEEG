function [DPs_table] = HarMNqEEG_genMetaDataTable(data_struct, veclogS, typeLog)
%% The objetive funtion is convert input data in a required table for the run the stpe 3

DPs_table=struct();


% Declare variables that for future may be will request to the user
num_freq=47;
freq_point_start=3;
freq_point_end=49;


switch typeLog
    case 'log'
        logfun=@log10;
    case  'riemlogm'
        logfun=@vecRieMap;
end

% get country
try
    country=data_struct.country;
catch
    country=data_struct.pais;
end


DPs_table.name=[country '_' data_struct.EEGMachine '_' data_struct.name];
DPs_table.country=country;
if isnan(data_struct.age)
    error('Missing info Age');
else
    DPs_table.age=data_struct.age;
end

if isnan(data_struct.sex)
    warning('Missing info Sex');
else
    switch  data_struct.sex
        case {''}
            error('The')
        case {'F','w',70,0,'female'}
            DPs_table.sex='F';
        case {'M','m',77,1,'male'}
            DPs_table.sex='M';
        otherwise
            DPs_table.sex=data_struct.sex;
            warning('Check info sex, %s is not a valid value', data_struct.sex);
    end
end




DPs_table.ref=data_struct.ref;
DPs_table.device=data_struct.EEGMachine;
DPs_table.study=[country '_' data_struct.EEGMachine];
DPs_table.nepochs=data_struct.nepochs;
DPs_table.freqres=data_struct.freqres;


% Convert struct to table
DPs_table = struct2table(DPs_table);

DPs_table=repmat(DPs_table,[num_freq,1]);
freqrange=data_struct.freqrange(freq_point_start:freq_point_end);%data_struct.freqrange IS FOR RAW, we don't use interpolate Spec, that makes spec and cross spect confuse
DPs_table.freq=freqrange(:);

%% assign DPs data to table
if sum(strcmp(func2str(logfun),{'vecRieMap', 'vecRieTan','logmtensor'}))>0
    logS_head=get_spec_hearder([],typeLog);
else
    logS_head=get_spec_hearder('diag',typeLog);
end
for i=1:size(veclogS,2)
    DPs_table.(logS_head{i})=veclogS(:,i);
end



end

