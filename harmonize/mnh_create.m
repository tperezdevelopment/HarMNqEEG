function mnhs=mnh_create(mnhs)
 %%
 %     Author: Ying Wang, Min Li
 %     Create Time: 2021
 %     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
 %     Joint China-Cuba LAB, UESTC
 
rng(1)
%% initialize mnh structure information
if ~isfield(mnhs,'mnhfun')
    mnhs.mnhfun=@mnh_zmap;
end
if ~isfield(mnhs,'tag')
    st = dbstack;
    mnhs.tag=st(2).name;
end
if ~isfield(mnhs,'batch')
    mnhs.batch={'study'};
end
if ~isfield(mnhs,'reRefBatch')
    mnhs.reRefBatch=[];
end
if ~isfield(mnhs,'respType')
    if isfield(mnhs,'resp')&& ~isempty(mnhs.resp)
        mnhs.respType=sep_spec_hearder(mnhs.resp{1});
    else
        mnhs.resp='riemlogm';
    end
end
if ischar(mnhs.respType)
    mnhs.respType={mnhs.respType};
end
if ~strcmp(mnhs.respType{1},'log')
    resp=get_spec_hearder([],mnhs.respType{1});
else
    resp=get_spec_hearder('diag',mnhs.respType{1});
end
%% assign all necessary information
inform={'name','country','device','study','sex','disease'};%,'datasetName'
factor={'freq','age'};



%% deal with complex cross part
mnhs.parts={@real,@imag};
mnhs.num_resp=size(resp,1);

%% compact output
%delete y(resp) mu eps sigma musigma z, only leave ystar mnhs.opt.compact=true;
mnhs.opt.compact.y=false;
mnhs.opt.compact.mu=false;
mnhs.opt.compact.eps=false;
mnhs.opt.compact.sigma=false;
mnhs.opt.compact.musigma=false;
mnhs.opt.compact.z=true;
mnhs.opt.compact.ystar=true;
%% define how many level of model
mnhs.level(find_char(mnhs.level,'batch'))=mnhs.batch;
level=mnhs.level;
num_level=length(level);
%% read data
if find_char(level,'global')
    idglobal=find_char(level,'global');
    levelraw=mnhs.level;
    level(idglobal)=[];
end
header2import=cat(1,inform(:),level(:),factor(:),resp(:),mnhs.batch(:));

opts = detectImportOptions(mnhs.path_table);
if isempty(find_char(opts.SelectedVariableNames,'disease'))
    iddisease=find_char(header2import,'disease');
    header2import(iddisease)=[];
end
opts.SelectedVariableNames = header2import ;
mnhs.T=readtable(mnhs.path_table,opts);

%%
if ~isempty(mnhs.reRefBatch)
    disp(['use ',mnhs.reRefBatch{:,1},'as the reference of ',mnhs.reRefBatch{:,2},', replace information in T for calculation' ])
    % only support one batch model yet
    mnhs.T=asnarray2table(mnhs.T,{mnhs.batch{1},mnhs.reRefBatch{:,1}},'orignalBatch',mnhs.reRefBatch(:,1));
    mnhs.T=asnarray2table(mnhs.T,{mnhs.batch{1},mnhs.reRefBatch{:,1}},mnhs.batch,mnhs.reRefBatch(:,2));
end


if idglobal
    level=levelraw;
    mnhs.T= initialize_table_var(mnhs.T,'global',[],{'used'});
end
if exist('iddisease','var') && iddisease
    mnhs.T= initialize_table_var(mnhs.T,'disease',[],{''});
end

if max(mnhs.T.age)>2
    mnhs.T.ageRaw=mnhs.T.age;
    mnhs.T.age=log10(mnhs.T.age);
end

%% save information
mnhs.inform=inform;
mnhs.factor=factor;
mnhs.resp=resp;
mnhs.num_level=num_level;
mnhs.num_freq=47;
mnhs.resp_ystar=append('ystar',resp);

mnhs.batchCat=cell(mnhs.num_level,1);
mnhs.num_batch=zeros(mnhs.num_level,1);
for i_batch=1:mnhs.num_batch
    mnhs.batchCat{i_batch}=unique(mnhs.T.(level{i_batch}));
    mnhs.num_batch(i_batch)=numel(mnhs.batchCat{i_batch});
end

end








