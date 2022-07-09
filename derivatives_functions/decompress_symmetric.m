function [MatS] = decompress_symmetric(MVecS, nr)
%     Original code Author: Sc.D. Jorge F. Bosch-Bayard. Montreal Neurological Institute
%     Modified Tool Author: Eng. Tania Perez Ramirez <tperezdevelopment@gmail.com>. Cuban Center for Neurosciences
%     Copyright(c): 2022 Jorge F. Bosch-Bayard <oldgandalf@gmail.com>



[ne, nf] = size(MVecS);

% a=0.5; b = 0.5; c = -ne;
% x1 = (-b + sqrt(b.^2 - 4 *a*c))./(2*a);
% x2 = (-b - sqrt(b.^2 - 4 *a*c))./(2*a);
% if x1 > 0, nr = x1; elseif x2 > 0, nr = x2; else nr = 0; end
% if (nr - floor(nr)) ~= 0, %error, is not an integer number
nec = (nr+1)*nr./2;
if ne ~= nec %#ok<BDSCI> %error, is not an integer number
    error('Matrix is not in the corect compacted format for symmetric matrices'); 
end
MatS = zeros(nr, nr, nf);
m = ones(nr, nr);
indU = find(triu(m));
for k=1:nf
    m = zeros(nr, nr);
    m(indU) = MVecS(:,k); %#ok<FNDSB> 
    m = m + triu(m,1)';
    MatS(:,:,k) = m;
end

