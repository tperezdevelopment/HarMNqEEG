function [MVecS] = compress_symmetric(mat_S)
%     Original code Author: Ying Wang, Min Li
%     Modified Tool Author: Eng. Tania Perez Ramirez <tperezdevelopment@gmail.com>. Cuban Center for Neurosciences
%     Copyright(c): 2022 Jorge F. Bosch-Bayard <oldgandalf@gmail.com>

[nr, nc, nf] = size(mat_S);

if nr ~= nc
    error('The matrix is not symmetric');
end
ne = (nr+1)*nr./2;
MVecS = zeros(ne, nf);
for k=1:nf
    VecS=triu(mat_S(:,:,k));
    if ~isequal(VecS, tril(mat_S(:,:,k))')
        if nr ~= nc
          error('The matrix is not symmetric'); 
        end
    end
    MVecS(:,k) = VecS(find(VecS));
end

