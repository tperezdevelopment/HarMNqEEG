function mnhs=mnh_zmap_predict(mnhs)
 %%
 %     Author: Ying Wang, Min Li
 %     Create Time: 2021
 %     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
 %     Joint China-Cuba LAB, UESTC
 
%% 1. use norm to get harmonized zscore
disp('[mnh_harmo]')
mnhs=mnh_harmo_predict(mnhs);
%% 2. get harmonized norms of new data
% not necessary

end




