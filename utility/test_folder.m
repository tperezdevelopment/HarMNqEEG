function test_folder(name)
%%
%     Author: Ying Wang, Min Li
%     Create Time: 2021
%     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
%     Joint China-Cuba LAB, UESTC
%     Modified by tperezdevelopment

[~, ~, e]=fileparts(name);


if isempty(e)
    if exist(name,'dir')
        %% diary off for remove
        diary off;
        rmdir(name, 's');
        pause(0.50) %in seconds
    end
    mkdir(name);
else
    if  exist(name,'file')
        %% diary off for remove
        diary off;
        delete(filetxt);
        pause(0.50) %in seconds
    end
    [p, ~, ~]=fileparts(name);
    if ~exist(p,'dir')
        mkdir(p);
    end
    %% From Leadfield ToolBox
    f = fopen( name, 'w' );
    fclose(f);
end
end









