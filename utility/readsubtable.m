function output=readsubtable(path_table,key)
%%
%     Author: Ying Wang, Min Li
%     Create Time: 2021
%     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
%     Joint China-Cuba LAB, UESTC
 
opts = detectImportOptions(path_table);
opts.SelectedVariableNames = key;
output=readtable(path_table,opts);

end



