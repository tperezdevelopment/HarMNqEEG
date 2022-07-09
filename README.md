# HarMNqEEG

    Original code Author: Ying Wang, Min Li
    Cbrain Tool Author: Eng. Tania Perez Ramirez <tperezdevelopment@gmail.com>
    Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
    Joint China-Cuba LAB, UESTC, CNEURO


<strong>HarMNqEEG TOOL DESCRIPTION</strong></br>
These results contribute to developing bias-free, low-cost neuroimaging technologies applicable in various health settings.
In this first version, we calculate the harmonized qEEG for the 19 channels of the S1020 montage. 
We additionally apply the Global Scale Factor (GSF, Hernandez-Caceres et al., 1994) correction, which accounts for the percent 
of the variability in the EEG that is not due to the neurophysiological activity of the person, but rather than to impedance 
at the electrodes, skull thickness, hair thickness, and some other technical aspects. This GSF correction has the effect of 
eliminating a scale factor that affects the signal amplitude and refers all the recordings to a common baseline, which makes 
the recordings more comparable. Also, the EEG recordings are all re-reference to the Average Reference montage, which is a popular
choice in qEEG and also eliminates the dependence of the EEG amplitude from the physical site where the reference electrode was located.</br>



<strong>INPUT PARAMETERS:</strong></br>
<h4>Auxiliar inputs</h4>
<ul>
<li>outputFolder_path: Path of output folder</li>
<li>generate_cross_spectra :Boolean parameter. Case False (0), will not  necessarily calculate the cross spectra. Case True (1) is required to calculate the cross spectra</li></ul>

<h4>Data Gatherer</h4>
raw_data_path -------------> Folder path of the raw data in .mat format. This folder contains subfolders by each subject. </br>
                             The subfolder contains a .mat file with the following parameters:</br>
                                - data          : an artifact-free EEG scalp data matrix, organized as nd x nt x ne, where</br>
                                                  nd : number of channels</br>
                                                  nt : epoch size (# of instants of times in an epoch)</br>
                                                  ne : number of epochs</br>
                                - sampling_freq : sampling frequency in Hz. Eg: 200</br>
                                - cnames        : a cell array containing the names of the channels. The expected names are:</br>
                                                  'Fp1'    'Fp2'    'F3'    'F4'    'C3'    'C4'    'P3'    'P4'    'O1'    'O2'    'F7'    'F8'    'T3'    'T4'    'T5'    'T6'    'Fz'    'Cz'    'Pz'
                                                  If the channels come in another order, they are re-arranged according to the expected order</br>
                                - data_code     : is the name of the original data file just for purpose of identification. It can be a code used by the owner to identify the data.</br>
                                - reference     : a string containing the name of the reference of the data.</br>
                                - age           : subject's age at recording time</br>
                                - sex           : subject's sex</br>
                                - country       : country providing the data</br>
                                - eeg_device    : EEG hardware where the data was recorded</br>
								
								
<h4>Preproccess Guassianize Data </h4>
typeLog ----------> Type of gaussianize method to apply. </br> 
					Options:</br>
                    typeLog(1)-> for log (Boolean):     log-spectrum</br>
                    typeLog(2)-> for riemlogm (Boolean): cross-spectrum with riemannian metric</br>


<h4>Calculate z-scores and harmonize </h4>
batch_correction --> List of the batch correction that we have. </br>
				     Options:</br>
                     batch_correction(1)->  ANT_Neuro-Malaysia</br>
                     batch_correction(2)->  BrainAmp_DC-Chengdu_2014</br>
                     batch_correction(3)->  BrainAmp_MR_plus_64C-Chongqing</br>
                     batch_correction(4)->  BrainAmp_MR_plus-Germany_2013</br>
                     batch_correction(5)->  DEDAAS Barbados1978</br>
                     batch_correction(6)->  DEDAAS-NewYork_1970s</br>
                     batch_correction(7)->  EGI-256 HCGSN_Zurich(2017)-Swiss</br>
                     batch_correction(8)->  Medicid-3M Cuba1990</br>
                     batch_correction(9)->  Medicid-4 Cuba2003</br>
                     batch_correction(10)-> Medicid_128Ch-CHBMP</br>
                     batch_correction(11)-> NihonKohden-Bern(1980)_Swiss</br>
                     batch_correction(12)-> actiCHamp_Russia_2013</br>
                     batch_correction(13)-> Neuroscan_synamps_2-Colombia</br>
                     batch_correction(14)-> nvx136-Russia(2013)</br>
								

