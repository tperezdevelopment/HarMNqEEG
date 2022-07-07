function [y,xgrid]=predict_griddedInterpolant(fpp,x,N,iValue)
%%
%     Author: Ying Wang, Min Li
%     Create Time: 2021
%     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
%     Joint China-Cuba LAB, UESTC
 
if nargin<2 || isempty(x)
    x=fpp.GridVectors;
end

[~,dx]=size(x);


sz=size(fpp.Values);
dim_value=ndims(fpp.Values);
ndcolon(1:dx) = {':'};
if nargin<4 || isempty(iValue)
    iValue=0;
end
if dim_value>dx && sz(end)>1 && iValue
    fpp.Values=fpp.Values(ndcolon{:},iValue);
end


if iscell(x)  && nargin>2 && ~isempty(N)  
    xgrid=get_ndgrid_scatter(x,'cell',N);
    glist=get_ndgrid_scatter(x,'list',N);
    glist=mat2cell(glist,size(glist,1),ones(1,dx));
elseif iscell(x)  && (nargin<3 || isempty(N))  
    glist=get_ndgrid(x,'cell');
    xgrid=glist;
else
    glist=mat2cell(x,size(x,1),ones(1,dx));
end


y=fpp(glist{:});
if nargin>2 && ~isempty(N) 
    if dx==1
        y=reshape(y,N,1);
    else
        y=reshape(y,N,N,1);
    end
end
end