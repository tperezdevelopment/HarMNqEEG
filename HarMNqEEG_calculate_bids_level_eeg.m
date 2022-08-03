function [] = HarMNqEEG_calculate_bids_level_eeg(filepath, typeLog, all_data, batch_correction, outputFolder_path, generate_cross_spectra, optional_matrix)
%% Calculate for each eeg file in eeg folder

% Create output folder and subfolders
derivatives_output_folder=[outputFolder_path filesep 'eeg'];
test_folder(derivatives_output_folder);
[~,allFiles] = recorrer_folders(fullfile(filepath, 'eeg'));
for eeg_i=1:length(allFiles)
    [~, data_code, ext]=fileparts(cell2mat(allFiles(eeg_i)));
    if strcmp(ext, '.edf') || strcmp(ext, '.bdf') %% This will be more
        [all_data] = HarMNqEEG_read_data_fileio(cell2mat(allFiles(eeg_i)), all_data);
        %% Disp information. Begin process by case
        disp(['BEGIN PROCESS FOR ', data_code]);
        HarMNqEEG_all_steps(derivatives_output_folder,generate_cross_spectra, typeLog, all_data, data_code, batch_correction, optional_matrix);
        %% Disp information. End process by case
        disp(['END PROCESS FOR ', data_code]);
    end


end
end

