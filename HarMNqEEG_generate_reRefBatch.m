function [reRefBatch] = HarMNqEEG_generate_reRefBatch(batch_correction,country, EEGMachine)
%% This will generate the reference for the batch correction

nomenclatura_batch=[country '_' EEGMachine];

try
    %     if class(batch_correction)=="string" || class(batch_correction)=="char"
    %         batch_correction=str2double(batch_correction);
    %     end

    if isempty(find(batch_correction, 1))
        reRefBatch=[];
    else
        switch batch_correction
            case {1, '1' , 'ANT_Neuro-Malaysia'}
                reRefBatch={nomenclatura_batch,'ANTNeuro Malaysia'};

            case {2, '2', 'BrainAmp_DC-Chengdu_2014'}
                reRefBatch={nomenclatura_batch, 'BrainAmpDC Chengdu'};

            case {3, '3', 'BrainAmp_MR_plus_64C-Chongqing'}
                reRefBatch={nomenclatura_batch, 'BrainAmpMRplus Chongqing'};

            case {4, '4', 'BrainAmp_MR_plus-Germany_2013'}
                reRefBatch={nomenclatura_batch, 'BrainAmpMRplus Germany'};

            case {5, '5', 'DEDAAS-Barbados1978'}
                reRefBatch={nomenclatura_batch, 'DEDAAS Barbados1978'};

            case {6, '6', 'DEDAAS-NewYork_1970s'}
                reRefBatch={nomenclatura_batch, 'DEDAAS NewYork'};

            case {7, '7', 'EGI-256_HCGSN_Zurich(2017)-Swiss'}
                reRefBatch={nomenclatura_batch, 'EGI Zurich'};

            case {8, '8', 'Medicid-3M-Cuba1990'}
                reRefBatch={nomenclatura_batch, 'Medicid-3M Cuba1990'};

            case {9, '9', 'Medicid-4-Cuba2003'}
                reRefBatch={nomenclatura_batch, 'Medicid-4 Cuba2003'};

            case {10, '10', 'Medicid_128Ch-CHBMP'}
                reRefBatch={nomenclatura_batch, 'Medicid-5 CHBMP'};

            case {11, '11', 'NihonKohden-Bern(1980)_Swiss'}
                reRefBatch={nomenclatura_batch, 'NihonKohden Bern'};

            case {12, '12', 'actiCHamp_Russia_2013'}
                reRefBatch={nomenclatura_batch, 'actiChamp Russia'};

            case {13, '13', 'Neuroscan_synamps_2-Colombia'}
                reRefBatch={nomenclatura_batch, 'neuroscan Colombia'};

            case {14, '14', 'nvx136-Russia(2013)'}
                reRefBatch={nomenclatura_batch, 'nvx136 Russia'};

            otherwise
                reRefBatch=[];
        end

    end
catch
    error('Incorrect definition of the parameter "Batch correction"')

end


