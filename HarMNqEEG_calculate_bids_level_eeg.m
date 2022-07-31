function [] = HarMNqEEG_calculate_bids_level_eeg(filepath, typeLog, metadata_table, data_code_position, batch_correction, outputFolder_path, optional_matrix)
%% Calculate for each eeg file in eeg folder

% Create output folder and subfolders
derivatives_output_folder=[outputFolder_path filesep 'eeg'];
test_folder(derivatives_output_folder);
[~,allFiles] = recorrer_folders(fullfile(filepath, 'eeg'));
for eeg_i=1:length(allFiles)
    [~, data_code, ext]=fileparts(cell2mat(allFiles(eeg_i)));
    if strcmp(ext, '.edf') ||  strcmp(ext, '.eeg') || strcmp(ext, '.edf') || strcmp(ext, '.vhdr') || strcmp(ext, '.vmrk') ...
            || strcmp(ext, '.set') || strcmp(ext, '.fdt') || strcmp(ext, '.bdf')
        [all_data] = HarMNqEEG_read_data_fileio(cell2mat(allFiles(eeg_i)), metadata_table, data_code_position);
        %% Disp information. Begin process by case
        disp(['BEGIN PROCESS FOR ', data_code]);
        HarMNqEEG_all_steps(derivatives_output_folder,typeLog, all_data, data_code, batch_correction, optional_matrix);
        %% Disp information. End process by case
        disp(['END PROCESS FOR ', data_code]);


    end

end
end

