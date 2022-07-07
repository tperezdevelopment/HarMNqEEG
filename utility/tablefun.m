function T=tablefun(func,T,varname,condition,varargin)
%%
%     Author: Ying Wang, Min Li
%     Create Time: 2021
%     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
%     Joint China-Cuba LAB, UESTC
 
% A = table([0.71;-2.05;-0.35;-0.82;1.57],[0.23;0.12;-0.18;0.23;0.41]);
% T = tablefun(@(x,y) x-y,A,'result',[],'Var1','Var2')
num_var=numel(varargin);
item=cell(num_var,1);
for ivar=1:num_var
    if ischar(varargin{ivar})
        item{ivar}=varargin(ivar);
    else
        item{ivar}=varargin{ivar};
    end
end
num_item=cellfun(@(x) numel(x), item);
nummax_item=max(num_item);
C=cell(num_var,1);
[~,idx_raw]=get_subtable(T,condition);



for ivar=1:num_var
    C{ivar}=table2array(get_subtable(T,condition,item{ivar}));
end
num_col=cellfun(@(x) size(x,2), C);

if ischar(varname)
    varname={varname};
end
num_varname=numel(varname);
if num_varname<nummax_item
    error('number of varname for output should equals to the input item number')
end


if  prod(num_col==nummax_item)
%     type=cellfun(@(x) class(x), C, 'UniformOutput',false);
    type=class(C{1});
    T=initialize_table_var(T,varname,type);
    idx_var=find_char(T.Properties.VariableNames,varname);
    y=func(C{:});
    if size(y,1)==1 && size(y,1)~=length(idx_raw)% broadcast 1 row
        y=repmat(y,[length(idx_raw),1]);
    end
    if ~isempty(varname)
        T(idx_raw,idx_var)=array2table(y,'VariableNames',varname);
    else
        T(idx_raw,idx_var)=array2table(y);
    end
else
    
    
    for ivar=1:num_var
        %         if num_item(ivar)==1 && num_item(ivar)<nummax_item
        %             item{ivar}=repmat(item{ivar},nummax_item,1);
        %         else
        %             error('not able to broadcast number of item not equal to 1')
        %         end
        if num_item(ivar)~=1 && num_item(ivar)<nummax_item
            error('not able to broadcast number of item not equal to 1')
        end
    end
    for iitem=1:nummax_item
        %         for ivar=1:num_var
        %             C{ivar}=table2array(get_subtable(T,condition,item{ivar}));
        %         end
        for ivar=1:num_var
            if num_item(ivar)>1
                C{ivar}=T.(item{ivar}{iitem});
            else
                C{ivar}=T.(item{ivar}{1});
            end
        end
        %                 T=asnarray2table(T,condition,varname{iitem},func(C{:}));
        y=func(C{:});
        if find_char(T.Properties.VariableNames,varname{iitem})
            if size(y,2)>length(T.(varname{iitem})(1,:))
                T.(varname{iitem})=[];
            end
        end
        if size(y,1)==1 && size(y,1)~=length(idx_raw)% broadcast 1 row
            y=repmat(y,[length(idx_raw),1]);
        end
        T.(varname{iitem})(idx_raw,:)=y;
    end
end








% num_var=length(varargin)/2;
% C=cell(num_var,1);
% for ivar=1:num_var
%     condition=varargin{(ivar-1)*2+1};
%     item=varargin{(ivar-1)*2+2};
%     C{ivar}=table2array(get_subtable(T,condition,item));
% end
% if ischar(varname)
%     varname={varname};
% end
% [~,idx_raw]=get_subtable(T,condition,item);
% type=cellfun(@(x) class(x), C, 'UniformOutput',false);
% T=initialize_table_var(T,varname,type);
% idx_var=find_char(T.Properties.VariableNames,varname);
% if ~isempty(varname)
%     T(idx_raw,idx_var)=array2table(func(C{:}),'VariableNames',varname);
% else
%     T(idx_raw,idx_var)=array2table(func(C{:}));
% end



end
% A = cellfun(@(x) x(1:3),C,'UniformOutput',false)
%
%
% for iresp=1:mnhs.num_resp
%         idx_resp     = find_char(mnhs.T.Properties.VariableNames,mnhs.resp{iresp});
%         idx_resp_mug = find_char(mnhs.T.Properties.VariableNames,mnhs.resp_mug{iresp});
%         idx_resp_resg  = find_char(mnhs.T.Properties.VariableNames,mnhs.resp_resg{iresp});
%         mnhs.T(:,idx_resp_resg)= array2table(table2array(mnhs.T(:,idx_resp))-table2array(mnhs.T(:,idx_resp_mug)));
%     end