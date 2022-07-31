function [] = HarMNqEEG_main(outputFolder_path, generate_cross_spectra,subjects_metadata, raw_data_path, typeLog,batch_correction, optional_matrix)

%     Original code Author: Ying Wang, Min Li
%     Cbrain Tool Author: Eng. Tania Perez Ramirez <tperezdevelopment@gmail.com>
%     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
%     Joint China-Cuba LAB, UESTC, CNEURO
%     Matlab version: 2021b


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
%% Auxiliar inputs
%%% outputFolder_path ----------> Path of output folder
%%% generate_cross_spectra -----> Boolean parameter. Case False (0), the
%%%                               raw_data_path folder will contain the
%%%                               data_gatherer output. Case True (1) is required to calculate the cross spectra

%% Data Gatherer
%%% raw_data_path -------------> Folder path of the raw data. If the generate_cross_spectra is True (1),
%%%                              this folder must contain a subfolders by
%%%                              each subjects or a list of eeg data, or the mix of subject folder and subject file. If
%%%                              the generate_cross_spectra is False (0),
%%%                              this folder must be contain the
%%%                              data_gatherer output, with the cross spectra generated (See more: https://github.com/CCC-members/BC-V_group_stat/blob/master/data_gatherer.m)

%% Metadata
%%% subjects_metadata --------> This files is optional in case generate_cross_spectra is False (0)
%%%                              In case generate_cross_spectra is True this must be a , .csv, or .xls, or .xlsx file that must
%%%                              contain a list of subjects with the
%%%                              following metadata info:
%%%                              1- data_code: Name of the file
%%%                                 subject or the subfolder subjet listed
%%%                                 in raw_data_path folder. Required
%%%                                 metadata
%%%                              2- reference: A string containing the name
%%%                                 of the reference of the data. Required metadata
%%%                              3- age: Subject's age at recording time. Required metadata
%%%                              4- sex: Subject's sex. Optional metadata
%%%                              5- country: Country providing the data. Required metadata
%%%                              6- eeg_device: EEG hardware where the data
%%%                                 was recorded. Required metadata

%% Preproccess Guassianize Data %%
%%% typeLog ----------> Type of gaussianize method to apply. Options:
%%%                     typeLog(1)-> for log (Boolean): log-spectrum
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

%% Optional Matrices to save
%%% optional_matrix --> List of matrix optional that the user can select. Options:
%%%                     optional_matrix(1) -> Complex matrix of FFT coefficients of nd x nfreqs x epoch length
%%%                     optional_matrix(2) -> Mean for Age of Riemannian Cross Spectra Norm


% Checking the parameters
if isempty(outputFolder_path)
    outputFolder_path=pwd;
end

if isempty(generate_cross_spectra)
    generate_cross_spectra=true;
end

if isempty(raw_data_path)
    error('The parameter raw_data_path is required');
end

if isempty(subjects_metadata) && generate_cross_spectra
    error('The parameter subjects_metadata is required when should the cross spectrum be calculated, generate_cross_spectra is True');
elseif ~isfile(subjects_metadata)
    error('The parameter subjects metadata must be a file')
else
    [~, ~, ext] = fileparts(subjects_metadata);
    if ~strcmp(ext, '.xls') && ~strcmp(ext, '.xlsx') && ~strcmp(ext, '.csv') && ~strcmp(ext, '.mat')
        error('The subjects metadata file need to have xls or xlsx or csv extension');
    end
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


if ~isempty(optional_matrix)
    try
        optional_matrix = str2num(optional_matrix); %#ok<ST2NM>
    catch
        error('Incorrect definition of the parameter "List of matrix optional"');
    end

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
        [~, data_code, ~] = fileparts(cell2mat(pathnames(i)));

        %% Creating subject folder
        test_folder([derivatives_output_folder filesep data_code]);

        %% Creating log file by subject and begin save info
        logFile=[derivatives_output_folder filesep data_code  filesep 'log.txt'];
        test_folder(logFile);
        diary off;
        diary (logFile);
        diary on;

        %% Disp information. Begin process by case
        disp(['BEGIN PROCESS FOR ', data_code]);

        %% BEGIN STEP 1 Cross_spectrum
        if generate_cross_spectra
            %% Checking metadata for data_code
            metadata_table = readtable(subjects_metadata);
            [~, pos] = ismember({data_code},metadata_table.data_code);
            if pos==0
                warning([data_code ' not found in the subjects metadata file']);
                continue;
            end
            [all_data] = HarMNqEEG_get_all_data(cell2mat(pathnames(i)), metadata_table, pos);

            %% Call data_gatherer
            [data_struct, error_msg] = data_gatherer(all_data.data, all_data.sampling_freq, all_data.cnames,data_code , ...
                all_data.reference, all_data.age, all_data.sex, all_data.country, all_data.eeg_device);
            if ~isempty(error_msg)
                warning(error_msg);
                continue;
            end
        else
            data_struct=all_data;
        end

        %%% reference batch
        [reRefBatch] = HarMNqEEG_generate_reRefBatch(batch_correction,data_struct.pais, data_struct.EEGMachine);



        %% Declare the json File and .h5 file
        [jsonFile]=HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_init,[derivatives_output_folder filesep data_code], data_code,data_struct.freqres,...
            data_struct.nt, data_struct.dnames, data_struct.srate ,data_struct.name, ...
            data_struct.pais, data_struct.EEGMachine, data_struct.age,reRefBatch);


        %% Saving FFTCoefs (Optional Matrix)
        if optional_matrix(1)==1
            dsetname = 'FFT_coefs'; dtype='Complex_Matrix';
            DsetAttr = {'Algorithm', 'FFT Matlab R2020';'Domain', 'Frequency'; 'Description', 'Complex matrix of FFT coefficients of nd x nfreqs x epoch length (stored for possible needed further processing for calculating the cross-spectral matrix, like regularization algorithms in case of ill-conditioning).'; ...
                'Minimum_Spectral_Frequency', num2str(data_struct.fmin); 'Maximum_Spectral_Frequency', num2str(data_struct.fmax); 'Frequency_Range',  data_struct.freqrange };
            prec='double';
            [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, [derivatives_output_folder filesep data_code], data_code, jsonFile, dsetname, dtype, prec, data_struct.ffteeg, DsetAttr);

        end


        %% END STEP 1 Cross_spectrum

        if typeLog(1)==1
            disp('----------------------------------------------------------------- Calculates for log-spectrum -----------------------------------------------------------------');
            [T] = HarMNqEEG_step2_step3_by_typeLog(data_struct, 'log', reRefBatch);

            %%% declare same parameters for all the matrix
            freqrange=T.freq';
            MinFreq=freqrange(1);
            MaxFreq=freqrange(end);

            %% Save the Raw Log-Spectra
            dsetname = 'Raw_Log_Spectra'; dtype='Real_Matrix';
            DsetAttr={'Domain', 'Frequency'; 'Dimensions', 'Nc x Nf (Number of channels, Number of frequencies)' ; 'Description', 'Raw Log-spectra matrix, after average reference and GSF (Global Scale Factor) correction. Each row is a frequency. The value of the frequency is in the field Freq.'; ...
                'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
            prec='double';
            [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, [derivatives_output_folder filesep data_code], data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'log', 'log'), DsetAttr);

            %% Save the Harmonized Raw Log-Spectra
            dsetname = 'Harmonized_Log_Spectra'; dtype='Real_Matrix';
            DsetAttr={'Domain', 'Frequency (Euclidean space)'; 'Dimensions', 'Nc x Nf (Number of channels, Number of frequencies)' ; 'Description', 'Harmonized log raw spectrum average reference and corrected by the GSF, harmonized by the correction of the given batch.';...
                'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
            prec='double';
            [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, [derivatives_output_folder filesep data_code], data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'ystarlog', 'log'), DsetAttr);


            %% Save the Z-scores Log Spectra
            dsetname = 'Z_scores_Log_Spectra'; dtype='Real_Matrix';
            DsetAttr={'Domain', 'Frequency (Euclidean space)'; 'Dimensions', 'Nc x Nf (Number of channels, Number of frequencies)' ; 'Description', 'The Z-scores of an individual raw Spectra. The element (i, f) of this matrix represents the deviation from normality of the power spectral density (PSD) of channel i and frequency f. The raw spectra is transformed to the Log space to achieve quasi gaussian distribution.';...
                'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
            prec='single';
            [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, [derivatives_output_folder filesep data_code], data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'zgloballog', 'log'), DsetAttr);

            if ~isempty(reRefBatch)
                %% Save the Harmonized Z-scores Log Spectra
                dsetname = 'Harmonized_Z_scores_Log_Spectra'; dtype='Real_Matrix';
                DsetAttr={'Domain', 'Frequency (Euclidean space)'; 'Dimensions', 'Nc x Nf (Number of channels, Number of frequencies)' ; 'Description', 'Harmonized Z-score of the log raw spectrum average reference and corrected by the GSF, harmonized by the correction of the given batch.';...
                    'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
                prec='single';
                [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, [derivatives_output_folder filesep data_code], data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'zstudylog', 'log'), DsetAttr);
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
            [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, [derivatives_output_folder filesep data_code], data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'globalriemlogm', 'riemlogm'), DsetAttr);

            %% Save the Harmonized Raw Riemannian Cross-Spectra
            dsetname = 'Harmonized_Raw_Riemannian_Cross_Spectra'; dtype='Hermitian';
            DsetAttr={'Domain', 'Frequency (Riemannian manifold)'; 'Dimensions', 'Nc x Nc x Nf' ; 'Description', 'Harmonized Raw Cross-spectral matrix transformed to the Riemanian space.';...
                'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
            [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, [derivatives_output_folder filesep data_code], data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'ystarriemlogm', 'riemlogm'), DsetAttr);

            %% Save the Z-scores Riemannian Cross-Spectra
            dsetname = 'Z_scores_Riemannian_Cross_Spectra'; dtype='Hermitian';
            DsetAttr={'Domain', 'Frequency'; 'Dimensions', 'Nc x Nc x Nf' ; 'Description', 'Z-scores of the Cross-spectral matrix transformed to the Riemanian space.';...
                'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
            [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, [derivatives_output_folder filesep data_code], data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'zglobalriemlogm', 'riemlogm'), DsetAttr);

            if ~isempty(reRefBatch)
                %% Save the Harmonized Z-scores Riemannian Cross-Spectra
                dsetname = 'Harmonized_Z_scores_Riemannian_Cross_Spectra'; dtype='Hermitian';
                DsetAttr={'Domain', 'Frequency'; 'Dimensions', 'Nc x Nc x Nf' ; 'Description', 'Harmonized Z-scores of the Cross-spectral matrix transformed to the Riemanian space.'; ...
                    'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
                [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, [derivatives_output_folder filesep data_code], data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'zstudyriemlogm', 'riemlogm'), DsetAttr);
            end

            %% Saving muglobalriemlogm (Optional Matrix)
            if optional_matrix(2)==1
                dsetname = 'Mean_for_Age_of_Riemannian_Cross_Spectra_Norm'; dtype='Complex_Matrix';
                DsetAttr={'Domain', 'Frequency'; 'Dimensions', 'Nc x Nc x Nf' ; 'Description', 'Mean for Age of Riemannian Cross Spectra Norm.'; ...
                    'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
                [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, [derivatives_output_folder filesep data_code], data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'muglobalriemlogm', 'riemlogm'), DsetAttr);
            end
            disp('----------------------------------------------------------------- END Calculates for cross-spectrum with riemannian metric -----------------------------------------------------------------');

        end


        %% Saving json file
        saveJSON(jsonFile,[derivatives_output_folder filesep data_code filesep 'HarMNqeeg_derivatives_' data_code '.json'])

        %% Disp information. End process by case
        disp(['END PROCESS FOR ', data_code]);

        diary off;

    catch ME
        rethrow(ME);
    end


end









disp('----------------------------------------------------------------- END ALL PROCESS -----------------------------------------------------------------');



end