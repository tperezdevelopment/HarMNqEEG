clear; clc;

addpath(genpath(pwd));

%% For generate the cross spectra options
% raw_data_path=[pwd filesep 'example_data' filesep 'raw_data'];
% generate_cross_spectra=1;
% outputFolder_path=[pwd filesep 'HARMNqEEG_Result_raw_data'];
% % outputFolder_path='';
% subjects_metadata=[pwd filesep 'example_data' filesep 'raw_data_table.mat'];

%% for cross spectra with other options
raw_data_path=[pwd filesep 'example_data' filesep 'without_the_cross_spectra_generated'];
generate_cross_spectra=1;
outputFolder_path=[pwd filesep 'HARMNqEEG_Result_without_the_cross_spectra_generated'];
subjects_metadata='';

%% For cross spectra generated
% raw_data_path=[pwd filesep 'example_data' filesep 'with_cross_spectra_generated'];
% generate_cross_spectra=0;
% outputFolder_path=[pwd filesep 'HARMNqEEG_Result_with_cross_spectra_generated'];
% subjects_metadata='';

% typeLog='1 1'; Or
typeLog(1)=true;
typeLog(2)=true;

% optional_matrix='1 1'; Or 
optional_matrix(1)=1;
optional_matrix(2)=1;

% batch_correction=6; %or% batch_correction='';

batch_correction=6;

if exist(outputFolder_path, 'dir')
    close all;
    diary off;    
    rmdir(outputFolder_path, 's');
    pause(0.50) %in seconds
end



HarMNqEEG_main(generate_cross_spectra, raw_data_path,subjects_metadata, typeLog,batch_correction, optional_matrix, outputFolder_path);













