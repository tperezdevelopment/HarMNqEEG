function varargout = warning(varargin)

% warning prints a warning message on screen, depending on the verbosity
% settings of the calling high-level FieldTrip function. This function works
% similar to the standard WARNING function, but also features the "once" mode.
%
% Use as
%   warning(...)
% with arguments similar to fprintf, or
%   warning(msgId, ...)
% with arguments similar to warning.
%
% You can switch of all warning messages using
%   warning off
% or for specific ones using
%   warning off msgId
%
% To switch them back on, you would use 
%   warning on
% or for specific ones using
%   warning on msgId
% 
% Warning messages are only printed once per timeout period using
%   warning timeout 60
%   warning once
% or for specific ones using
%   warning once msgId
%
% You can see the most recent messages and identifier using
%   warning last
%
% You can query the current on/off/once state for all messages using
%   warning query
%
% See also error, warning, FT_NOTICE, fprintf, FT_DEBUG, ERROR, WARNING

% Copyright (C) 2012-2017, Robert Oostenveld, J?rn M. Horschig
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

if nargout
  [varargout{1:nargout}] = ft_notification(varargin{:});
elseif isequal(varargin, {'last'})
  % return an answer anyway
  varargout{1} = ft_notification(varargin{:});
else
  ft_notification(varargin{:});
end

