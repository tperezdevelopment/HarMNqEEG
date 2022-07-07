function mnhs=mnh_create_predict(mnhs)
%%
 %     Author: Ying Wang, Min Li
 %     Create Time: 2021
 %     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
 %     Joint China-Cuba LAB, UESTC

mnhs.mnhfun=@mnh_zmap_predict;
%read table for new DPs
mnhs_test=mnh_create(mnhs);
mnhs.Ttest=mnhs_test.T;
end