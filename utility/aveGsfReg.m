function [M]=aveGsfReg(M,steps,dF)
 %%
 %     Author: Ying Wang, Min Li
 %     Create Time: 2021
 %     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
 %     Joint China-Cuba LAB, UESTC
 

if nargin<3
    dF=[];
    if sum(find_char(steps,'reg'))
        error('reg needs dF')
    end
end


for i=1:length(steps)
    M=evalfunc(steps{i},M,dF);
end

end



function M=evalfunc(step,M,dF)
[~,~,Nf]=size(M);
switch step
    case 'ave'
        M=aveReference(M);
    case 'gsf'
        M=gsf(M);
    case 'reg'
            for i=1:Nf
                M(:,:,i)=regularizeHS(M(:,:,i), dF);
            end
    otherwise
        error('no match step')
end

end