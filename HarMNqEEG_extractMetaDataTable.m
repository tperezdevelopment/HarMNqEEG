function [metaDataMatrix] = HarMNqEEG_extractMetaDataTable(DPs_table,metaDataName, typeLog)
%% The objetive funtion is extract Metadata from Table

if ~ischar(metaDataName)
    error(['Error, the variable' metaDataValue 'need to be a string']);
end


% Declare variables that for future may be will request to the user
num_channel=18;

switch typeLog
    case 'log'
        % init the matrix output
        metaDataMatrix=[];
        stand_col_extract=cellfun(@(x) append(metaDataName,num2str(x),'_', num2str(x)), num2cell((1:18)'), 'UniformOutput', false);
        for i=1:num_channel
            metaDataMatrix=[metaDataMatrix DPs_table.(char(stand_col_extract(i)))]; %#ok<AGROW>
        end
    case  'riemlogm'  %% developed by Bosch
        fn = fieldnames(DPs_table);
        ind = strmatch(metaDataName, fn); %#ok<*MATCH2> 
        st = strrep(fn(ind), metaDataName, '');
        xi = zeros(length(st),1); yi = xi;
        for k=1:length(st)
            s=strsplit(st{k}, '_');
            xi(k) = str2double(s{1}); yi(k) = str2double(s{2});
        end
        nv = max(xi);
        nf = size(DPs_table,1);
        indtril = sub2ind([nv, nv], xi, yi);
        metaDataMatrix = zeros(nv*nv, nf);
        metaDataMatrix(indtril, :) = DPs_table{:,ind}';
        indtriu = sub2ind([nv, nv], yi, xi);
        metaDataMatrix(indtriu, :) = conj(DPs_table{:,ind}');
        metaDataMatrix = reshape(metaDataMatrix, nv, nv, nf);

end





end