function [out,refM]=vecRieMap(M,refM,isvec)
%%
%     Author: Ying Wang, Min Li
%     Create Time: 2021
%     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
%     Joint China-Cuba LAB, UESTC
 
if nargin<3|| isempty(isvec)
    isvec=true;
end
MM=num2cell(M,[1,2]);
if nargin<2 || isempty(refM)
    [refM]=karcher(MM{1:end});  % (D.A.Bini and B.Iannazzo,2013)
end
mapM=nan(size(M));
for i=1:size(M,3)
    mapM(:,:,i)=logm((refM^-0.5)*M(:,:,i)*(refM^-0.5));
end
%% vech
if isvec
    idmat=repmat(eye(size(M,1,2)),[1,1,size(M,3)]);
    mapM(~idmat)=mapM(~idmat).*sqrt(2);
    vecmapM=mat2tril(mapM);
    out=vecmapM;
else
    out=mapM;
end
end