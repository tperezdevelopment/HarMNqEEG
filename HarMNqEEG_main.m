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
    outputFolder_path=[raw_data_path filesep 'derivatives'];
end


if isempty(generate_cross_spectra)
    generate_cross_spectra=true;
end

if isempty(raw_data_path)
    error('The parameter raw_data_path is required');
end

if ~isempty(subjects_metadata)
    if ~isfile(subjects_metadata)
        error('The parameter subjects metadata must be a file')
    else
        [~, ~, ext] = fileparts(subjects_metadata);
        if ~strcmp(ext, '.xls') && ~strcmp(ext, '.xlsx') && ~strcmp(ext, '.csv') && ~strcmp(ext, '.mat')
            error('The subjects metadata file need to have xls or xlsx or csv extension');
        end
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
test_folder(outputFolder_path);

% Calculate All in loop
[~,pathnames] = recorrer_folders(raw_data_path);
for i=1:size(pathnames,2)
    try
        [~, data_code, ~] = fileparts(cell2mat(pathnames(i)));

        %% Creating folder for data_code
        outputFolder_path_data_code=[outputFolder_path filesep data_code];
        test_folder(outputFolder_path_data_code);

        %% Creating log file by subject and begin save info
        logFile=[outputFolder_path_data_code  filesep 'log.txt'];
        test_folder(logFile);
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
                    %% Checking metadata for data_code
                    metadata_table = readtable(subjects_metadata);
                    [~, data_code_position] = ismember({data_code},metadata_table.data_code);
                    if data_code_position==0
                        warning([data_code ' not found in the subjects metadata file']);
                        diary off;
                        continue;
                    end

                    if  strcmp(file_ext, '.txt') %% txt format for all data
                        [all_data]= HarMNqEEG_import_txt(cell2mat(pathnames(i)), metadata_table, data_code_position);
                        HarMNqEEG_all_steps(outputFolder_path_data_code,generate_cross_spectra, typeLog, all_data, data_code, batch_correction, optional_matrix);
                    else

                        try
                            [all_data] = HarMNqEEG_read_data_fileio(cell2mat(pathnames(i)), metadata_table, data_code_position);
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
                metadata_table = readtable(subjects_metadata);
                [~, data_code_position] = ismember({data_code},metadata_table.data_code);
                if data_code_position==0
                    warning([data_code ' not found in the subjects metadata file']);
                    diary off;
                    continue;
                end

                if isfolder(cell2mat(pathnames(i)))
                    if startsWith(data_code, 'sub-') %% checking is BIDS
                        try
                            HarMNqEEG_calculate_bids(cell2mat(pathnames(i)), typeLog, metadata_table, data_code_position, batch_correction, outputFolder_path_data_code, optional_matrix);
                        catch ME
                            disp( getReport( ME, 'extended', 'hyperlinks', 'on' ) );
                            diary off;
                            continue;
                        end
                    elseif  ~isempty(dir(fullfile(cell2mat(pathnames(i)), '*.PLG')))   %% checking is PLG
                        if ~isempty(fullfile(cell2mat(pathnames(i)), '*.WIN'))
                            [all_data]= HarMNqEEG_import_plg(cell2mat(pathnames(i)), metadata_table, data_code_position);
                            HarMNqEEG_all_steps(outputFolder_path_data_code,generate_cross_spectra, typeLog, all_data, data_code, batch_correction, optional_matrix);
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

        end %% cross spectro generated


        %% Disp information. End process by case
        disp(['END PROCESS FOR ', data_code]);

        diary off;

    catch ME
        rethrow(ME);
    end


end

