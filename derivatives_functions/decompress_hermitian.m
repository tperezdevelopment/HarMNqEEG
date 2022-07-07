function [MatH] = decompress_hermitian(MatC)
%     Original code Author: Sc.D. Jorge F. Bosch-Bayard. Montreal Neurological Institute
%     Modified Tool Author: Eng. Tania Perez Ramirez <tperezdevelopment@gmail.com>. Cuban Center for Neurosciences
%     Copyright(c): 2022 Jorge F. Bosch-Bayard <oldgandalf@gmail.com>

[nr, nc, nf] = size(MatC);

if nr ~= nc    
    error('Error: The matrix is not in the compressed hermitian format. Pls, report to the providers');
end
MatH = zeros(nr,nr, nf);
for k=1:nf
    M = MatC(:,:,k);
    Mu = triu(M);
    Ml = tril(M,-1);
%     il = find(Ml);
    Mu = Mu + 1i*Ml';
    Mu = Mu + triu(Mu,1)'; %since Mu is already complex the transpose is also conjugate
    MatH(:,:,k) = Mu;
end
