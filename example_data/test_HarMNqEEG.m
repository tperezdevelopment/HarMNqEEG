clear; clc;

addpath(genpath(pwd));

%% For generate the cross spectra options
raw_data_path='C:\Users\tperezdevelopment\Desktop\lectura de datos\datos_plg';
generate_cross_spectra=1;
outputFolder_path=[pwd filesep 'HARMNqEEG_Result_lectura_datos2_PLG'];
subjects_metadata='C:\Users\tperezdevelopment\Desktop\lectura de datos\tabla_plg.xlsx';

%% for cross spectra with other options
% raw_data_path=[pwd filesep 'example_data' filesep 'without_the_cross_spectra_generated'];
% generate_cross_spectra=1;
% outputFolder_path=[pwd filesep 'HARMNqEEG_Result_without_the_cross_spectra_generated'];
% subjects_metadata='';

%% For cross spectra generated
% raw_data_path=[pwd filesep 'example_data' filesep 'with_cross_spectra_generated'];
% generate_cross_spectra=0;
% outputFolder_path=[pwd filesep 'HARMNqEEG_Result_with_cross_spectra_generated'];
% subjects_metadata='';

typeLog='1 1';

optional_matrix='1 1';

batch_correction=6; %or% batch_correction='';

diary off;
if exist(outputFolder_path, 'dir')
   rmdir(outputFolder_path, 's');
end    

HarMNqEEG_main(outputFolder_path, generate_cross_spectra,subjects_metadata, raw_data_path, typeLog,batch_correction, optional_matrix);













