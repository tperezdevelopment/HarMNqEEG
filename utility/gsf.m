function [datat, factor] = gsf( data )
%scale by the Global Scale Factor
% data: the cross-spectral matrix of nd xnd x nf (nd: number of electrodes; nf: number of frequencies)
%%
%     Author:Bosch-Bayard
%     Create Time: 2021
 
[nd, nd,nfrec] = size(data);

sumd=0;
nfs = 0;
for w=1:nfrec
    tmp = data(:,:,w);
    if sum(tmp(:)) ~= 0
        nfs = nfs+1;
        tt = real(diag(tmp));
        ind = find(tt > 0);
        sumd=sumd+sum(log(tt(ind)));
    end
end
factor=exp(sumd./(nfs*nd));
datat=data./factor;
