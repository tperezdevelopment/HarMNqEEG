function TF=isexist(name,searchType)
%%
%     Author: Ying Wang, Min Li
%     Create Time: 2021
%     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
%     Joint China-Cuba LAB, UESTC
 
if ischar(name) || isstring(name)
    name={name};
end
num_name=numel(name);
TF=false(num_name,1);
for i=1:num_name
    TF(i)=exist(name{i},searchType);    
end
end