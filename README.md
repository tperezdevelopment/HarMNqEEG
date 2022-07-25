# HarMNqEEG

    Original code Author: Ying Wang, Min Li
    Cbrain Tool Author: Eng. Tania Perez Ramirez <tperezdevelopment@gmail.com>
    Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
    Joint China-Cuba LAB, UESTC, CNEURO


<h2 dir="auto">HarMNqEEG TOOL DESCRIPTION</h2>
These results contribute to developing bias-free, low-cost neuroimaging technologies applicable in various health settings.
In this first version, we calculate the harmonized qEEG for the 19 channels of the S1020 montage. 
We additionally apply the Global Scale Factor (GSF, Hernandez-Caceres et al., 1994) correction, which accounts for the percent 
of the variability in the EEG that is not due to the neurophysiological activity of the person, but rather than to impedance 
at the electrodes, skull thickness, hair thickness, and some other technical aspects. This GSF correction has the effect of 
eliminating a scale factor that affects the signal amplitude and refers all the recordings to a common baseline, which makes 
the recordings more comparable. Also, the EEG recordings are all re-reference to the Average Reference montage, which is a popular
choice in qEEG and also eliminates the dependence of the EEG amplitude from the physical site where the reference electrode was located.</br>


<h2 dir="auto">HarMNqEEG Installation and Requirements</h2>
<ol dir="auto">
<li>Matlab version: 2021a</li>
<li> Clone the the repository or download the .zip folder. </li>
<li>Extact the folder and Add the HarMNqEEG folder to your path in MATLAB</li>
<li> Call the main function HarMNqEEG_main.m</li>

</ol>

<strong> Requirements Installation</strong></br>
Matlab 2021b or higher


<h2 dir="auto">INPUT PARAMETERS:</h2> 
<h4>Auxiliar inputs</h4>
<ul>
<li>outputFolder_path: Path of output folder</li>
<li>generate_cross_spectra: Boolean parameter. Case False (0), will not  necessarily calculate the cross spectra. Case True (1) is required to calculate the cross spectra</li>
</ul>

<h4>Data Gatherer</h4>
<ul>
<li>raw_data_path : Folder path of the raw data in .mat format. This folder contains subfolders by each subject. 
                             The subfolder contains a .mat file with the following parameters:</br>
<ul>                              
							<li>  data  : an artifact-free EEG scalp data matrix, organized as nd x nt x ne, where</br>
                                              <ul style="list-style-type: none;"><li>    nd : number of channels</li>
                                                 <li> nt : epoch size (# of instants of times in an epoch)</li>
                                                 <li> ne : number of epochs</li></ul>
                              <li>   sampling_freq : sampling frequency in Hz. Eg: 200</li>
                              <li>   cnames    : a cell array containing the names of the channels. </br>
							                      The expected names are:</br>
                                                  'Fp1'    'Fp2'    'F3'    'F4'    'C3'    'C4'    'P3'    'P4'    'O1'    'O2'    'F7'    'F8'    'T3'    'T4'    'T5'    'T6'    'Fz'    'Cz'    'Pz'
                                                  If the channels come in another order, they are re-arranged according to the expected order</li>
                               <li>  data_code     : is the name of the original data file just for purpose of identification. It can be a code used by the owner to identify the data.</li>
                              <li>   reference     : a string containing the name of the reference of the data.</li>
                               <li>  age           : subject's age at recording time</li>
                               <li>  sex           : subject's sex</li>
                               <li>  country       : country providing the data</li>
                               <li>  eeg_device    : EEG hardware where the data was recorded</li>
								</ul></li></ul>
								
<h4>Preproccess Guassianize Data </h4>
<ul> <li>typeLog: Type of gaussianize method to apply. </br> 
										<strong>Options:</strong></br>
                                   <ul><li> typeLog(1): for log (Boolean):     log-spectrum</li>
                                    <li>typeLog(2): for riemlogm (Boolean): cross-spectrum with riemannian metric</li></ul>
</li></ul>									
									


<h4>Calculate z-scores and harmonize </h4>
<ul>
<li>batch_correction --> List of the batch correction that we have. </br>
				     <strong>Options:</strong></br>
		<ul>			 
                    <li> 1:  ANT_Neuro-Malaysia</li>
                    <li> 2:  BrainAmp_DC-Chengdu_2014</li>
                    <li> 3:  BrainAmp_MR_plus_64C-Chongqing</li>
                    <li> 4:  BrainAmp_MR_plus-Germany_2013</li>
                    <li> 5:  DEDAAS Barbados1978</li>
                    <li> 6:  DEDAAS-NewYork_1970s</li>
                    <li> 7:  EGI-256 HCGSN_Zurich(2017)-Swiss</li>
                    <li> 8:  Medicid-3M Cuba1990</li>
                    <li> 9:  Medicid-4 Cuba2003</li>
                    <li> 10: Medicid_128Ch-CHBMP</li>
                    <li> 11: NihonKohden-Bern(1980)_Swiss</li>
                    <li> 12: actiCHamp_Russia_2013</li>
                    <li> 13: Neuroscan_synamps_2-Colombia</li>
                    <li> 14: nvx136-Russia(2013)</li>
	   </ul>							

</ul>

<ul> <li>optional_matrix: List of matrix optional that the user can select. </br> 
										<strong>Options:</strong></br>
                                   <ul><li> optional_matrix(1): Complex matrix of FFT coefficients of nd x nfreqs x epoch length</li>
                                    <li>optional_matrix(2): Mean for Age of Riemannian Cross Spectra Norm</li></ul>
</li></ul>									
					

<h2 dir="auto">HarMNqEEG Output Description</h2>
<strong>Folder structure</strong></br>
The tool will be save a subfolder 'derivatives' (following the struct BIDs, https://bids.neuroimaging.io/) into the folder defined by the user with the outputFolder_path parameter. Into the subfolder derivatives, the result will saved by each folder subject. </br>
<strong>Type of output files</strong></br>
Into each folder subject will be saved two files HarMNqeeg_derivatives.json and HarMNqeeg_derivatives.h5. The .h5 file is a hdf5 format. HDF5 is a data model, library, and file format for storing and managing data (More info: https://portal.hdfgroup.org/display/HDF5/HDF5). The two files will saved commun values like the name of the tool, description, and other metas info. Also will be saved attributes and matrix description</br>
<ol>
   <li>Name_Subject: name of the subject</li>
   <li>Country: of the subject</li>
   <li>EEGMachine: EEG device with which the study was carried out</li>
   <li>Sex: sex of the subject</li>
   <li>Age: age of the subject</li>
   <li>MinFreq: Minimum spectral frequency (according to the data recording maybe down-sampled if higher than the expected, or the original one if lower than the expected)</li>
   <li>FreqRes: Frequency resolution (maybe down-sampled if higher than the expected, or the original one if lower than the expected)</li>
   <li>MaxFreq: Maximum spectral frequency (according to the data recording maybe down-sampled if higher than the expected, or the original one if lower than the expected) </li>
   <li>Epoch_Length: Epoch size (# of instants of times in an epoch)</li>
   <li>FFT_coefs: Complex matrix of FFT coefficients of nd x nfreqs x epoch length (stored for possible needed further processing for calculating the cross-spectral matrix, like regularization algorithms in case of ill-conditioning).</li>
   <li>reRefBatch: In case of the batch_correction is not empty. The reRefBatch is the batch correction of the z-scores</li>
</ol>
   
Also the HarMNqeeg_derivatives.h5 will be saved the following matrix:   
<ol>
   <li>Raw_Log_Spectra: Raw Log-spectra matrix, after average reference and GSF (Global Scale Factor) correction. Each row is a frequency. The value of the frequency is in the field Freq</li>
   <li>Harmonized_Log_Spectra: Harmonized log raw spectrum average reference and corrected by the GSF, harmonized by the correction of the given batch.</li>
   <li>Z_scores_Log_Spectra: The Z-scores of an individual raw Spectra. The element (i, f) of this matrix represents the deviation from normality of the power spectral density (PSD) of channel i and frequency f. The raw spectra is transformed to the Log space to achieve quasi gaussian distribution.</li>
   <li>Harmonized_Z_scores_Log_Spectra: Harmonized Z-score of the log raw spectrum average reference and corrected by the GSF, harmonized by the correction of the given batch.</li>
   <li>Raw_Riemannian_Cross_Spectra: Raw Cross-spectral matrix transformed to the Riemanian space.</li>
   <li>Harmonized_Raw_Cross_Spectra: Harmonized Raw Cross-spectral matrix transformed to the Riemanian space.</li>
   <li>Z_scores_Riemannian_Cross_Spectra: Z-scores of the Cross-spectral matrix transformed to the Riemanian space.</li>
   <li>Harmonized_Z_scores_Cross_Spectra: Harmonized Z-scores of the Cross-spectral matrix transformed to the Riemanian space.</li>   

</ol>

<strong>Optional Matrix</strong></br>
With the optional_matrix, the user can be select the following matrix to save:
<ol>
  <li>FFT_coefs: Complex matrix of FFT coefficients of nd x nfreqs x epoch length</li>
  <li>Mean_for_Age_of_Riemannian_Cross_Spectra_Norm: Mean for Age of Riemannian Cross Spectra Norm</li>
</ol>


<h2 dir="auto">HarMNqEEG EXAMPLE</h2>
In the folder example_data, there are two subfolders and the test_HarMNqEEG.m file to run the tool with data example.

<ul>
  <li>Subfolder: with_cross_spectra_generated. This folder will be the raw_data_path parameter. This folder contains 2 subjects by folder for testing the tool. In each subject folder there is a .mat file with the <strong>cross spectra generated</strong>. When the raw_data_path parameters is the results of the data_gatherer ( Github location of the script: https://github.com/CCC-members/BC-V_group_stat/blob/master/data_gatherer.m), the generate_cross_spectra parameter must be 0 </li>
  <li>Subfolder: without_the_cross_spectra_generated. This folder will be the raw_data_path parameter. This folder contains 2 subjects by folder for testing the tool. In each subject folder there is a .mat file with the <strong>cross spectra input data</strong>. The generate_cross_spectra parameter must be 1 </li>
</ul>
