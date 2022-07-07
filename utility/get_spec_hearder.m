function [logmS_head,idx]=get_spec_hearder(opt,respType,num_channel,k,stand_col)
% stand_col={'Fp1'    'Fp2'    'F3'    'F4'    'C3'    'C4'    'P3'    'P4'
% 'O1'    'O2'    'F7'    'F8'    'T3'    'T4'    'T5'    'T6'    'Fz'    'Cz'    'Pz'}
%%
%     Author: Ying Wang, Min Li
%     Create Time: 2021
%     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
%     Joint China-Cuba LAB, UESTC
 

if nargin<4 ||isempty(k)
    k=0;% after average reference
end
if nargin<3 ||isempty(num_channel)
    num_channel=18;% after average reference
end
if nargin<2 ||isempty(respType)
    respType='';
end
if nargin<1 ||isempty(opt)
    opt='tril';
end
if nargin<5 ||isempty(stand_col)
    stand_col=cellfun(@(x) num2str(x), num2cell((1:num_channel)'), 'UniformOutput', false);
end
stand_col=stand_col(:);
voxel_name=append(stand_col,'_',stand_col');
switch opt
    case{'','tril','TRIL'}
        [voxel_name,idx]=mat2tril(voxel_name,k);
        num_voxel=numel(voxel_name);
    case {'diag'}
        idx=logical(eye(num_channel));
        voxel_name=voxel_name(idx);
        num_voxel=numel(voxel_name);
    case{'all'}
        num_voxel=numel(voxel_name);
        idx=true(num_channel,num_channel);
end
logmS_head=cell(num_voxel,1);

for i=1:num_voxel
    logmS_head{i}=[respType,voxel_name{i}];
end

end
