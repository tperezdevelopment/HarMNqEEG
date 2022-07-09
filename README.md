# HarMNqEEG

    Original code Author: Ying Wang, Min Li
    Cbrain Tool Author: Eng. Tania Perez Ramirez <tperezdevelopment@gmail.com>
    Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
    Joint China-Cuba LAB, UESTC, CNEURO


HarMNqEEG TOOL DESCRIPTION</br>
These results contribute to developing bias-free, low-cost neuroimaging technologies applicable in various health settings.
In this first version, we calculate the harmonized qEEG for the 19 channels of the S1020 montage. 
We additionally apply the Global Scale Factor (GSF, Hernandez-Caceres et al., 1994) correction, which accounts for the percent 
of the variability in the EEG that is not due to the neurophysiological activity of the person, but rather than to impedance 
at the electrodes, skull thickness, hair thickness, and some other technical aspects. This GSF correction has the effect of 
eliminating a scale factor that affects the signal amplitude and refers all the recordings to a common baseline, which makes 
the recordings more comparable. Also, the EEG recordings are all re-reference to the Average Reference montage, which is a popular
choice in qEEG and also eliminates the dependence of the EEG amplitude from the physical site where the reference electrode was located.



Auxiliar inputs
outputFolder_path ----------> Path of output folder
generate_cross_spectra -----> Boolean parameter. Case False (0), will not  necessarily
                              calculate the cross spectra. Case True
                              (1) is required to calculate the cross spectra

Data Gatherer
raw_data_path -------------> Folder path of the raw data in .mat format. This folder
                             contains subfolders by each subject. The
                             subfolder contains a .mat file with the
                             following parameters:
                                - data          : an artifact-free EEG scalp data matrix, organized as nd x nt x ne, where
                                                  nd : number of channels
                                                  nt : epoch size (# of instants of times in an epoch)
                                                  ne : number of epochs
                                - sampling_freq : sampling frequency in Hz. Eg: 200
                                - cnames        : a cell array containing the names of the channels. The expected names are:
                                                  'Fp1'    'Fp2'    'F3'    'F4'    'C3'    'C4'    'P3'    'P4'    'O1'    'O2'    'F7'    'F8'    'T3'    'T4'    'T5'    'T6'    'Fz'    'Cz'    'Pz'
                                                  If the channels come in another order, they are re-arranged according to the expected order
                                - data_code     : is the name of the original data file just for purpose of identification.
                                                  It can be a code used by the owner to identify the data.
                                - reference     : a string containing the name of the reference of the data.
                                - age           : subject's age at recording time
                                - sex           : subject's sex
                                - country       : country providing the data
                                - eeg_device    : EEG hardware where the data was recorded
								
								
Preproccess Guassianize Data 
typeLog ----------> Type of gaussianize method to apply. Options:
                    typeLog(1)-> for log (Boolean):     log-spectrum
                    typeLog(2)-> for riemlogm (Boolean): cross-spectrum with riemannian metric


Calculate z-scores and harmonize 
batch_correction --> List of the batch correction that we have. Options:
                     batch_correction(1)->  ANT_Neuro-Malaysia
                     batch_correction(2)->  BrainAmp_DC-Chengdu_2014
                     batch_correction(3)->  BrainAmp_MR_plus_64C-Chongqing
                     batch_correction(4)->  BrainAmp_MR_plus-Germany_2013
                     batch_correction(5)->  DEDAAS Barbados1978
                     batch_correction(6)->  DEDAAS-NewYork_1970s
                     batch_correction(7)->  EGI-256 HCGSN_Zurich(2017)-Swiss
                     batch_correction(8)->  Medicid-3M Cuba1990
                     batch_correction(9)->  Medicid-4 Cuba2003
                     batch_correction(10)-> Medicid_128Ch-CHBMP
                     batch_correction(11)-> NihonKohden-Bern(1980)_Swiss
                     batch_correction(12)-> actiCHamp_Russia_2013
                     batch_correction(13)-> Neuroscan_synamps_2-Colombia
                     batch_correction(14)-> nvx136-Russia(2013)
								

