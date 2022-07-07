function vars=get_handlevar(f)
% https://stackoverflow.com/questions/36682998/matlab-anonymous-function-list-arguments
% https://stackoverflow.com/users/670206/suever
anoninputs = @(f)strsplit(regexp(func2str(f), '(?<=^@\()[^\)]*', 'match', 'once'), ',');
vars=anoninputs(f);
end
