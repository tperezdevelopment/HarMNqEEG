function [] = HarMNqEEG_calculate_bids(filepath, typeLog, metadata_table, data_code_position, batch_correction, outputFolder_path, optional_matrix)
% This function will import and calculate all t,he steps for BIDS format


if exist(fullfile(filepath, 'eeg'),'dir')
   HarMNqEEG_calculate_bids_level_eeg(filepath, typeLog, metadata_table, data_code_position, batch_correction, outputFolder_path, optional_matrix); 
else
    subFolders = dir(fullfile(filepath, 'ses-*'));

    for iFold = 1:length(subFolders)
        if ~exist(fullfile(filepath, subFolders(iFold).name, 'eeg'), 'dir')
            error(['Check the data for '  subFolders(iFold).name ' from '  data_code ' this must be contain the eeg folder']);
        else
           derivatives_ses_subfolders=[outputFolder_path filesep subFolders(iFold).name];
           test_folder(derivatives_ses_subfolders);
           HarMNqEEG_calculate_bids_level_eeg(fullfile(filepath, subFolders(iFold).name),typeLog, metadata_table, data_code_position, batch_correction, derivatives_ses_subfolders, optional_matrix);
        end

    end
end


end

