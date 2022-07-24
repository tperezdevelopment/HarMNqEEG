clear; clc;

addpath(genpath(pwd));

%% For generate the cross spectra options
% raw_data_path=[pwd filesep 'example_data' filesep 'without_the_cross_spectra_generated'];
% generate_cross_spectra=1;
% outputFolder_path=[pwd filesep 'HARMNqEEG_Result_without_the_cross_spectra_generated'];

%% For cross spectra generated
raw_data_path=[pwd filesep 'example_data' filesep 'with_cross_spectra_generated'];
generate_cross_spectra=0;
outputFolder_path=[pwd filesep 'HARMNqEEG_Result_with_cross_spectra_generated'];



typeLog='0 1';

optional_matrix='0 0';

batch_correction=6; %or% batch_correction='';

if exist(outputFolder_path, 'dir')
   rmdir(outputFolder_path, 's');
end    

HarMNqEEG_main(generate_cross_spectra,raw_data_path, typeLog, batch_correction,optional_matrix, outputFolder_path);













