function [mattril,onesind]=mat2tril(data,k)
% examp: 10*10*100, get lower triangle
% Yingwang 5/10/2020
%  ind= 0 is the main diagonal
%  ind > 0 is above the main diagonal
%  ind < 0 is below the main diagonal.
if nargin<2
    k=0;
end
[r,c,p]=size(data);
onesind=tril(true(r,c),k);

nn=sum(sum(onesind));
onesind=repmat(onesind,[1,1,p]);
% mattril=reshape(data(onesind~=0),[(r*c-r)/2,p]);
mattril=reshape(data(onesind),[nn,p]);
end


