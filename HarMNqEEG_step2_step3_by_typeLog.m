function [T] = HarMNqEEG_step2_step3_by_typeLog(data_struct, typeLog, reRefBatch)
%% Call the step 2 and step 3


%% BEGIN STEP 2 Gaussianize_DPs_predict: gaussianize incoming spectrum
% Declare variables that for future may be will request to the user
steps={'ave','reg','gsf'};
%%preprocess step
switch typeLog
    case 'log'
        [veclogS]= HarMNqEEG_gaussianize_DPs_predict(data_struct,[],typeLog,steps);
    case  'riemlogm'
        load( 'refM_riemlogm_global_1564.mat','refM');
        [veclogS]= HarMNqEEG_gaussianize_DPs_predict(data_struct,refM,'riemlogm',steps);
end



%% STEP 3 Calculation of the z-scores and the hamornized steps
% Get DPs_table for calculate Step 3
try
    [DPs_table] = HarMNqEEG_genMetaDataTable(data_struct, veclogS, typeLog);
catch ME
    rethrow(ME);
end


% Creating tmp folder
test_folder([pwd filesep 'tmp']);
file_DPs_table_csv=[pwd filesep 'tmp' filesep 'DPs_table.csv'];
writetable(DPs_table,file_DPs_table_csv);
[mnhs]=HarMNqEEG_calculate_z_scores_and_harmonize(typeLog, file_DPs_table_csv,reRefBatch,[pwd filesep 'tmp'] );

T=mnhs.Ttest;

% Deleting the tmp folder
try
    if exist([pwd filesep 'tmp'], 'dir')
        rmdir([pwd filesep 'tmp'], 's');
    end
catch ME
    rethrow(ME);
end



end

