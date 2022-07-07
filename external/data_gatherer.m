function [data_struct, error_msg] = data_gatherer(data, SAMPLING_FREQ, cnames, data_code, reference, age, sex, country, eeg_device)

% This function collects EEG data and stores them in a standardized
% structure, to be used in the multi-national norms project.
% A minimum of 4 analysis epochs is required to calculate the
% cross-spectral matrices. It is because at this point, only the EEG
% spectra will be use and the requirement is relaxed.
% The requirements are determined to be compatible with the Cuban Normative data 1990:
% Bosch-Bayard, J.; Galan, L.; Aubert, E.; Virues, T.; Valdes-Sosa, P.A.
% Resting state healthy EEG: the first wave of the Cuban normative database.
% Data Report, Front. Neurosci. - Brain Imaging Methods, 2020, 14:555119. doi: 10.3389/fnins.2020.555119.
% 
% The analysis windows are standardized to a length of 2.56 seconds,
% producing a frequency resolution of 0.390625 Hz. If a higher resolution
% is found it is down-sampled to match the standard one. If it is lower, the
% spectra are calculated using the original sampling frequency and then
% interpolated to achieve the standardized frequency resolution.
% This function does not apply any transformation to the data, as Average
% Reference or other. The data is processed in its original reference and
% changes will be applied at the processing time.

% For this project, the EEG data is expected to be organized as artifact
% free epochs. Since only 19 channels are used, it would be preferrable
% that the epochs are selected by visual inspection of a human expert and
% not any automatic preprocessing procedure is used.

% INPUTS:
% data          : an artifact-free EEG scalp data matrix, organized as nd x nt x ne, where
%                 nd : number of channels
%                 nt : epoch size (# of instants of times in an epoch)
%                 ne : number of epochs
% SAMPLING_FREQ : sampling frequency in Hz. Eg: 200
% cnames        : a cell array containing the names of the channels. The expected names are:
%                 'Fp1'    'Fp2'    'F3'    'F4'    'C3'    'C4'    'P3'    'P4'    'O1'    'O2'    'F7'    'F8'    'T3'    'T4'    'T5'    'T6'    'Fz'    'Cz'    'Pz'
%                 If the channels come in another order, they are re-arranged according to the expected order
% data_code     : is the name of the original data file just for purpose of identification.
%                 It can be a code used by the owner to identify the data.
% reference     : a string containing the name of the reference of the data.
% age           : subject's age at recording time
% sex           : subject's sex
% country       : country providing the data
% eeg_device    : EEG hardware where the data was recorded

% OUTPUTS:
% data_struct: Structure of:
%     name   : data_code
%     srate  : SAMPLING_FREQ
%     nchan  : length(cnames)
%     dnames : channels names in its final order (always the standardized order)
%     ref    : reference
%     data   : data used for cross-spectra calculation. Different from input if the data was down-sampled
%     nt     : epoch size (# of instants of times in an epoch)
%     age    : age
%     sex    : sex
%     pais   : country
%     EEGMachine : eeg_device
%     nepochs : number of epochs
%     fmin    : Minimum spectral frequency (according to the data recording maybe down-sampled if higher than the expected, or the original one if lower than the expected)
%     freqres : frequency resolution (maybe down-sampled if higher than the expected, or the original one if lower than the expected)
%     fmax    : Maximum spectral frequency (according to the data recording maybe down-sampled if higher than the expected, or the original one if lower than the expected)
%     CrossM  : complex cross spectral matrix of nd x nd x nfreqs (nfreqs according to the spanning: fmin:freqres:fmax)
%     ffteeg  : complex matrix of FFT coefficients of nd x nfreqs x nepochs (stored for possible needed further processing for calculating the
%              cross-spectral matrix, like regularization algorithms in case of ill-conditioning)
%     freqrange: the spanning of fmin:freqres:fmax
%     Spec    : EEG spectra. Same as the diagonal of CrossM, or interpolated to satisfy the expected frequency range if the original frequency
%               resolution was lower than needed.
%     Spec_freqrange : Frequency range of the spectra. It will always be 0.390625:0.390625:(nfreqs*0.390625)


% Author: J. Bosch-Bayard
% Version: 0
% Date: Feb-10-2021

%%% Standard options for the MultiNational Norms project%%%%%%
desired_order = {'Fp1'    'Fp2'    'F3'    'F4'    'C3'    'C4'    'P3'    'P4'    'O1'    'O2'    'F7'    'F8'    'T3'    'T4'    'T5'    'T6'    'Fz'    'Cz'    'Pz'};
desired_freqres = 0.3906; %Hz
desired_epoch_size = 1./desired_freqres; %in seconds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

error_msg = '';
interpolate = 0;
sp = 1 ./ SAMPLING_FREQ;
[nd, epoch_size, nepochs] = size(data);
real_freqres = 1 ./ (sp*epoch_size);

if round(real_freqres*100)/100 < round(desired_freqres*100)/100  %reduce the epoch_size to match the desired frequency resolution
    new_epoch_size = floor(desired_epoch_size ./ sp); %epoch size which will guarantee the desired frequency resolution
    data = data(:, 1:new_epoch_size, :);
    [nd, epoch_size, nepochs] = size(data);
    real_freqres = 1 ./ (sp*epoch_size);
elseif round(real_freqres*100)/100 > round(desired_freqres*100)/100  %The epoch size is too short to achieve the desired frequency resolution. It will be necessary to interpolate the spectra
    interpolate = 1;
end

if nepochs > 3  %At least need 3 analysis windows to calculate the cross spectral matrices

    %check if the channels are in the desired order
    [sd, od] = ismember(lower(desired_order), lower(cnames));
    if any(od == 0)
        data_struct = [];
        error_msg = 'The dataset does not contain the needed channels';
        return;
    end
    data = data(od, :,:);
    data_struct.name = data_code;
    data_struct.srate = SAMPLING_FREQ;
    data_struct.nchan = length(cnames);
    data_struct.dnames = desired_order;
    data_struct.ref = reference;
    data_struct.data = data;
    data_struct.nt = epoch_size;
    data_struct.age = age;
    data_struct.sex = sex;
    data_struct.pais = country;
    data_struct.EEGMachine = eeg_device;
    data_struct.nepochs = nepochs;
    
    [Spec, data_struct.fmin, data_struct.freqres, data_struct.fmax, data_struct.CrossM, data_struct.ffteeg] = eeg_to_sp(data, sp);
    data_struct.freqrange = data_struct.fmin:data_struct.freqres:data_struct.fmax;
    
    if interpolate %Interpolate the coefficients to match the spectra to the desired frequency range
        real_frange = data_struct.fmin:data_struct.freqres:data_struct.freqres*size(Spec,2);
        desired_frange = desired_freqres:desired_freqres:desired_freqres*size(Spec,2);
        Sp = Spec;
        for h=1:size(Spec,1)
            Spec(h,:) = pchip(real_frange, Spec(h,:), desired_frange);
        end
        %%%%%%%%%%%%
        %Here just to guarantee that the interpolation procedure did not introduced negative laues in the spectra
        % It is not likely for pchip function, but just in case
        Spec(:,1) = Sp(:,1);
        ii = find(Spec < 0);
        if ~isempty(ii)
            data_struct = [];
            error_msg = 'The interpolation produced negative values in the spectra';
            return
        end
        ii = find(Spec < eps);
        Spec(ii) = 1.0e-7; %If too low for zero, then just make a little less smaller, since log will be used
        %%%%%%%%%%%%%%%%%%%%%%%%
        data_struct.Spec = Spec;
        data_struct.Spec_freqrange = desired_frange;
    else
        data_struct.Spec = Spec;
        data_struct.Spec_freqrange = data_struct.freqrange;
    end

else %Too few analysis windows
    data_struct = [];
    error_msg = 'Too few analysis windows';
end


function [Spec, fmin, freqres, fmax, CrossM, ffteeg] = eeg_to_sp(EEG, sp)
% EEG: EEG scalp data matrix, organized as nd x nt x ne, where
% nd : number of channels
% nt : epoch size (# of instants of times in an epoch)
% ne : number of epochs
% sp : sampling period in seconds. Eg: 0.005 means 5 millisec

[nd, nt, ne] = size(EEG);
NFFT = nt;
freqres = 1 ./ (sp*NFFT);
fmin = freqres;
fmax = 1 ./ (2*sp);

ncoefs = floor(nt./2);
ffteeg = zeros(nd, ncoefs, ne);

% wind = reshape(hanning(nt), 1, nt); %multiply the EEG signal by Hanning windows

CrossM = zeros(nd, nd, ncoefs); % allocated matrix for the cross spectrum
for k=1:ne
  % A=EEG(:,:,k) .* repmat(wind, nd, 1);  %Applying Hanning window
  A=EEG(:,:,k);  %In this version we don't use windows to be compatible with the cross-spectra of the Cuban Normative data 1990
  f = fft(A,NFFT,2);
  f = f(:, 2:ncoefs+1); %Nyquist
  ffteeg(:,:,k) = f;
  
  for h=1:ncoefs
      CrossM(:,:,h) = CrossM(:,:,h) + f(:,h) * f(:,h)';
  end

end
CrossM = CrossM ./ ne;
Spec = zeros(nd, ncoefs); % allocated matrix for the spectrum
for k=1:size(CrossM,3)
    Spec(:,k) = diag(CrossM(:,:,k));
end
Spec = real(Spec); %This should not be necessary, but anyway

