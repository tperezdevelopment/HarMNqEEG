function index=find_char(char_cell1,char_cell2,opt,ignorecase)
%%
 %     Author: Ying Wang, Min Li
 %     Create Time: May 22, 2021
 %     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
 %     Joint China-Cuba LAB, UESTC
 
if nargin<3
    opt=true;
end
if nargin<4
    ignorecase=false;
end
if ischar(char_cell2)
    char_cell2={char_cell2};
end

if ignorecase
    cmp=@strcmpi;
else
    cmp=@strcmp;
end
if opt
    try
        index=cellfun(@(x) find(cmp(char_cell1(:),x)),char_cell2(:),'UniformOutput',true);
    catch
        index=cellfun(@(x) find(cmp(char_cell1(:),x)),char_cell2(:),'UniformOutput',false);
%         nonindex=cellfun(@(x) isempty(x),index(:),'UniformOutput',true);
%         index(nonindex)={0};
        index=cell2mat(index);
    end
else
    index=cellfun(@(x) find(cmp(char_cell1(:),x)),char_cell2(:),'UniformOutput',opt);
end
end