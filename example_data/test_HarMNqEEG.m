clear; clc;

raw_data_path='D:\BOSCH\CORRIDA DE DATOS PARA HARMNQEEG';
generate_cross_spectra=0;
outputFolder_path=[pwd filesep 'HARMNqEEG_Result_for_Bosch_10-07-2022_CIAABL3'];
typeLog='1 1';
batch_correction='6';

if exist(outputFolder_path, 'dir')
   rmdir(outputFolder_path, 's');
end    

HarMNqEEG_main(generate_cross_spectra,raw_data_path, typeLog, batch_correction, outputFolder_path);













