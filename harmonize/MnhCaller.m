function mnhs=MnhCaller(mnhs)
 %%
 %     Author: Ying Wang, Min Li
 %     Create Time: 2021
 %     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
 %     Joint China-Cuba LAB, UESTC
 

% dbstop if error Commented by tperezdevelopment for compiled version
%% record
[~,filename]=fileparts(mnhs.path_table);
filename=[mnhs.path_out,filesep,filename,'_',mnhs.tag];
mnhs.time_start=datetime;
mnhs = mnhs.mnhfun(mnhs);%
%% only for model compare
if isfield(mnhs,'only_criteria')&& mnhs.only_criteria
    warning('not save T and tregs, to save time')
    mnhs.T=[];
    mnhs.tregs=[];
end
%% change the batch back to the orignal from the refrence batch
if ~isempty(mnhs.reRefBatch)
    mnhs.Ttest=asnarray2table(mnhs.Ttest,{'orignalBatch',setdiff(unique(mnhs.Ttest.orignalBatch),{''})},mnhs.batch,mnhs.reRefBatch(:,1));
end

%% save result modified by tperezdevelopment
writetable(mnhs.Ttest,[filename,'.csv']); %%save in csv file
% Predict_zscore_table=mnhs.Ttest;
% save([filename,'.mat'], 'Predict_zscore_table');
disp(['finish ',mfilename,'-',func2str(mnhs.mnhfun),'-',mnhs.tag]);
mnhs.time_finish=datetime;

