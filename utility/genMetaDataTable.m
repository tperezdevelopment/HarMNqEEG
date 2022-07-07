
function T=genMetaDataTable(data_path,pathology)


%======================================================
% organized data: 1-remaned by  ID+country; 2- extract country, age, sex,
% EEGmachine, CrossM into .mat; 3-including size(crossM) into  excel
% write by: YingWang(Rigel), MinLi
% date: 2/19/2021
%===================================================

if nargin<2 || isempty(pathology)
    pathology=[];
end


subjList = dir([data_path, '/*.mat']);              % List all .mat files
fields={'name','country','age','sex','ref','device','pathology','study',...
    'srate', 'dnames','nt','nepochs','fmin','fmax','freqres','path'};

nsubs=size(subjList,1);

data_table = struct();
for i=1:numel(fields)
    data_table(nsubs).(fields{i})=[];
end
for j=nsubs:-1:1
    try
        filename=fullfile(data_path, subjList(j).name);
        data_table(j).path=filename;
        load(filename,'data_struct');     %Load  Subject
        data_struct.country= data_struct.pais;
        data_struct.device= data_struct.EEGMachine; 
        data_struct.pathology=pathology;
        flag_fullinform=true;

        if isempty(data_struct.name) || strcmp(data_struct.name, 'U')
            data_struct.name=subjList(j).name;
        end
        data_struct.name=subjList(j).name(1:end-4);
        switch  data_struct.sex
            case {'F','w',70,0,'female'}
                data_struct.sex='F';
            case {'M','m',77,1,'male'}
                data_struct.sex='M';
            otherwise
                flag_fullinform=false;
        end
        if isnan(data_struct.age)
            flag_fullinform=false;
        end
        data_table(j).path=[data_path,filesep,data_struct.name,'.mat'];

        if flag_fullinform
            data_table(j).filelog={'full info'};
        else
            data_table(j).filelog={'lost info'};
        end
        data_table(j)=copyfield(data_struct, data_table(j), fields);
        data_table(j).dnames= [data_table(j).dnames{:}];
       
        if isempty(pathology)
            data_table(j).study=[data_struct.country,'_',data_struct.EEGMachine];
        else
            data_table(j).study=[data_struct.country,'_',data_struct.EEGMachine,'_',pathology];
        end
        data_table(j).name=[data_table(j).study,'_', data_table(j).name];

    catch ME
        fprintf('organize fail for #%s: %s\n', filename,ME.message);
        data_table(j).filelog=ME.message;
    end
    fprintf('organize successful for # %s\n',filename);
end
T = struct2table(data_table);

end

