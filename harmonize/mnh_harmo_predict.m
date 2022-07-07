function mnhs=mnh_harmo_predict(mnhs)
 %%
 %     Author: Ying Wang, Min Li
 %     Create Time: 2021
 %     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
 %     Joint China-Cuba LAB, UESTC
 
%% harmonization
opt=mnhs.opt;
opt.compact.eps=false;
opt.compact.musigma=false;
opt.compact.sigma=false;
[mnhs.Ttest]=tnureg_zmap_predict(mnhs.Ttest,mnhs.resp,mnhs.tregs,opt);



end









