function [DPs_table, num_subj]=gaussianize_DPs_predict(DataInfo,refM,typeLog,steps,dataFilter,batch)

%     Original code Author: Ying Wang, Min Li
%     Cbrain Tool Author: Eng. Tania Perez Ramirez <tperezdevelopment@gmail.com>
%     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
%     Joint China-Cuba LAB, UESTC, CNEURO

%% gaussianize_DPs_predict: gaussianize incoming spectrum
% DataInfo: Table of meta info table
%
% refM: the geometric mean for gaussianize incoming cross-spectrum
%
% typeLog: 'log' for spectrum,
%          'riemlog' for cross-spectrum with Riemannian Vectorization
%           other gaussianize method not support yet
%
% steps: steps and order for the preprocessing of the cross spectrum,
%         default {'ave','reg','gsf'} average refrence->regularization->global scale factor correction
%
% dataFilter: screen out some data with pair {'variableName','variableValue','variableName','variableValue', ...}
%
% batch: batch wise geometric mean, default is empty which use global geometric mean
%


%%
%     Author: Ying Wang, Min Li
%     Create Time: 2021
%     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
%     Joint China-Cuba LAB, UESTC

if nargin<2 || isempty(refM) && strcmp(typeLog,'riemlogm')
    error('please load refM from norm study')
end

if nargin<3 || isempty(typeLog)
    error('The parameter typeLog is required');
end

if nargin<4 || isempty(steps)
    steps={'ave','reg','gsf'};
end
if nargin<5 || isempty(dataFilter)
    dataFilter=[];%paires of key and value
end
if nargin<6 || isempty(batch)
    batch=[];% batch for geometric mean
end


switch typeLog
    case {'log'}
        logfun=@log10;
    case {'riemlogm'}
        logfun=@vecRieMap;
    otherwise
        error('missing match type of log')
end

%% ====main Riemann mapping of cross-spectrum matrix===========
%1- group data by Manifolds of single frequencies for all subjects
%2- calculate Riemann mean
%3- logMap form manifold to Eculiden sapce  Pennec et al., 2006

if ~isempty(dataFilter)
    DataInfo=get_subtable(DataInfo,dataFilter);
end
assert(sum(strcmp(DataInfo.Properties.VariableNames,'path')),'need path in the data information table');
file_data=DataInfo.path;
assert(prod(isexist(file_data,'file')),'missing file');
%% initialize
num_channel=19-1;
num_subj=length(file_data);
num_freq_raw=49;
freq_point_start=3;% larger than 1.1hz with the resolution of 0.3xxx
freq_point_end=num_freq_raw;
num_freq=freq_point_end-freq_point_start+1;

fCrossMHS=zeros(num_channel,num_channel,num_subj,num_freq);%num_channel=18 after average reference
freqrange=zeros(num_subj,num_freq);
%% 1-average reference 2-globalscale factorization 3-regulization
for i=1:num_subj
    load(file_data{i},'data_struct');
    NTapers=data_struct.nepochs;
    CrossMHSR=aveGsfReg(data_struct.CrossM(:,:,freq_point_start:freq_point_end),steps,NTapers);
    fCrossMHS(:,:,i,:)=CrossMHSR;
    freqrange(i,:)=data_struct.freqrange(freq_point_start:freq_point_end);%data_struct.freqrange IS FOR RAW, we don't use interpolate Spec, that makes spec and cross spect confuse
end
%% out put factor data
inform={'name','nameInRawData','country','counryInRawData','age','sex','ref','datasetName','device','study','EegMachineInRawData','nepochs','freqres','disease'};
DPs_table=get_subtable(DataInfo,[],inform);
DPs_table=repmat(DPs_table,[num_freq,1]);

%% add freqrange to gam table
DPs_table.freq=freqrange(:);

%% manifold mapping of each freq point
if sum(strcmp(func2str(logfun),{'vecRieMap','logmtensor'}))>0 && isempty(batch)
    num_voxel=(num_channel-1)*num_channel/2 + num_channel;
    veclogS=zeros(num_voxel,num_subj,num_freq);
    for i = 1:num_freq % for each independent frequency
        %Calculate the Riemannian Mean and do the mapping to the tangent space
        [veclogS(:,:,i)] = logfun(fCrossMHS(:,:,:,i),refM(:,:,i)); % num_voxel , Nsubject , frequency
    end
elseif sum(strcmp(func2str(logfun),{'vecRieMap','logmtensor'}))>0 && ~isempty(batch)
    batchCat=unique(DataInfo.(batch));
    num_batch=numel(batchCat);

    num_voxel=(num_channel-1)*num_channel/2 + num_channel;
    veclogS=zeros(num_voxel,num_subj,num_freq);

    for ibatch=1:num_batch
        [~,idx_batch]=get_subtable(DataInfo,{batch,batchCat{ibatch}});
        for i = 1:num_freq % for each independent frequency
            %Calculate the Riemannian Mean and do the mapping to the tangent space
            [veclogS(:,idx_batch,i)] = logfun(fCrossMHS(:,:,idx_batch,i),refM(:,:,ibatch,i)); % num_voxel , Nsubject , frequency
        end
    end
elseif strcmp(func2str(logfun),{'log10'})
    idx_diag=repmat(diag(true(num_channel,1)),[1,1,num_subj,num_freq]);
    num_voxel=num_channel;
    fCrossMHS=reshape(fCrossMHS(idx_diag),[num_voxel,num_subj,num_freq]);
    [veclogS] = log(fCrossMHS); % num_voxel , num_subj , num_freq
else
    error('no such approach');
end
%% reshape
veclogS=permute(veclogS,[2,3,1]);%num_subj, num_freq, num_voxel
veclogS=reshape(veclogS,[],num_voxel);
%% save temp result
% log_path=path_save;
% test_folder(log_path);
% file_workspace=[log_path,filesep,'workspace_',mfilename,'_',num2str(num_subj),'.mat'];
% if ~isempty(tag)
%     file_workspace=strrep(file_workspace,'.mat',['_',tag,'.mat']);
% end
% save(file_workspace)


%% assign DPs data to table
if sum(strcmp(func2str(logfun),{'vecRieMap', 'vecRieTan','logmtensor'}))>0
    logS_head=get_spec_hearder([],typeLog);
else
    logS_head=get_spec_hearder('diag',typeLog);
end
for i=1:num_voxel
    DPs_table.(logS_head{i})=veclogS(:,i);
end

end