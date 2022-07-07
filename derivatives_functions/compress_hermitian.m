function [MatC] = compress_hermitian(mat_H)
%     Original code Author: Sc.D. Jorge F. Bosch-Bayard. Montreal Neurological Institute
%     Modified Tool Author: Eng. Tania Perez Ramirez <tperezdevelopment@gmail.com>. Cuban Center for Neurosciences
%     Copyright(c): 2022 Jorge F. Bosch-Bayard <oldgandalf@gmail.com>

[nr, nc, nf] = size(mat_H);
if nr ~= nc
    error('The matrix is not hermitian');
end
MatC = zeros(nr,nr, nf);
for k=1:nf
    M=mat_H(:,:,k);
    if ~isequal(triu(M), tril(M)')
        if nr ~= nc
            error('The matrix is not hermitian');
        end
    end
    MatC(:,:,k) = triu(real(M))-tril(imag(M));
end
end
