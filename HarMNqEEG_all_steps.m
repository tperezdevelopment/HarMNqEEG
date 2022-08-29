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
    DsetAttr = {'Algorithm', 'FFT Matlab R2020';'Domain', 'Frequency'; 'Dimensions', 'Nc x Nf x Ne (Number of channels, Number of frequencies, Number of epochs)'; 'DataType', '3D Complex Matrix'; ...
        'Description', 'Complex matrix of FFT coefficients of the EEG data (stored for possible needed further processing for calculating the cross-spectral matrix, like regularization algorithms in case of ill-conditioning).'; ...
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
    DsetAttr={'Domain', 'Frequency'; 'Dimensions', 'Nc x Nf (Number of channels, Number of frequencies)' ; 'DataType', '2D Spectral Matrix'; ...
        'Description', 'The (i, j) element of this matrix (where i,j=1:Nc and f=1:Nf) are the real log power spectral density (PSD) of channel i and frequency f. The raw spectra are transformed to the Log space to achieve quasi gaussian distribution.'; ...
        'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
    prec='double';
    [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, derivatives_output_folder, data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'log', 'log'), DsetAttr);

    if ~isempty(reRefBatch)
        %% Save the Harmonized Raw Log-Spectra
        dsetname = 'Harmonized_Raw_Log_Spectra'; dtype='Real_Matrix';
        DsetAttr={'Domain', 'Frequency (Euclidean space)'; 'Dimensions', 'Nc x Nf (Number of channels, Number of frequencies)' ;'DataType', '2D Spectral Matrix'; ...
            'Description', 'Same as the Raw Log-Spectra after harmonization to account for the batch effect.';...
            'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
        prec='double';
        [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, derivatives_output_folder, data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'ystarlog', 'log'), DsetAttr);
    end

    %% Save the Z-scores Log Spectra
    dsetname = 'Z_scores_Log_Spectra'; dtype='Real_Matrix';
    DsetAttr={'Domain', 'Frequency (Euclidean space)'; 'Dimensions', 'Nc x Nf (Number of channels, Number of frequencies)' ; 'DataType', '2D Spectral Matrix'; ...
        'Description', 'The Z-scores of an individual raw Spectra. The element (i, f) of this matrix represents the deviation from normality of the log power spectral density (PSD) of channel i and frequency f.';...
        'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
    prec='single';
    [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, derivatives_output_folder, data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'zgloballog', 'log'), DsetAttr);

    if ~isempty(reRefBatch)
        %% Save the Harmonized Z-scores Log Spectra
        dsetname = 'Harmonized_Z_scores_Log_Spectra'; dtype='Real_Matrix';
        DsetAttr={'Domain', 'Frequency (Euclidean space)'; 'Dimensions', 'Nc x Nf (Number of channels, Number of frequencies)' ; 'DataType', '2D Spectral Matrix'; ...
            'Description', 'Same as the Z-scores Log Spectra for the harmonized Raw Log-Spectra.';...
            'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
        prec='single';
        [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, derivatives_output_folder, data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'zstudylog', 'log'), DsetAttr);
    end
    disp('----------------------------------------------------------------- END Calculates for log-spectrum -----------------------------------------------------------------');
end

if typeLog(2)==1
    disp('----------------------------------------------------------------- Calculates for cross-spectrum in Tangent Space -----------------------------------------------------------------');
    [T] = HarMNqEEG_step2_step3_by_typeLog(data_struct, 'riemlogm', reRefBatch);

    %% MATRIX STEP 2
    %%% declare same parameters for all the matrix
    prec='double';
    freqrange=T.freq';
    MinFreq=freqrange(1);
    MaxFreq=freqrange(end);

    %% Save the Raw Cross-Spectra in Tangent Space
    dsetname = 'Raw_Cross_Spectra_in_Tangent_Space'; dtype='Hermitian';
    DsetAttr={'Domain', 'Frequency (Riemannian manifold)'; 'Dimensions', 'Nc x Nc x Nf' ; 'DataType', '3D Hermitian Tensor'; ...
        'Description', 'The (i, j) element of the f-th matrix (where i,j=1:Nc and f=1:Nf) are the complex cross-spectrum between channels i and j, at frequency f, transformed to the tangent space. It is understood as a measurement of coupling between the time series of channels I and j, at frequency f.';...
        'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
    %% Notes globalriemlogm and riemlogm are the same
    [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, derivatives_output_folder, data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'globalriemlogm', 'riemlogm'), DsetAttr);

    if ~isempty(reRefBatch)
        %% Save the Harmonized Raw Cross-Spectra in Tangent Space
        dsetname = 'Harmonized_Raw_Cross_Spectra_in_Tangent_Space'; dtype='Hermitian';
        DsetAttr={'Domain', 'Frequency (Riemannian manifold)'; 'Dimensions', 'Nc x Nc x Nf' ; 'DataType', '3D Hermitian Tensor'; ...
            'Description', 'Same as the Raw Cross-Spectra in Tangent Space, after harmonization to account for the batch effect.';...
            'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
        [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, derivatives_output_folder, data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'ystarriemlogm', 'riemlogm'), DsetAttr);
    end

    %% Save the Z-scores of Cross-Spectra in Tangent Space
    dsetname = 'Z_scores_of_Cross_Spectra_in_Tangent_Space'; dtype='Hermitian';
    DsetAttr={'Domain', 'Frequency'; 'Dimensions', 'Nc x Nc x Nf' ; 'DataType', '3D Hermitian Tensor'; ...
        'Description', 'It is the Z-scores of the Raw Cross-Spectra in Tangent Space.';...
        'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
    [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, derivatives_output_folder, data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'zglobalriemlogm', 'riemlogm'), DsetAttr);

    if ~isempty(reRefBatch)
        %% Save the Harmonized Z-scores of Cross-Spectra in Tangent Space
        dsetname = 'Harmonized_Z_scores_of_Cross_Spectra_in_Tangent_Space'; dtype='Hermitian';
        DsetAttr={'Domain', 'Frequency'; 'Dimensions', 'Nc x Nc x Nf' ; 'DataType', '3D Hermitian Tensor'; ...
            'Description', 'It is the Z-scores of the Harmonized Raw Cross-Spectra in Tangent Space.'; ...
            'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
        [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, derivatives_output_folder, data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'zstudyriemlogm', 'riemlogm'), DsetAttr);
    end

    %% Saving muglobalriemlogm (Optional Matrix). Age evaluated Norms Mean of Cross Spectra in Tangent Space
    if optional_matrix(2)==1
        dsetname = 'Age_evaluated_Norms_Mean_of_Cross_Spectra_in_Tangent_Space'; dtype='Complex_Matrix';
        DsetAttr={'Domain', 'Frequency'; 'Dimensions', 'Nc x Nc x Nf' ; 'DataType', '3D Hermitian Tensor'; ...
            'Description', 'This is obtained by evaluating the Mean of the normative regression for the Raw Cross-Spectra in Tangent Space, at the subject’s age.'; ...
            'Minimum_Spectral_Frequency', num2str(MinFreq); 'Maximum_Spectral_Frequency', num2str(MaxFreq); 'Frequency_Range',  freqrange };
        [jsonFile] = HarMNqeeg_derivates_main_store(@HarMNqeeg_derivates_overwrite, derivatives_output_folder, data_code, jsonFile, dsetname, dtype, prec, HarMNqEEG_extractMetaDataTable(T,'muglobalriemlogm', 'riemlogm'), DsetAttr);
    end
    disp('----------------------------------------------------------------- END Calculates for cross-spectrum in Tangent Space -----------------------------------------------------------------');

end


%% Saving json file
saveJSON(jsonFile,[derivatives_output_folder filesep 'HarMNqeeg_derivatives_' data_code '.json'])





end

