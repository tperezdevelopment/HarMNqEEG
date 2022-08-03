function test_folder(name, type)
%%
%     Author: Ying Wang, Min Li
%     Create Time: 2021
%     Copyright(c): 2020-2022 Ying Wang, yingwangrigel@gmail.com, Min Li, minli.231314@gmail.com
%     Joint China-Cuba LAB, UESTC
%     Modified by tperezdevelopment

%% name -----> the full path of the folder or file that will created
%% type -----> the type of the name that will be created. File of dir. If it is empty the default value is dir


if nargin<2 || isempty(type)
    type='dir';
end

switch type
    case 'dir'
        if exist(name,'dir')
            try
                rmdir(name, 's');
                pause(0.50) %in seconds
            catch

            end
        end
        mkdir(name);

    case 'type'
        if  exist(name,'file')
            try
                delete(name);
                pause(0.50) %in seconds
            catch

            end
        end
        %% From Leadfield ToolBox
        f = fopen( name, 'w' );
        fclose(f);
end


end


