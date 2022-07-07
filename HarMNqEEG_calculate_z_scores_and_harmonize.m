function [mnhs] = HarMNqEEG_calculate_z_scores_and_harmonize(typeLog, file_DPs_table,reRefBatch, output_folder_tmp)

switch typeLog
    case 'log'
%         norm=[filesep 'bin' filesep 'data' filesep 'norm' filesep 'norm_log_gfavfa_bfvf_study.mat'];
          norm= 'norm_log_gfavfa_bfvf_study.mat';
    case  'riemlogm'
%         norm=[filesep 'bin' filesep 'data' filesep 'norm' filesep 'norm_riemlogm_gfavfa_bava_study.mat'];
          norm='norm_riemlogm_gfavfa_bava_study.mat';
end
% load neccesary variables for the prediction, which defined in training progress
%   tregs: saved regression model for training data table
%   level: levels definition of the hamonization model
%   batch: batch definition, which has to match the norm file load above,
%          which fixed to {'study'} as the result of model compare in the paper
%   resp: responses to be regressed
%   opt: options of the regression parameter
mnhs=load(norm,'tregs','level','batch','resp','opt');
% batch definition, which has to match the norm file load above

mnhs.path_table=file_DPs_table;
mnhs.path_out=output_folder_tmp;
mnhs.tag='zscore';

if isempty(reRefBatch)
    mnhs.reRefBatch={};    
    %%global options by tperezdevelopment, note: this will for the existing
    %%.mat file with the norm
    mnhs.level=mnhs.level(1);
    mnhs.tregs=mnhs.tregs(1);
else
    mnhs.reRefBatch=reRefBatch;
end  

% mnhs.batch={'study'};  %%this parameter, for this version, is fixed

% load data with the information above
mnhs=mnh_create_predict(mnhs);

%% the table with harmonized data and its zscore will be saved in the caller
mnhs=MnhCaller(mnhs);

end

