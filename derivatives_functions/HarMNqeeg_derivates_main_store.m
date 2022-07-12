function [jsonFile] = HarMNqeeg_derivates_main_store(func,derivatives_output_folder_each_subject, data_code, varargin)

%% init a few manually attributes
h5_filename = ['HarMNqeeg_derivatives_' data_code '.h5'];
perc_compres = 7; 

[jsonFile] = func([derivatives_output_folder_each_subject filesep h5_filename],perc_compres, varargin{:});

end

