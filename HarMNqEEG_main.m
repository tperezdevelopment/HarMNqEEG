function [] = HarMNqEEG_main(generate_cross_spectra,raw_data_path, typeLog,batch_correction, outputFolder_path)

%     Original code Author: Ying Wang, Min Li
%     Cbrain Tool Author: Eng. Tania Perez Ramirez <tperezdevelopment@gmail.com>
%     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
%     Joint China-Cuba LAB, UESTC, CNEURO


% HarMNqEEG TOOL DESCRIPTION
% % These results contribute to developing bias-free, low-cost neuroimaging technologies applicable in various health settings.
% % In this first version, we calculate the harmonized qEEG for the 19 channels of the S1020 montage.
% % We additionally apply the Global Scale Factor (GSF, Hernandez-Caceres et al., 1994) correction, which accounts for the percent
% % of the variability in the EEG that is not due to the neurophysiological activity of the person, but rather than to impedance
% % at the electrodes, skull thickness, hair thickness, and some other technical aspects. This GSF correction has the effect of
% % eliminating a scale factor that affects the signal amplitude and refers all the recordings to a common baseline, which makes
% % the recordings more comparable. Also, the EEG recordings are all re-reference to the Average Reference montage, which is a popular
% % choice in qEEG and also eliminates the dependence of the EEG amplitude from the physical site where the reference electrode was located.


% INPUT PARAMETERS:
% % Auxiliar inputs
%%% outputFolder_path ----------> Path of output folder
%%% generate_cross_spectra -----> Boolean parameter. Case False (0), will not  necessarily
%%%                               calculate the cross spectra. Case True
%%%                               (1) is required to calculate the cross spectra

% % Data Gatherer
%%% raw_data_path -------------> Folder path of the raw data in .mat format. This folder
%%%                              contains subfolders by each subject. The
%%%                              subfolder contains a .mat file with the
%%%                              following parameters:
%%%                                 - data          : an artifact-free EEG scalp data matrix, organized as nd x nt x ne, where
%%%                                                   nd : number of channels
%%%                                                   nt : epoch size (# of instants of times in an epoch)
%%%                                                   ne : number of epochs
%%%                                 - sampling_freq : sampling frequency in Hz. Eg: 200
%%%                                 - cnames        : a cell array containing the names of the channels. The expected names are:
%%%                                                   'Fp1'    'Fp2'    'F3'    'F4'    'C3'    'C4'    'P3'    'P4'    'O1'    'O2'    'F7'    'F8'    'T3'    'T4'    'T5'    'T6'    'Fz'    'Cz'    'Pz'
%%%                                                   If the channels come in another order, they are re-arranged according to the expected order
%%%                                 - data_code     : is the name of the original data file just for purpose of identification.
%%%                                                   It can be a code used by the owner to identify the data.
%%%                                 - reference     : a string containing the name of the reference of the data.
%%%                                 - age           : subject's age at recording time
%%%                                 - sex           : subject's sex
%%%                                 - country       : country providing the data
%%%                                 - eeg_device    : EEG hardware where the data was recorded



%% Preproccess Guassianize Data %%
%%% typeLog ----------> Type of gaussianize method to apply. Options:
%%%                     typeLog(1)-> for log (Boolean):     log-spectrum
%%%                     typeLog(2)-> for riemlogm (Boolean): cross-spectrum with riemannian metric


%% Calculate z-scores and harmonize %%
%%% batch_correction --> List of the batch correction that we have. Options:
%%%                      1->  ANT_Neuro-Malaysia
%%%                      2->  BrainAmp_DC-Chengdu_2014
%%%                      3->  BrainAmp_MR_plus_64C-Chongqing
%%%                      4->  BrainAmp_MR_plus-Germany_2013
%%%                      5->  DEDAAS Barbados1978
%%%                      6->  DEDAAS-NewYork_1970s
%%%                      7->  EGI-256 HCGSN_Zurich(2017)-Swiss
%%%                      8->  Medicid-3M Cuba1990
%%%                      9->  Medicid-4 Cuba2003
%%%                      10-> Medicid_128Ch-CHBMP
%%%                      11-> NihonKohden-Bern(1980)_Swiss
%%%                      12-> actiCHamp_Russia_2013
%%%                      13-> Neuroscan_synamps_2-Colombia
%%%                      14-> nvx136-Russia(2013)





%%Checking the parameters
if isempty(generate_cross_spectra)
    generate_cross_spectra=true;
end

if isempty(raw_data_path)
    error('The parameter raw_data_path is required');
end

if isempty(typeLog)
    error('The Type of gaussianize method to apply(typeLog) parameter is required');
else
    try
        typeLog = str2num(typeLog); %#ok<ST2NM>
    catch
        error('Incorrect definition of the parameter "Type of gaussianize method to apply(typeLog)"')
    end
end

if typeLog(1)==0 && typeLog(2)==0
    error('You must select the log-spectrum(log) or/and cross-spectrum with riemannian metric(riemlog)');
end




% ADD PATH Commented for compiled version
addpath(genpath(pwd));

% Create output folder and subfolders
derivatives_output_folder=[outputFolder_path filesep 'derivatives'];
test_folder(derivatives_output_folder);

% Calculate All in loop

[~,pathnames] = recorrer_folders(raw_data_path);
for i=1:size(pathnames,2)
    try
        [filename,filepath] = recorrer_folders(cell2mat(pathnames(i)));
        all_data =importdata(filepath{1});
        [~, data_code, ~] = fileparts(filename{1});

        %% Disp information. Begin process by case
        disp(['BEGIN PROCESS FOR ', data_code]);

        %% BEGIN STEP 1 Cross_spectrum
        if generate_cross_spectra  %%Call data_gatherer
            [data_struct, error_msg] = data_gatherer(all_data.data, all_data.sampling_freq, all_data.cnames,data_code , ...
                all_data.reference, all_data.age, all_data.sex, all_data.country, all_data.eeg_device);
            if ~isempty(error_msg)
                error(error_msg);
            end
        else
            data_struct=all_data;
        end

        %%% reference batch
        [reRefBatch] = HarMNqEEG_generate_reRefBatch(batch_correction,data_struct.pais, data_struct.EEGMachine);


        %% Declare the json File and .h5 file
        test_folder([derivatives_output_folder filesep data_code]);
        [jsonFile]=HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_init,[derivatives_output_folder filesep data_code], data_struct.fmin,...
            data_struct.freqres, data_struct.fmax, data_struct.nt, data_struct.ffteeg, data_struct.dnames, data_struct.freqrange, data_struct.srate ,data_struct.name, data_struct.pais, data_struct.EEGMachine, data_struct.sex, data_struct.age,reRefBatch);




        %% END STEP 1 Cross_spectrum

        if typeLog(1)==1
            disp('----------------------------------------------------------------- Calculates for log-spectrum -----------------------------------------------------------------');
            [T] = HarMNqEEG_step2_step3_by_typeLog(data_struct, 'log', reRefBatch);

            %% Save the Raw Log-Spectra
            dsetname = 'Raw_Log_Spectra'; dtype='Real_Matrix';
            DsetAttr={'Domain', 'Frequency'; 'Dimensions', 'Nc x Nf (Number of channels, Number of frequencies)' ; 'Description', 'Raw Log-spectra matrix, after average reference and GSF (Global Scale Factor) correction. Each row is a frequency. The value of the frequency is in the field Freq.'};
            prec='double';
            [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, [derivatives_output_folder filesep data_code], jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'log', 'log'), DsetAttr);

            %% Save the Harmonized Raw Log-Spectra
            dsetname = 'Harmonized_Log_Spectra'; dtype='Real_Matrix';
            DsetAttr={'Domain', 'Frequency (Euclidean space)'; 'Dimensions', 'Nc x Nf (Number of channels, Number of frequencies)' ; 'Description', 'Harmonized log raw spectrum average reference and corrected by the GSF, harmonized by the correction of the given batch.'};
            prec='double';
            [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, [derivatives_output_folder filesep data_code], jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'ystarlog', 'log'), DsetAttr);


            %% Save the Z-scores Log Spectra
            dsetname = 'Z_scores_Log_Spectra'; dtype='Real_Matrix';
            DsetAttr={'Domain', 'Frequency (Euclidean space)'; 'Dimensions', 'Nc x Nf (Number of channels, Number of frequencies)' ; 'Description', 'The Z-scores of an individual raw Spectra. The element (i, f) of this matrix represents the deviation from normality of the power spectral density (PSD) of channel i and frequency f. The raw spectra is transformed to the Log space to achieve quasi gaussian distribution.'};
            prec='single';
            [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, [derivatives_output_folder filesep data_code], jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'zgloballog', 'log'), DsetAttr);

            if ~isempty(reRefBatch)
                %% Save the Harmonized Z-scores Log Spectra
                dsetname = 'Harmonized_Z_scores_Log_Spectra'; dtype='Real_Matrix';
                DsetAttr={'Domain', 'Frequency (Euclidean space)'; 'Dimensions', 'Nc x Nf (Number of channels, Number of frequencies)' ; 'Description', 'Harmonized Z-score of the log raw spectrum average reference and corrected by the GSF, harmonized by the correction of the given batch.'};
                prec='single';
                [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, [derivatives_output_folder filesep data_code], jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'zstudylog', 'log'), DsetAttr);
            end
            disp('----------------------------------------------------------------- END Calculates for log-spectrum -----------------------------------------------------------------');
        end

        if typeLog(2)==1
            disp('----------------------------------------------------------------- Calculates for cross-spectrum with riemannian metric -----------------------------------------------------------------');
            [T] = HarMNqEEG_step2_step3_by_typeLog(data_struct, 'riemlogm', reRefBatch);

            %% MATRIX STEP 2
            %%% declare same parameters for all the matrix
            prec='double';
            freqrange=T.freq';
            MinFreq=freqrange(1);
            MaxFreq=freqrange(end);

            %% Save the Raw Riemannian Cross-Spectra
            dsetname = 'Raw_Riemannian_Cross_Spectra'; dtype='Hermitian';
            DsetAttr={'Domain', 'Frequency (Riemannian manifold)'; 'Dimensions', 'Nc x Nc x Nf' ; 'Description', 'Raw Cross-spectral matrix transformed to the Riemanian space.';...
                      'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
            %% Notes globalriemlogm and riemlogm are the same
            [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, [derivatives_output_folder filesep data_code], jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'globalriemlogm', 'riemlogm'), DsetAttr);

            %% Save the Harmonized Raw Riemannian Cross-Spectra
            dsetname = 'Harmonized_Raw_Riemannian_Cross_Spectra'; dtype='Hermitian';
            DsetAttr={'Domain', 'Frequency (Riemannian manifold)'; 'Dimensions', 'Nc x Nc x Nf' ; 'Description', 'Harmonized Raw Cross-spectral matrix transformed to the Riemanian space.';...
                     'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
            [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, [derivatives_output_folder filesep data_code], jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'ystarriemlogm', 'riemlogm'), DsetAttr);

            %% Save the Z-scores Riemannian Cross-Spectra
            dsetname = 'Z_scores_Riemannian_Cross_Spectra'; dtype='Hermitian';
            DsetAttr={'Domain', 'Frequency'; 'Dimensions', 'Nc x Nc x Nf' ; 'Description', 'Z-scores of the Cross-spectral matrix transformed to the Riemanian space.';...
                      'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
            [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, [derivatives_output_folder filesep data_code], jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'zglobalriemlogm', 'riemlogm'), DsetAttr);

            if ~isempty(reRefBatch)
                %% Save the Harmonized Z-scores Riemannian Cross-Spectra
                dsetname = 'Harmonized_Z_scores_Riemannian_Cross_Spectra'; dtype='Hermitian';
                DsetAttr={'Domain', 'Frequency'; 'Dimensions', 'Nc x Nc x Nf' ; 'Description', 'Harmonized Z-scores of the Cross-spectral matrix transformed to the Riemanian space.'; ...
                          'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
                [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, [derivatives_output_folder filesep data_code], jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'zstudyriemlogm', 'riemlogm'), DsetAttr);
            end

            disp('----------------------------------------------------------------- END Calculates for cross-spectrum with riemannian metric -----------------------------------------------------------------');

        end


        %% Saving json file
        saveJSON(jsonFile,[derivatives_output_folder filesep data_code filesep 'HarMNqeeg_derivatives.json'])

        %% Disp information. End process by case
        disp(['END PROCESS FOR ', data_code]);



    catch ME
        disp(['organize fail for #%s: %s\n ', data_code,ME.message]);
        rethrow(ME);
    end


end









disp('----------------------------------------------------------------- END ALL PROCESS -----------------------------------------------------------------');



end