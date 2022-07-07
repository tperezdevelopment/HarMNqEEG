function T=tnureg_zmap_predict(T,y,tregs,opt)
 %%
 %     Author: Ying Wang, Min Li
 %     Create Time: 2021
 %     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
 %     Joint China-Cuba LAB, UESTC
 

if isstruct(tregs)
    tregs={tregs};
end
opt=set_defaults(opt,'standardize',false);
opt=set_defaults(opt,'unstandardize',false);
opt=set_defaults(opt,'maxibf',1);

dy=numel(y);
n=size(T,1);
%% standardize
if opt.standardize
    func=@(x) [mean(x,1);std(real(x),1)+1i*std(imag(x))];
    mu=func(reshape(table2array(get_subtable(T,[],y)),n,[],dy));
    stdy=mu(2,:,:);
    mu=mu(1,:,:);
    for i=1:dy
        T.(y{i})=T.(y{i})-mu(:,:,i);
        T.(y{i})=real(T.(y{i}))./real(stdy(:,:,i))+1i*imag(T.(y{i}))./imag(stdy(:,:,i));
    end
end
%% initialize resp to regress
num_level=size(tregs,1);
%% predict
for ibf=1:opt.maxibf
    for i=1:num_level
        disp(['runing level: ',num2str(i)])
        %% mu (and musigma)
        if i==1 && ibf==1
            T=clone_table_var(T,tregs{i,1}.resp,y);
        elseif i==1 && ibf>1
            if tregs{num_level,1}.opt.calc_z
                T=clone_table_var(T,tregs{i,1}.resp,tregs{num_level,1}.opt.resp_z);
            else
                T=clone_table_var(T,tregs{i,1}.resp,tregs{num_level,1}.opt.resp_eps);
            end
        else
            if tregs{i-1,1}.opt.calc_z
                T=clone_table_var(T,tregs{i,1}.resp,tregs{i-1,1}.opt.resp_z);
            else
                T=clone_table_var(T,tregs{i,1}.resp,tregs{i-1,1}.opt.resp_eps);
            end
        end
        [T]=tnureg_predict(T,tregs{i,1});
        
    end
end
%% check tregs
%% modified check_tregs function by tperezdevelopment
check_tregs_modified_by_tperezdevelopment(T,tregs);



%% compact to save memory

if opt.compact.y
    T=asnarray2table(T,[],y,[]);
end
if opt.compact.sigma
    for i=1:num_level
        T=asnarray2table(T,[],tregs{i,1}.opt.resp_sigma,[]);
    end
end
%% get ystar
ystar=append('ystar',y);

if tregs{num_level}.opt.calc_musigma
    T=clone_table_var(T,ystar,tregs{num_level,1}.opt.resp_z);
else
    T=clone_table_var(T,ystar,tregs{num_level,1}.opt.resp_eps);
end

for i=num_level:-1:1
    if tregs{i}.opt.calc_musigma
        if ~opt.isremove(i)
            func=@(mu,sigma,ystar) (real(mu)+real(sigma).*real(ystar))+...
                1i*(imag(mu)+imag(sigma).*imag(ystar));
            T = tablefun(func,T,ystar,[],...
                tregs{i}.opt.resp_mu,...
                tregs{i}.opt.resp_musigma,...
                ystar);
        end
    else
        if ~opt.isremove(i)
            func=@(mu,ystar) real(mu)+real(ystar)+...
                1i*(imag(mu)+imag(ystar));
            T = tablefun(func,T,ystar,[],...
                tregs{i}.opt.resp_mu,...
                ystar);
        end
    end
end

%% unstandardize for ystar
% for i=1:dy
%     T.(ystar{i})=T.(ystar{i})./sqrt(sigmay(:,:,i));
% end
if opt.unstandardize
    for i=1:dy
        T.(ystar{i})=real(T.(ystar{i})).*real(stdy(:,:,i))+1i*imag(T.(ystar{i})).*imag(stdy(:,:,i));
        T.(ystar{i})=T.(ystar{i})+mu(:,:,i);
    end
end
%% compact to save memory
if opt.compact.mu
    for i=1:num_level
        T=asnarray2table(T,[],tregs{i,1}.opt.resp_mu,[]);
    end
end

if opt.compact.eps
    for i=1:num_level
        T=asnarray2table(T,[],tregs{i,1}.opt.resp_eps,[]);
    end
end
if opt.compact.musigma
    for i=1:num_level
        T=asnarray2table(T,[],tregs{i,1}.opt.resp_musigma,[]);
    end
end

if opt.compact.z
    for i=1:num_level
        T=asnarray2table(T,[],tregs{i,1}.opt.resp_z,[]);
    end
end
if opt.compact.ystar
    for i=1:num_level
        T=asnarray2table(T,[],ystar,[]);
    end
end

end