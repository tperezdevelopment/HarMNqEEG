function [yhat]=predict_griddedInterpolant_complex(fpp,x,opt,d)
%%
%     Author: Ying Wang, Min Li
%     Create Time: 2021
%     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
%     Joint China-Cuba LAB, UESTC
 
dx=size(x,2);
dy=length(opt.sep_complex);
dy2=length(opt.sep_complex)+length(opt.idcomplex);
if isfield(opt,'y_type_out') && strcmp(opt.y_type_out,'variance')
    fpp.Values=log(fpp.Values.*reshape(d,[ones(1,dx),dy2]));
end



[yhat]=predict_griddedInterpolant(fpp,x);
if ismatrix(yhat) && ~isempty(opt.inherit_bandwidth) && opt.inherit_bandwidth==1
    yhat=permute(yhat,[1,3,2]);
end
if isfield(opt,'y_type_out') && strcmp(opt.y_type_out,'variance')
    yhat=exp(yhat)./d;
end





if ndims(yhat)==3
    dh=size(yhat,2);
else
    dh=1;
end

sz=size(yhat);

%%
if isfield(opt,'inherit_bandwidth')&& ~isempty(opt.inherit_bandwidth) && size(opt.inherit_bandwidth,1)==dh
    
    yhat=reshape(yhat,sz(1),numel(opt.inherit_bandwidth),sz(3));
    yhat=yhat(:,opt.inherit_bandwidth(:),:);
elseif  isfield(opt,'inherit_bandwidth')&& ~isempty(opt.inherit_bandwidth) && size(opt.inherit_bandwidth,1)~=dh
    yhat=reshape(yhat,sz(1),[]);
end
%%
dimy_output=ndims(yhat);
if dimy_output==2
    yhat(:,opt.idcomplex)=yhat(:,opt.idcomplex)+1j*yhat(:,dy+[1:length(opt.idcomplex)]);
    yhat(:,dy+[1:length(opt.idcomplex)])=[];
else
    yhat(:,:,opt.idcomplex)=yhat(:,:,opt.idcomplex)+1j*yhat(:,:,dy+(1:length(opt.idcomplex)));
    yhat(:,:,dy+(1:length(opt.idcomplex)))=[];
end

end