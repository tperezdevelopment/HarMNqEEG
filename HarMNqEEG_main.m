function [] = HarMNqEEG_main(generate_cross_spectra, raw_data_path,subjects_metadata, typeLog,batch_correction, optional_matrix, outputFolder_path)
%     Original code Author: Ying Wang, Min Li
%     Cbrain Tool Author: Eng. Tania Perez Ramirez <tperezdevelopment@gmail.com>
%     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
%     Joint China-Cuba LAB, UESTC, CNEURO
%     Matlab version: 2021b

% HarMNqEEG TOOL DESCRIPTION
% %This toolbox extends frequency domain quantitative electroencephalography (qEEG) methods pursuing higher sensitivity to detect Brain Developmental Disorders. 
% % Prior qEEG work lacked integration of cross-spectral information omitting important functional connectivity descriptors. Lack of geographical diversity precluded accounting for site-specific variance, increasing qEEG nuisance variance. We ameliorate these weaknesses by (i) Creating lifespan Riemannian multinational qEEG norms for cross-spectral tensors. 
% % These norms result from the HarMNqEEG project fostered by the Global Brain Consortium. We calculated the norms with data from 9 countries, 12 devices, and 14 studies, including 1564 subjects. Developmental equations for the mean and standard deviation of qEEG traditional and Riemannian DPs were calculated using additive mixed-effects models. 
% % We demonstrate qEEG “batch effects” and provide methods to calculate harmonized z-scores. (ii) We also show that harmonized Riemannian norms produce z-scores with increased diagnostic accuracy. These results contribute to developing bias-free, low-cost neuroimaging technologies applicable in various health settings. 
% % In this first version, we limited the harmonized qEEG to the 19 channels of the S1020 montage. At the present, the toolbox accepts the input EEG data in EEG-BIDS, EDF+, BDF+, PLG, EEGLAB SET format, and a predefined TEXT format. In the case of not EEG-BIDS structure, the derivatives are stored in the same directory where the raw EEG file is located. 
% % The toolbox also contains the definition of the Harmonized qEEG derivatives for the EEG-BIDS format. The derivatives are stored in the BIDS structure compliant with the BIDS definition for the derivatives, in the Hierarchical Data Format (HDF). The functions for creating and loading the HarMNqEEG derivatives can be found in the directory "derivatives_functions".

% INPUT PARAMETERS:
%% Note important
%%% The chanel montage must be 10-20 system

%% Data Gatherer
%%% generate_cross_spectra -----> Boolean parameter. Default False. Case False (0), the
%%%                               raw_data_path folder will contain the
%%%                               data_gatherer output. Case True (1) is required to calculate the cross spectra

%%% raw_data_path -------------> This parameter is required. Folder path of the raw data. The content of this raw_data_path depends
%%%                              of generate_cross_spectra parameters:
%%%                              1- If the generate_cross_spectra is False (0),
%%%                              this folder must be contain the data_gatherer output, with the cross spectra generated
%%%                              (See more: https://github.com/CCC-members/BC-V_group_stat/blob/master/data_gatherer.m)
%%%                              2- If the generate_cross_spectra is True
%%%                              (1), the raw_data_path can contain the
%%%                              following formats:
%%%                                 2.1- A Matlab structure (*.mat) with the
%%%                                 following parameters:
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
%%%
%%%                                 2.2- An ASCII file (*.txt) with a fixed
%%%                                 structure which contains the data of an EEG file. In that case, the file needs to
%%%                                 have the extension ".txt" and m ust have the following structure:
%%%                                  - NAME
%%%                                  - SEX
%%%                                  - AGE
%%%                                  - SAMPLING_FREQ
%%%                                  - EPOCH_SIZE
%%%                                  - NCHANNELS
%%%                                  - MONTAGE=
%%%                                    Fp1-REF
%%%                                    Fp2-REF
%%%                                    F3_-REF
%%%                                   and so on. The program expects NCHANNELS lines with the names
%%%                                  AFTER THE CHANNELS NAMES THE EEG DATA
%%%                                  where each lione is an instant of time and each column represents a channel.
%%%                                 If the EEG contains 30 segments of 512 points each and 19 channels, then
%%%                                 30*512 lines of 19 columns of numbers (either float or integer) are expected
%%%
%%%                                 2.3- Generic data formats (*.edf)
%%%
%%%                                 2.4- Biosemi (*.bdf)
%%%
%%%                                 2.5- EEGLAB format (*.set)
%%%
%%%                                 2.6- MEDICID neurometrics system (*.plg)
%%%
%%%




%% Metadata
%%% subjects_metadata --------> This files is optional in case generate_cross_spectra is False (0)
%%%                              In case generate_cross_spectra is True this must be a  *.csv, *.tsv or *.mat file format. This file must
%%%                              contain a list of subjects with the
%%%                              following metadata info:
%%%                              1- data_code: Name of the file
%%%                                 subject or the subfolder subject listed
%%%                                 in raw_data_path folder. Required
%%%                                 metadata
%%%                              2- reference: A string containing the name
%%%                                 of the reference of the data. Required metadata
%%%                              3- age: Subject's age at recording time. Required metadata
%%%                              4- sex: Subject's sex. Optional metadata
%%%                              5- country: Country providing the data. Required metadata
%%%                              6- eeg_device: EEG hardware where the data
%%%                                 was recorded. Required metadata


%% Preproccess Guassianize Data and  Calculate z-scores and harmonize %%
%%% typeLog ----------> This parameter is required. Type of gaussianize method to apply. Options:
%%%                     typeLog(1)-> for log (Boolean). By default is False: log-spectrum
%%%                     typeLog(2)-> for riemlogm (Boolean). By default is True: cross-spectrum in Tangent Space

%%% batch_correction --> List of the batch correction. You must select one closed study for calculating batch harmonized z-scores.
%%%                      The batch_correction you can put the number of the
%%%                      batch list or the batch correction name.
%%%                      The name of existed batch reference is the union
%%%                      between: EEG_Device+Country+Study_Year:
%%%                      1->  ANT_Neuro-Malaysia
%%%                      2->  BrainAmp_DC-Chengdu_2014
%%%                      3->  BrainAmp_MR_plus_64C-Chongqing
%%%                      4->  BrainAmp_MR_plus-Germany_2013
%%%                      5->  DEDAAS-Barbados_1978
%%%                      6->  DEDAAS-NewYork_1970s
%%%                      7->  EGI-256_HCGSN_Zurich_2017-Swiss
%%%                      8->  Medicid-3M-Cuba_1990
%%%                      9->  Medicid-4-Cuba_2003
%%%                      10-> Medicid_128Ch-CHBMP
%%%                      11-> NihonKohden-Bern_1980_Swiss
%%%                      12-> actiCHamp_Russia_2013
%%%                      13-> Neuroscan_synamps_2-Colombia
%%%                      14-> nvx136-Russia_2013

%% Optional Matrices to save
%%% optional_matrix --> List of matrix optional that the user can select. This can be empty. Options:
%%%                     optional_matrix(1) -> FFT_coefs (Boolean): Complex matrix of FFT coefficients of nd x nfreqs x epoch length
%%%                     optional_matrix(2) -> Mean_Age_Cross (Boolean): Mean for Age of Tangent Space Cross Spectra Norm


%% Auxiliar inputs
%%% outputFolder_path ----------> Path of output folder.


% Checking the parameters and Create output folder and subfolders
if isempty(outputFolder_path)
    outputFolder_path=[raw_data_path filesep 'derivatives'];
else
    outputFolder_path=[outputFolder_path filesep 'derivatives'];
    test_folder(outputFolder_path);
end

 if ischar(generate_cross_spectra)
        generate_cross_spectra = str2num(generate_cross_spectra); %#ok<ST2NM>
 end

if isempty(generate_cross_spectra)
    generate_cross_spectra=false;
end

if isempty(raw_data_path)
    error('The parameter raw_data_path is required');
end

if ~isempty(subjects_metadata)
    if ~isfile(subjects_metadata)
        error('The parameter subjects metadata must be a file')
    else
        [~, ~, ext] = fileparts(subjects_metadata);
        if ~strcmp(ext, '.csv') && ~strcmp(ext, '.xlsx') && ~strcmp(ext, '.tsv') && ~strcmp(ext, '.mat')
            error('The subjects metadata file need to have csv, or tsv or mat extension');
        end
    end
end

try
    if ischar(typeLog)
        typeLog = str2num(typeLog); %#ok<ST2NM>
    end
    if isempty(typeLog)
        error('The Type of gaussianize method to apply(typeLog) parameter is required');
    end
    if typeLog(1)==0 && typeLog(2)==0
        typeLog(2)=1;
        warning('You must select the log-spectrum(log) or/and cross-spectrum with Riemannian Vectorization(riemlog). By default the riemlog option (typeLog(2)=1) will be selected');
    end
catch ME
    rethrow(ME);
end




try
    if ischar(optional_matrix)
        optional_matrix = str2num(optional_matrix); %#ok<ST2NM>
    end
    if isempty(optional_matrix)
        optional_matrix(1)=0;
        optional_matrix(2)=0;
    end
catch
    error('Incorrect definition of the parameter "List of matrix optional"');
end


% ADD PATH Commented for compiled version
addpath(genpath(pwd));




disp('----------------------------------------------------------------- BEGIN PROCESS ALL PROCESS -----------------------------------------------------------------');

% Calculate All in loop
[~,pathnames] = recorrer_folders(raw_data_path);
for i=1:size(pathnames,2)
    try
        [~, data_code, ~] = fileparts(cell2mat(pathnames(i)));

        %% Creating folder for data_code
        outputFolder_path_data_code=[outputFolder_path filesep data_code];
        test_folder(outputFolder_path_data_code);

        %% Creating log file by subject and begin save info
        logFile=[outputFolder_path_data_code  filesep 'log_' data_code '.txt'];
        test_folder(logFile, 'file');
        diary off;
        diary (logFile);
        diary on;

        %% Disp information. Begin process by case
        disp(['BEGIN PROCESS FOR ', data_code]);

        if generate_cross_spectra
            %% Checking firts is .mat
            if isfile(cell2mat(pathnames(i)))
                [~,~,file_ext] = fileparts(cell2mat(pathnames(i)));
                if strcmp(file_ext, '.mat')                     %%Reading by .mat
                    all_data =importdata(cell2mat(pathnames(i)));
                    try
                        HarMNqEEG_all_steps(outputFolder_path_data_code,generate_cross_spectra,typeLog, all_data, data_code, batch_correction, optional_matrix);
                    catch ME
                        disp( getReport( ME, 'extended', 'hyperlinks', 'on' ) );
                        diary off;
                        continue;
                    end
                else
                    if isempty(subjects_metadata)
                        error('The parameter subjects_metadata is required when should the cross spectrum be calculated, generate_cross_spectra is True');
                    end
                    %%Reading by fileio module from Fieltrip
                    try
                        [all_data] = HarMNqEEG_read_subjects_metadata(subjects_metadata,data_code);
                    catch ME
                        disp( getReport( ME, 'extended', 'hyperlinks', 'on' ) );
                        diary off;
                        continue;
                    end

                    if  strcmp(file_ext, '.txt') %% txt format for all data
                        [all_data]= HarMNqEEG_import_txt(cell2mat(pathnames(i)), all_data);
                        HarMNqEEG_all_steps(outputFolder_path_data_code,generate_cross_spectra, typeLog, all_data, data_code, batch_correction, optional_matrix);
                    else

                        try
                            [all_data] = HarMNqEEG_read_data_fileio(cell2mat(pathnames(i)), all_data);
                            HarMNqEEG_all_steps(outputFolder_path_data_code,generate_cross_spectra, typeLog, all_data, data_code, batch_correction, optional_matrix);
                        catch ME
                            disp( getReport( ME, 'extended', 'hyperlinks', 'on' ) );
                            diary off;
                            continue;
                        end
                    end
                end

            else  %% folders subjects
                if isempty(subjects_metadata)
                    error('The parameter subjects_metadata is required when should the cross spectrum be calculated, generate_cross_spectra is True');
                end

                %% Checking metadata for data_code
                try
                    [all_data] = HarMNqEEG_read_subjects_metadata(subjects_metadata,data_code);
                catch ME
                    disp( getReport( ME, 'extended', 'hyperlinks', 'on' ) );
                    diary off;
                    continue;
                end

                if isfolder(cell2mat(pathnames(i)))
                    if startsWith(data_code, 'sub-') %% checking is BIDS
                        try
                            HarMNqEEG_calculate_bids(cell2mat(pathnames(i)), data_code, typeLog, all_data, batch_correction, outputFolder_path_data_code, generate_cross_spectra, optional_matrix);
                        catch ME
                            disp( getReport( ME, 'extended', 'hyperlinks', 'on' ) );
                            diary off;
                            continue;
                        end
                    elseif  ~isempty(dir(fullfile(cell2mat(pathnames(i)), '*.PLG')))   %% checking is PLG
                        if ~isempty(fullfile(cell2mat(pathnames(i)), '*.WIN'))
                            try
                                [all_data]= HarMNqEEG_import_plg(cell2mat(pathnames(i)), all_data);
                                HarMNqEEG_all_steps(outputFolder_path_data_code,generate_cross_spectra, typeLog, all_data, data_code, batch_correction, optional_matrix);
                            catch ME
                                disp( getReport( ME, 'extended', 'hyperlinks', 'on' ) );
                                diary off;
                                continue;
                            end
                        else
                            warning(['The ' data_code ' must be contain the win file'] );
                            diary off;
                            continue;
                        end
                    else
                        warning(['Please check the info for ' data_code ]);
                        diary off;
                        continue;
                    end

                end
            end
        else  %% only call the all steps
            all_data =importdata(cell2mat(pathnames(i)));
            try
                HarMNqEEG_all_steps(outputFolder_path_data_code,generate_cross_spectra, typeLog, all_data, data_code, batch_correction, optional_matrix);
            catch ME
                disp( getReport( ME, 'extended', 'hyperlinks', 'on' ) );
                diary off;
                continue;
            end

        end %% cross spectro generated if


        %% Disp information. End process by case
        disp(['----------------------------------------------------------------- END PROCESS FOR ' data_code ' -----------------------------------------------------------------']);

        diary off;

    catch ME
        rethrow(ME);
    end


end

disp('----------------------------------------------------------------- END PROCESS ALL PROCESS -----------------------------------------------------------------');

