function [opt, isdefault]= set_defaults(opt, varargin)
%[opt, isdefault]= set_default_param(opt, defopt)
%[opt, isdefault]= set_default_param(opt, field/value list)
%
% This functions fills in the given struct opt some new fields with
% default values, but only when these fields DO NOT exist before in opt.
% Existing fields are kept with their original values.
% There are two forms in which you can can specify the default values,
% (1) as struct, 
%   opt= set_defaults(opt, struct('color','g', 'linewidth',3));
%
% (2) as property/value list, e.g.,
%   opt= set_defaults(opt, 'color','g', 'linewidth',3);
%
% The second output argument isdefault is a struct with the same fields
% as the returned opt, where each field has a boolean value indicating
% whether or not the default value was inserted in opt for that field.
%
% The default values should be given for ALL VALID property names, i.e. the
% set of fields in 'opt' should be a subset of 'defopt' or the field/value
% list. A warning will be issued for all fields in 'opt' that are not present
% in 'defopt', thus possibly avoiding a silent setting of options that are
% not understood by the receiving functions. 
%
% $Id$
% 
% Copyright (C) Fraunhofer FIRST
% Authors: Frank Meinecke (meinecke@first.fhg.de)
%          Benjamin Blankertz (blanker@first.fhg.de)
%          Pavel Laskov (laskov@first.fhg.de)

if nargin > 2
    % we have NVPs in the defaults...
    names = varargin(1:2:end);
    values = varargin(2:2:end);
else
    % we have a struct
    names = fieldnames(varargin{1})';
    values = struct2cell(varargin{1})';
end

% append opt struct
names = [names,fieldnames(opt)'];
values = [values,struct2cell(opt)'];
    
% use only the last assignment for each name
[s,idx] = sort(names(:));
idx( strcmp(s((1:end-1)'),s((2:end)'))) = [];

% build output struct
opt = cell2struct(values(idx),names(idx),2);


