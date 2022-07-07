function [T]=tnureg_predict(T,tregs)
 %%
 %     Author: Ying Wang, Min Li
 %     Create Time: 2021
 %     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
 %     Joint China-Cuba LAB, UESTC
 

idx=find_char(unique(tregs.condition{2}),unique(T.(tregs.condition{1})));
num_cond=length(idx);
for icond=1:num_cond
    cond={tregs.condition{1},tregs.condition{2}{idx(icond)}};
    disp(['predict data [',cond{2},'] in [',cond{1},']'])
    T=nureg_table_predict(T,...
        cond,...
        tregs.factor_mu,...
        tregs.factor_sigma,...
        tregs.resp,...
        tregs.opt,...
        tregs.regs{idx(icond)});
end







end












