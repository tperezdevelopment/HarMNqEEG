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
                    <li> batch_correction(1):  ANT_Neuro-Malaysia</li>
                    <li> batch_correction(2):  BrainAmp_DC-Chengdu_2014</li>
                    <li> batch_correction(3):  BrainAmp_MR_plus_64C-Chongqing</li>
                    <li>batch_correction(4):  BrainAmp_MR_plus-Germany_2013</li>
                    <li> batch_correction(5):  DEDAAS Barbados1978</li>
                    <li> batch_correction(6):  DEDAAS-NewYork_1970s</li>
                    <li> batch_correction(7):  EGI-256 HCGSN_Zurich(2017)-Swiss</li>
                    <li>batch_correction(8):  Medicid-3M Cuba1990</li>
                    <li> batch_correction(9):  Medicid-4 Cuba2003</li>
                    <li> batch_correction(10): Medicid_128Ch-CHBMP</li>
                    <li> batch_correction(11): NihonKohden-Bern(1980)_Swiss</li>
                    <li> batch_correction(12): actiCHamp_Russia_2013</li>
                    <li> batch_correction(13): Neuroscan_synamps_2-Colombia</li>
                    <li> batch_correction(14): nvx136-Russia(2013)</li>
	   </ul>							

</ul>

<strong>HarMNqEEG EXAMPLE</strong></br>
In the folder example_data, there are two subfolders and the test_HarMNqEEG.m file to run the tool with data example.

<ul>
  <li>Subfolder: with_cross_spectra_generated. This folder will be the raw_data_path parameter. This folder contains 2 subjects by folder for testing the tool. In each subject folder there is a .mat file with the <strong>cross spectra generated</strong>. When the raw_data_path parameters is the results of the data_gatherer ( Github location of the script: https://github.com/CCC-members/BC-V_group_stat/blob/master/data_gatherer.m), the generate_cross_spectra parameter must be 0 </li>
  <li>Subfolder: without_the_cross_spectra_generated. This folder will be the raw_data_path parameter. This folder contains 2 subjects by folder for testing the tool. In each subject folder there is a .mat file with the <strong>cross spectra input data</strong>. The generate_cross_spectra parameter must be 1 </li>
</ul>
