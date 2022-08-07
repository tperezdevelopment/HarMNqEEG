function [] = HarMNqEEG_all_steps(derivatives_output_folder,generate_cross_spectra, typeLog, all_data, data_code, batch_correction, optional_matrix)
% Calculate all steps by subject or session for longitudinal data

if generate_cross_spectra
    %% Call data_gatherer
    [data_struct, error_msg] = data_gatherer(all_data.data, all_data.sampling_freq, all_data.cnames,data_code , ...
        all_data.reference, all_data.age, all_data.sex, all_data.country, all_data.eeg_device);
    if ~isempty(error_msg)
        warning(error_msg);
        return;
    end
else
     data_struct=all_data;
end
%%% reference batch
[reRefBatch] = HarMNqEEG_generate_reRefBatch(batch_correction,data_struct.pais, data_struct.EEGMachine);



%% Declare the json File and .h5 file
[jsonFile]=HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_init,derivatives_output_folder, data_code,data_struct.freqres,...
    data_struct.nt, data_struct.dnames, data_struct.srate ,data_struct.name, ...
    data_struct.pais, data_struct.EEGMachine, data_struct.age,reRefBatch);


%% Saving FFTCoefs (Optional Matrix)
if optional_matrix(1)==1
    dsetname = 'FFT_coefs'; dtype='Complex_Matrix';
    DsetAttr = {'Algorithm', 'FFT Matlab R2020';'Domain', 'Frequency'; 'Description', 'Complex matrix of FFT coefficients of nd x nfreqs x epoch length (stored for possible needed further processing for calculating the cross-spectral matrix, like regularization algorithms in case of ill-conditioning).'; ...
        'Minimum_Spectral_Frequency', num2str(data_struct.fmin); 'Maximum_Spectral_Frequency', num2str(data_struct.fmax); 'Frequency_Range',  data_struct.freqrange };
    prec='double';
    [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, derivatives_output_folder, data_code, jsonFile, dsetname, dtype, prec, data_struct.ffteeg, DsetAttr);

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
    [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, derivatives_output_folder, data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'log', 'log'), DsetAttr);

    %% Save the Harmonized Raw Log-Spectra
    dsetname = 'Harmonized_Log_Spectra'; dtype='Real_Matrix';
    DsetAttr={'Domain', 'Frequency (Euclidean space)'; 'Dimensions', 'Nc x Nf (Number of channels, Number of frequencies)' ; 'Description', 'Harmonized log raw spectrum average reference and corrected by the GSF, harmonized by the correction of the given batch.';...
        'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
    prec='double';
    [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, derivatives_output_folder, data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'ystarlog', 'log'), DsetAttr);


    %% Save the Z-scores Log Spectra
    dsetname = 'Z_scores_Log_Spectra'; dtype='Real_Matrix';
    DsetAttr={'Domain', 'Frequency (Euclidean space)'; 'Dimensions', 'Nc x Nf (Number of channels, Number of frequencies)' ; 'Description', 'The Z-scores of an individual raw Spectra. The element (i, f) of this matrix represents the deviation from normality of the power spectral density (PSD) of channel i and frequency f. The raw spectra is transformed to the Log space to achieve quasi gaussian distribution.';...
        'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
    prec='single';
    [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, derivatives_output_folder, data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'zgloballog', 'log'), DsetAttr);

    if ~isempty(reRefBatch)
        %% Save the Harmonized Z-scores Log Spectra
        dsetname = 'Harmonized_Z_scores_Log_Spectra'; dtype='Real_Matrix';
        DsetAttr={'Domain', 'Frequency (Euclidean space)'; 'Dimensions', 'Nc x Nf (Number of channels, Number of frequencies)' ; 'Description', 'Harmonized Z-score of the log raw spectrum average reference and corrected by the GSF, harmonized by the correction of the given batch.';...
            'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
        prec='single';
        [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, derivatives_output_folder, data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'zstudylog', 'log'), DsetAttr);
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
    DsetAttr={'Domain', 'Frequency (Riemannian manifold)'; 'Dimensions', 'Nc x Nc x Nf' ; 'Description', 'Raw Cross-spectral matrix transformed to the Tangent space.';...
        'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
    %% Notes globalriemlogm and riemlogm are the same
    [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, derivatives_output_folder, data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'globalriemlogm', 'riemlogm'), DsetAttr);

    %% Save the Harmonized Raw Riemannian Cross-Spectra
    dsetname = 'Harmonized_Raw_Riemannian_Cross_Spectra'; dtype='Hermitian';
    DsetAttr={'Domain', 'Frequency (Riemannian manifold)'; 'Dimensions', 'Nc x Nc x Nf' ; 'Description', 'Harmonized Raw Cross-spectral matrix transformed to the Tangent space.';...
        'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
    [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, derivatives_output_folder, data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'ystarriemlogm', 'riemlogm'), DsetAttr);

    %% Save the Z-scores Riemannian Cross-Spectra
    dsetname = 'Z_scores_Riemannian_Cross_Spectra'; dtype='Hermitian';
    DsetAttr={'Domain', 'Frequency'; 'Dimensions', 'Nc x Nc x Nf' ; 'Description', 'Z-scores of the Cross-spectral matrix transformed to the Tangent space.';...
        'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
    [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, derivatives_output_folder, data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'zglobalriemlogm', 'riemlogm'), DsetAttr);

    if ~isempty(reRefBatch)
        %% Save the Harmonized Z-scores Riemannian Cross-Spectra
        dsetname = 'Harmonized_Z_scores_Riemannian_Cross_Spectra'; dtype='Hermitian';
        DsetAttr={'Domain', 'Frequency'; 'Dimensions', 'Nc x Nc x Nf' ; 'Description', 'Harmonized Z-scores of the Cross-spectral matrix transformed to the Tangent space.'; ...
            'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
        [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, derivatives_output_folder, data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'zstudyriemlogm', 'riemlogm'), DsetAttr);
    end

    %% Saving muglobalriemlogm (Optional Matrix)
    if optional_matrix(2)==1
        dsetname = 'Mean_for_Age_of_Riemannian_Cross_Spectra_Norm'; dtype='Complex_Matrix';
        DsetAttr={'Domain', 'Frequency'; 'Dimensions', 'Nc x Nc x Nf' ; 'Description', 'Mean for Age of Riemannian Cross Spectra Norm.'; ...
            'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
        [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, derivatives_output_folder, data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'muglobalriemlogm', 'riemlogm'), DsetAttr);
    end
    disp('----------------------------------------------------------------- END Calculates for cross-spectrum with riemannian metric -----------------------------------------------------------------');

end


%% Saving json file
saveJSON(jsonFile,[derivatives_output_folder filesep 'HarMNqeeg_derivatives_' data_code '.json'])





end

