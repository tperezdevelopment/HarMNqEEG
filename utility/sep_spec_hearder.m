function [respType,label]=sep_spec_hearder(resp)
%%
%     Author: Ying Wang, Min Li
%     Create Time: 2021
%     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
%     Joint China-Cuba LAB, UESTC
 
% respType=get_resp_type('logs19_19')
% regexp('logs19_19','(\d{1,2}\_\d{1,2})','match')
if ischar(resp)
    resp={resp};
end
num_resp=numel(resp);
label=cell(num_resp,1);
pat=regexp(resp,'(\d{1,2}\_\d{1,2})','match');

respType= erase(resp{1},pat{1});
for i=1:num_resp
    label(i)=extract(resp{i},pat{i});
end

end