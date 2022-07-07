function T=initialize_table_var(T,varname,type,content)
%%
%     Author: Ying Wang, Min Li
%     Create Time: 2021
%     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
%     Joint China-Cuba LAB, UESTC
 
len_table=size(T,1);

if ischar(varname)
    varname={varname};
end
num_var=length(varname);
if isempty(type)
    type=class(content);
    if numel(content)==1
        type=repmat(type,[num_var,1]);
    end
end
if ischar(type)
    type={type};
end
if length(type)==1
    type=repmat(type,[num_var,1]);
end





for i=1:num_var
    %     T.(varName{i})=get_empty(type{i},[len_table,0]);
    if nargin<4||isempty(content)
        switch type{i}
            case {'double','single'}
                T.(varname{i})=NaN(len_table,1,type{i});
            case {'logical'}
                T.(varname{i})=false(len_table,1,type{i});
            case {'cell'}
                T.(varname{i})=cell(len_table,1);
            case {'char'}
                T.(varname{i})=cell(len_table,1);
            case {'string'}
                T.(varname{i})=cell(len_table,1);
            otherwise
                error('please add type support above')
        end
    else
        %         if ischar(content)
        %             content={content};
        %         end
        %         T.(varName{i})=repmat(content(i),len_table,1);
        switch type{i}
            case {'double','single'}
                if isscalar(content)
                    T.(varname{i})=content*ones(len_table,1,type{i});
                else
                    T.(varname{i})=content(i)*ones(len_table,1,type{i});
                end
            case {'logical'}
                if isscalar(content)
                    T.(varname{i})=content*true(len_table,1,type{i});
                else
                    T.(varname{i})=content(i)*true(len_table,1,type{i});
                end
            case {'cell'}
                if numel(content)==1
                    T.(varname{i})(:)=content;
                else
                    T.(varname{i})(:)=content{i};
                end
            case {'char'}
                if ischar(content)
                    T.(varname{i})(:)={content};
                else
                    T.(varname{i})(:)=content(i);
                end
            case {'string'}
                if isstring(content)
                    T.(varname{i})(:)={content};
                else
                    T.(varname{i})(:)=content(i);
                end
            otherwise
                error('please add type support above')
        end
    end
end




