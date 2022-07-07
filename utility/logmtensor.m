function vecmapM=logmtensor(M)
%%
%     Author: Ying Wang, Min Li
%     Create Time: 2021
%     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
%     Joint China-Cuba LAB, UESTC
 
NTrial = size(M,3);
N_elec = size(M,1);

mapM=zeros(N_elec,N_elec,NTrial);
for i=1:NTrial
    %Tn =  C^-0.5*RiemannLogMap(C,COV(:,:,i))*C^-0.5;
    mapM(:,:,i) = logm(M(:,:,i));
end

vecmapM=mat2tril(mapM);
end
