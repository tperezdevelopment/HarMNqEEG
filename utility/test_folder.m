function test_folder(name,cat)
%%
%     Author: Ying Wang, Min Li
%     Create Time: 2021
%     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
%     Joint China-Cuba LAB, UESTC
 
if nargin<2
 [~,~,e] = fileparts(name);
    if isempty(e)
        cat='dir';
    else
        cat='file';
    end
end



if strcmp(cat,'dir')
    if(~exist(name,'dir'))
        mkdir(name);
    end
else
    [p,~,~] = fileparts(name);
    if(~exist(p,'dir'))
        mkdir(p);
    end
end



