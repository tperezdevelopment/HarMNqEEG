function [data_table,row_indx_orig]=get_subtable(data_table,condition,items)
 %%
 %     Author: Ying Wang, Min Li
 %     Create Time: 2021
 %     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
 %     Joint China-Cuba LAB, UESTC
 
num_condition=numel(condition);
row_indx_orig=1:size(data_table,1);
for i=1:2:num_condition
    item=condition{i};
    property=condition{i+1};
    if ischar(property)
        row_indx=strcmp(data_table.(item),property);
    elseif iscell(property)
        row_indx=find_char(data_table.(item),property,true);
    elseif istable(property)
        row_indx=find_char(data_table.(item),table2cell(property),true);
    elseif isnumeric(property)
        row_indx=find(ismember(data_table.(item),property));
    end
    data_table=data_table(row_indx,:);
    row_indx_orig=row_indx_orig(row_indx);
end
if nargin>2 && ~isempty(items)
    col_idx=find_char(data_table.Properties.VariableNames,items);
    data_table=data_table(:,col_idx);
end
    

end




