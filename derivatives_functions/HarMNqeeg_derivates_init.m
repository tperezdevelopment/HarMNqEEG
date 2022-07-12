function [jsonFile] = HarMNqeeg_derivates_init(h5_file_full_path, perc_compres, MinFreq, FreqRes, MaxFreq, Epoch_Length, fftcoefs, dnames, freqrange,srate, name, pais, EEGMachine, sex, age, reRefBatch)

%% Declare the json File
jsonFile.Attributes.Software= "HarMNqEEG";
jsonFile.Attributes.creation_date=date;
jsonFile.Attributes.Description_Software="These results contribute to developing bias-free, low-cost neuroimaging technologies applicable in various health settings. In this first version, we calculate the harmonized qEEG for the 19 channels of the S1020 montage. We additionally apply the Global Scale Factor (GSF, Hernandez-Caceres et al., 1994) correction, which accounts for the percent of the variability in the EEG that is not due to the neurophysiological activity of the person, but rather than to impedance at the electrodes, skull thickness, hair thickness, and some other technical aspects. This GSF correction has the effect of eliminating a scale factor that affects the signal amplitude and refers all the recordings to a common baseline, which makes the recordings more comparable. Also, the EEG recordings are all re-reference to the Average Reference montage, which is a popular choice in qEEG and also eliminates the dependence of the EEG amplitude from the physical site where the reference electrode was located.";
jsonFile.Attributes.Description_Json_File= "This is a json file that describes the outputs and the path respectively.";
jsonFile.Attributes.Software_Version= "1.0.0";
jsonFile.Attributes.Institutes= "Joint China-Cuba LAB, UESTC, CNEURO";
jsonFile.Attributes.Software_Original_Code="Author: Ying Wang, Min Li";
jsonFile.Attributes.Software_Derivatives_Original_Author="Sc.D. Jorge F. Bosch-Bayard <oldgandalf@gmail.com>. Montreal Neurological Institute";
jsonFile.Attributes.Cbrain_Software_Author="Eng. Tania Perez Ramirez <tperezdevelopment@gmail.com>";
jsonFile.Attributes.Maintainer= "tperezdevelopment@gmail.com";
jsonFile.Attributes.Reference_Paper="Li M, et al.. Harmonized-Multinational qEEG norms (HarMNqEEG). Neuroimage. 2022;256:119190. doi: 10.1016/j.neuroimage.2022.119190. Epub 2022 Apr 7. PMID: 35398285.";

%% Inserting specific data
jsonFile.Attributes.Name_Subject=name;
jsonFile.Attributes.Country=pais;
jsonFile.Attributes.EEGMachine=EEGMachine;
jsonFile.Attributes.Sex=sex;
jsonFile.Attributes.Age=age;
jsonFile.Attributes.Frequency_Unit="Hz";
jsonFile.Attributes.Frequency_Resolution=num2str(FreqRes);
jsonFile.Attributes.Epoch_Length=num2str(Epoch_Length);
jsonFile.Attributes.Channels_Names=dnames;
jsonFile.Attributes.Sampling_Frequency=num2str(srate);

%% saving reference
if ~isempty(reRefBatch)
    jsonFile.Attributes.Reference_Batch_Correction=reRefBatch{2};
end


%% Add attributes .h5 file
%%% Creating h5 file. Inserting fftcoefs data
dsetname = 'FFT_coefs'; dtype='Complex_Matrix'; overw=false; 
DsetAttr = {'Algorithm', 'FFT Matlab R2020';'Domain', 'Frequency'; 'Description', 'Complex matrix of FFT coefficients of nd x nfreqs x epoch length (stored for possible needed further processing for calculating the cross-spectral matrix, like regularization algorithms in case of ill-conditioning).'; ...
           'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
prec='double';
try
    HarMNqeeg_derivates_h5_builder(h5_file_full_path,dsetname,fftcoefs,DsetAttr, dtype, overw, prec, perc_compres);
    [jsonFile]=HarMNqeeg_derivates_json_builder(jsonFile,dsetname,dtype, DsetAttr);
catch ME
    rethrow(ME);
end
cellfun(@(x) h5writeatt(h5_file_full_path,'/',x,jsonFile.Attributes.(x)),fieldnames(jsonFile.Attributes),'UniformOutput',false);
end

