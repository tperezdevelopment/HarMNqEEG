function T=clone_table_var(T,resp1,resp2)
 %%
 %     Author: Ying Wang, Min Li
 %     Create Time: 2021
 %     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
 %     Joint China-Cuba LAB, UESTC
 

if ischar(resp1)
    resp1={resp1};
end
if ischar(resp2)
    resp2={resp2};
end

num_resp1=length(resp1);
num_resp2=length(resp2);
if num_resp1==1
    resp1=repmat(resp1,[num_resp2,1]);
end
if num_resp2==1
    resp2=repmat(resp2,[num_resp1,1]);
end

for i=1:num_resp1
    T.(resp1{i})=T.(resp2{i});
end

end