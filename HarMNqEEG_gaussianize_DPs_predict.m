function [veclogS ] = HarMNqEEG_gaussianize_DPs_predict(data_struct,refM,typeLog,steps)
%     Original code Author: Ying Wang, Min Li
%     Cbrain Tool Author: Eng. Tania Perez Ramirez <tperezdevelopment@gmail.com>
%     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
%     Joint China-Cuba LAB, UESTC, CNEURO

% steps: steps and order for the preprocessing of the cross spectrum,
% default {'ave','reg','gsf'} average refrence->regularization->global scale factor correction
%% ====main Riemann mapping of cross-spectrum matrix===========
%1- group data by Manifolds of single frequencies for all subjects
%2- calculate Riemann mean
%3- logMap form manifold to Eculiden sapce  Pennec et al., 2006


if nargin<2 || isempty(refM) && strcmp(typeLog,'riemlogm')
    error('please load refM from norm study')
end

if nargin<3 || isempty(typeLog)
    error('The parameter typeLog is required');
end

if nargin<4 || isempty(steps)
    steps={'ave','reg','gsf'};
end

switch typeLog
    case {'log'}
        logfun=@log10;
    case {'riemlogm'}
        logfun=@vecRieMap;
    otherwise
        error('missing match type of log')
end


%% initialize
num_channel=19-1;
num_freq_raw=49;
freq_point_start=3;% larger than 1.1hz with the resolution of 0.3xxx
freq_point_end=num_freq_raw;
num_freq=freq_point_end-freq_point_start+1;

fCrossMHS=zeros(num_channel,num_channel,num_freq);%num_channel=18 after average reference
NTapers=data_struct.nepochs;
CrossMHSR=aveGsfReg(data_struct.CrossM(:,:,freq_point_start:freq_point_end),steps,NTapers);
fCrossMHS(:,:,:)=CrossMHSR;

%% manifold mapping of each freq point
if sum(strcmp(func2str(logfun),{'vecRieMap','logmtensor'}))>0
    num_voxel=(num_channel-1)*num_channel/2 + num_channel;
    veclogS=zeros(num_voxel,num_freq);
    for i = 1:num_freq % for each independent frequency
        %Calculate the Riemannian Mean and do the mapping to the tangent space
        [veclogS(:,i)] = logfun(fCrossMHS(:,:,i),refM(:,:,i)); % num_voxel , Nsubject , frequency
    end
elseif strcmp(func2str(logfun),{'log10'})
    idx_diag=repmat(diag(true(num_channel,1)),[1,1,num_freq]);
    num_voxel=num_channel;
    fCrossMHS=reshape(fCrossMHS(idx_diag),[num_voxel,num_freq]);
    [veclogS] = log(fCrossMHS); % num_voxel, num_freq    
else
    error('no such approach');
end

%% reshape
veclogS=permute(veclogS,[2,3,1]);% num_freq, num_voxel
veclogS=reshape(veclogS,[],num_voxel);





end

