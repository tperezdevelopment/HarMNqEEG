function [jsonFile] = HarMNqeeg_derivates_init(h5_file_full_path, perc_compres, MinFreq, FreqRes, MaxFreq, Epoch_Length, fftcoefs, name, pais, EEGMachine, sex, age, reRefBatch)

%% Declare the json File
jsonFile.Attributes.Software= "HarMNqEEG";
jsonFile.Attributes.creation_date=date;
jsonFile.Attributes.Description_Software="This tool evaluates the  batch harmonized z-scores based on the multinational norms.This toolbox extends the frequency domain quantitative electroencephalography (qEEG) methods pursuing higher sensitivity to detect Brain Developmental Disorders. Prior qEEG work lacked integration of cross-spectral information omitting important functional connectivity descriptors. Lack of geographical diversity precluded accounting for site-specific variance, increasing qEEG nuisance variance. We ameliorate these weaknesses. i) Create lifespan Riemannian multinational qEEG norms for cross-spectral tensors. These norms result from the HarMNqEEG project fostered by the Global Brain Consortium. We calculate the norms with data from 9 countries, 12 devices, and 14 studies, including 1564 subjects. qEEG traditional and Riemannian descriptive parameters were calculated using additive mixed-effects models. We demonstrate qEEG 'batch effects' and provide methods to calculate harmonized z-scores. ii) provide traditional and Riemannian norms. iii) We offer open code to calculate different individual z-scores from the HarMNqEEG dataset. These results contribute to developing bias-free, low-cost neuroimaging technologies applicable in various health settings.";
jsonFile.Attributes.Description_Json_File= "This is a json file that describes the outputs and the path respectively.";
jsonFile.Attributes.Software_Version= "1.0.0";
jsonFile.Attributes.Institutes= "Joint China-Cuba LAB, UESTC, CNEURO";
jsonFile.Attributes.Software_Original_Code="Author: Ying Wang, Min Li";
jsonFile.Attributes.Software_Derivatives_Original_Author="Sc.D. Jorge F. Bosch-Bayard <oldgandalf@gmail.com>. Montreal Neurological Institute";
jsonFile.Attributes.Cbrain_Software_Author="Eng. Tania Perez Ramirez <tperezdevelopment@gmail.com>";
jsonFile.Attributes.Maintainer= "tperezdevelopment@gmail.com";
jsonFile.Attributes.Reference_Paper="Harmonized-Multinational qEEG Norms (HarMNqEEG). Link: https://www.biorxiv.org/content/10.1101/2022.01.12.476128v1";

%% Inserting specific data
jsonFile.Attributes.Name_Subject=name;
jsonFile.Attributes.Country=pais;
jsonFile.Attributes.EEGMachine=EEGMachine;
jsonFile.Attributes.Sex=sex;
jsonFile.Attributes.Age=age;
jsonFile.Attributes.MinFreq=num2str(MinFreq);
jsonFile.Attributes.FreqRes=num2str(FreqRes);
jsonFile.Attributes.MaxFreq=num2str(MaxFreq);
jsonFile.Attributes.Epoch_Length=num2str(Epoch_Length);
%% saving reference
if ~isempty(reRefBatch)
    jsonFile.Attributes.Reference_Batch_Correction=reRefBatch{2};
end


%% Add attributes .h5 file
%%% Creating h5 file. Inserting fftcoefs data
dsetname = 'FFT_coefs'; dtype='Complex_Matrix'; overw=false;
DsetAttr = {'Algorithm', 'FFT Matlab R2020';'Domain', 'Frequency'; 'Description', 'Complex matrix of FFT coefficients of nd x nfreqs x epoch length (stored for possible needed further processing for calculating the cross-spectral matrix, like regularization algorithms in case of ill-conditioning).'};
prec='double';
try
    HarMNqeeg_derivates_h5_builder(h5_file_full_path,dsetname,fftcoefs,DsetAttr, dtype, overw, prec, perc_compres);
    [jsonFile]=HarMNqeeg_derivates_json_builder(jsonFile,dsetname,dtype, DsetAttr);
catch ME
    rethrow(ME);
end
cellfun(@(x) h5writeatt(h5_file_full_path,'/',x,jsonFile.Attributes.(x)),fieldnames(jsonFile.Attributes),'UniformOutput',false);
end

