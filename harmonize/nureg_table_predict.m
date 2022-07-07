function [T,regs]=nureg_table_predict(T,condition,factor_mu,factor_sigma,resp,opt,regs)
 %%
 %     Author: Ying Wang, Min Li
 %     Create Time: 2021
 %     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
 %     Joint China-Cuba LAB, UESTC
 

%%
num_resp=length(resp);
if ~isfield(opt,'resp_mu')
    opt.resp_mu=append('mu',resp);
end
if ~isfield(opt,'resp_eps')
    opt.resp_eps=append('eps',resp);
end
if ~isfield(opt,'resp_sigma')
    opt.resp_sigma=append('sigma',resp);
end
if ~isfield(opt,'resp_musigma')
    opt.resp_musigma=append('musigma',resp);
end
if ~isfield(opt,'resp_z')
    opt.resp_z=append('z',resp);
end

if ~isfield(opt,'calc_eps')
    opt.calc_eps=false;
end
if ~isfield(opt,'calc_sigma')
    opt.calc_sigma=false;
end
if ~isfield(opt,'calc_musigma')
    opt.calc_musigma=false;
end
if ~isfield(opt,'calc_z')
    opt.calc_z=false;
end
if ~isfield(opt,'global_h')
    opt.global_h=false;
end


%%
[subtable]=get_subtable(T,condition,[resp(:);factor_mu(:);factor_sigma(:)]);
%%
if ischar(factor_mu)
    factor_mu={factor_mu};
end
if  ~isempty(factor_sigma) && ischar(factor_sigma)
    factor_sigma={factor_sigma};
end


dx=length(factor_mu);
%% get data
if ~isempty(factor_mu)
    x_mu=zeros(size(subtable,1),dx);
    for ix=1:dx
        x_mu(:,ix) = table2array(get_subtable(subtable,[],factor_mu(ix)));
    end
else
    x_mu=[];
end
if ~isempty(factor_sigma)
    x_sigma=zeros(size(subtable,1),dx);
    for ix=1:dx
        x_sigma(:,ix) = table2array(get_subtable(subtable,[],factor_sigma(ix)));
    end
else
    x_sigma=[];
end
y=table2array(get_subtable(subtable,[],resp));% y=gpuArray(table2array(get_subtable(subtable,[],resp)));

%% calculate
% mu
yhat=predict_griddedInterpolant_complex(regs(1).fpp_yhat,x_mu,opt);

% residual
yeps=[];
if opt.calc_eps || opt.calc_sigma|| opt.calc_musigma || opt.calc_z
    if opt.y_keep_all && ismatrix(y) && num_resp>1
        yeps=permute(y,[1,3,2])-yhat;
    else
        yeps=y-yhat;
    end
end

% variance
if opt.calc_sigma|| opt.calc_musigma || opt.calc_z
    ysigma=real(yeps).^2+1j*(imag(yeps)).^2;
end

% mean of variance
if opt.calc_musigma || opt.calc_z
    opt.y_type_out='variance';
    ymusigma=predict_griddedInterpolant_complex(regs(2).fpp_yhat,x_sigma,opt,regs(2).d);
end
if any(real(ymusigma(:))<0)||any(imag(ymusigma(:))<0)
    error('ymusigma may not smooth well')
end
% fisher's z score
if opt.calc_z
    if ~opt.y_keep_all
        yz=real(yeps)./sqrt(real(ymusigma))+...
            1j*(opt.sep_complex~=2).*imag(yeps)./(sqrt(imag(ymusigma))+eps);
    else
        yz=real(yeps)./sqrt(real(ymusigma))+...
            1j*permute((opt.sep_complex~=2),[1,3,2]).*imag(yeps)./(sqrt(imag(ymusigma))+eps);
    end
end


%% save to the table

T=asnarray2table(T,condition,opt.resp_mu,yhat);
if opt.calc_eps
    T=asnarray2table(T,condition,opt.resp_eps,yeps);
end
if opt.calc_sigma
    T=asnarray2table(T,condition,opt.resp_sigma,ysigma);
end
if opt.calc_musigma
    T=asnarray2table(T,condition,opt.resp_musigma,ymusigma);
end
if opt.calc_z
    T=asnarray2table(T,condition,opt.resp_z,yz);
end


end






















