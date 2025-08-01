function ft_flush_event(filename, varargin)

% FT_FLUSH_EVENT removes all events from the event queue
%
% Use as
%   ft_flush_event(filename, ...)
%
% See also FT_FLUSH_HEADER, FT_FLUSH_DATA

% Copyright (C) 2007-2010 Robert Oostenveld
%
% This file is part of FieldTrip, see http://www.fieldtriptoolbox.org
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id$

% TODO implement filtering

% set the defaults
eventformat = ft_getopt(varargin, 'eventformat',  ft_filetype(filename));

switch eventformat
  case 'disp'
    % nothing to do

  case 'fcdc_buffer'
    [host, port] = filetype_check_uri(filename);
    buffer('flush_evt', [], host, port);

%   case 'fcdc_mysql'  %% Commented by tperezdevelopment
%     % open the database
%     [user, password, server, port] = filetype_check_uri(filename);
%     if ~isempty(port)
%       server = sprintf('%s:%d', server, port);
%     end
%     mysql('open', server, user, password);
%     % remove all previous event information
%     cmd = 'TRUNCATE TABLE fieldtrip.event';
%     mysql(cmd);
%     mysql('close');

  case 'matlab'
    if exist(filename, 'file')
      warning('deleting existing file ''%s''', filename);
      delete(filename);
    end

  otherwise
    error('unsupported data format');
end

