function [reRefBatch] = HarMNqEEG_generate_reRefBatch(batch_correction,country, EEGMachine)
%% This will generate the reference for the batch correction

nomenclatura_batch=[country '_' EEGMachine];

try
    batch_correction=str2double(batch_correction); 

    if isempty(find(batch_correction, 1))
         reRefBatch=[];
    else
        switch batch_correction
            case 1
                reRefBatch={nomenclatura_batch,'ANTNeuro Malaysia'};
            case 2
                reRefBatch={nomenclatura_batch, 'BrainAmpDC Chengdu'};                 
            case 3
                reRefBatch={nomenclatura_batch, 'BrainAmpMRplus Chongqing'};
            case 4
                reRefBatch={nomenclatura_batch, 'BrainAmpMRplus Germany'};
            case 5
                reRefBatch={nomenclatura_batch, 'DEDAAS Barbados1978'};
            case 6
                reRefBatch={nomenclatura_batch, 'DEDAAS NewYork'};
            case 7
                reRefBatch={nomenclatura_batch, 'EGI Zurich'};
            case 8
                reRefBatch={nomenclatura_batch, 'Medicid-3M Cuba1990'};
            case 9
                reRefBatch={nomenclatura_batch, 'Medicid-4 Cuba2003'};
            case 10
                reRefBatch={nomenclatura_batch, 'Medicid-5 CHBMP'};
            case 11
                reRefBatch={nomenclatura_batch, 'NihonKohden Bern'};
            case 12
                reRefBatch={nomenclatura_batch, 'actiChamp Russia'};
            case 13
                reRefBatch={nomenclatura_batch, 'neuroscan Colombia'};
            case 14
                reRefBatch={nomenclatura_batch, 'nvx136 Russia'};
            otherwise
                reRefBatch=[];
        end

    end
catch
    error('Incorrect definition of the parameter "Batch correction"')

end


