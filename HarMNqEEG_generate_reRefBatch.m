function [reRefBatch] = HarMNqEEG_generate_reRefBatch(batch_correction,country, EEGMachine)
%% This will generate the reference for the batch correction


nomenclatura_batch=[country '_' EEGMachine];

try
    batch_correction=str2num(batch_correction); %#ok<ST2NM>

    if sum(batch_correction)>1
        error('You must select only one batch correction');
    elseif isempty(find(batch_correction, 1))
         reRefBatch=[];
    else

        switch find(batch_correction)
            case 1
                reRefBatch={nomenclatura_batch,'DEDAAS Barbados1978'};
            case 2
                reRefBatch={nomenclatura_batch, 'BrainAmp_MR_plus_64C-Chongqing'};
            case 3
                reRefBatch={nomenclatura_batch, 'BrainAmp_DC-Chengdu_2014'};
            case 4
                reRefBatch={nomenclatura_batch, 'Medicid3M-Cuba1990'};
            case 5
                reRefBatch={nomenclatura_batch, 'Medicid-4-Cuba'};
            case 6
                reRefBatch={nomenclatura_batch, 'Medicid_128Ch-CHBMP'};
            case 7
                reRefBatch={nomenclatura_batch, 'Neuroscan_synamps_2-Colombia'};
            case 8
                reRefBatch={nomenclatura_batch, 'ANT_Neuro-Malaysia'};
            case 9
                reRefBatch={nomenclatura_batch, 'BrainAmp_MR_plus-Germany_2013'};
            case 10
                reRefBatch={nomenclatura_batch, 'actiCHamp_Russia_2013'};
            case 11
                reRefBatch={nomenclatura_batch, 'nvx136-Russia(2013)'};
            case 12
                reRefBatch={nomenclatura_batch, 'EGI-256 HCGSN_Zurich(2017)-Swiss'};
            case 13
                reRefBatch={nomenclatura_batch, 'NihonKohden-Bern(1980)_Swiss'};
            case 14
                reRefBatch={nomenclatura_batch, 'DEDAAS-NewYork_1970s'};
            otherwise
                reRefBatch=[];
        end

    end
catch
    error('Incorrect definition of the parameter "Batch correction"')

end
end

