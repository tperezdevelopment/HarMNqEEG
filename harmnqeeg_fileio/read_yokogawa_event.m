function [event] = read_yokogawa_event(filename, varargin)

% READ_YOKOGAWA_EVENT reads event information from continuous,
% epoched or averaged MEG data that has been generated by the Yokogawa
% MEG system and software and allows those events to be used in
% combination with FieldTrip.
%
% Use as
%   [event] = read_yokogawa_event(filename)
%
% See also READ_YOKOGAWA_HEADER, READ_YOKOGAWA_DATA

% Copyright (C) 2005, Robert Oostenveld
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

event   = [];
handles = definehandles;

% get the options, the default is set below
chanindx    = ft_getopt(varargin, 'chanindx');
threshold   = ft_getopt(varargin, 'threshold');
detectflank = ft_getopt(varargin, 'detectflank');
combinebinary = ft_getopt(varargin, 'combinebinary', false);
trigshift   = ft_getopt(varargin, 'trigshift');
if isempty(combinebinary)
  combinebinary = false;
end

% ensure that the required toolbox is on the path
if ft_hastoolbox('yokogawa_meg_reader')
  % read the dataset header
  hdr = read_yokogawa_header_new(filename);
  ch_info = hdr.orig.channel_info.channel;
  type = [ch_info.type];

  % determine the trigger channels (if not specified by the user)
  if isempty(chanindx)
    chanindx = find(type==handles.TriggerChannel);
  end

  % Use the MEG Reader documentation if more detailed support is required.
  if hdr.orig.acq_type==handles.AcqTypeEvokedRaw
    % read the trigger id from all trials
    event = getYkgwHdrEvent(filename);
    % use the standard FieldTrip header for trial events
    % make an event for each trial as defined in the header
    for i=1:hdr.nTrials
      event(end+1).type     = 'trial';
      event(end  ).sample   = (i-1)*hdr.nSamples + 1;
      event(end  ).offset   = -hdr.nSamplesPre;
      event(end  ).duration =  hdr.nSamples;
      if ~isempty(value)
        event(end  ).value    =  event(i).code;
      end
    end

  % Use the MEG Reader documentation if more detailed support is required.
  elseif hdr.orig.acq_type==handles.AcqTypeEvokedAve
    % make an event for the average
    event(1).type     = 'average';
    event(1).sample   = 1;
    event(1).offset   = -hdr.nSamplesPre;
    event(1).duration =  hdr.nSamples;

  elseif hdr.orig.acq_type==handles.AcqTypeContinuousRaw
    % Events annotated by users during measurements
    bookmark_tmp = getYkgwHdrBookmark(filename);
    if ~isempty(bookmark_tmp)
      for i = 1:length(bookmark_tmp)
        event(end+1).sample = bookmark_tmp(i).sample_no + 1;
        event(end  ).type   =  'bookmarks';
        if ~isempty(bookmark_tmp(i).label)
          event(end  ).value = bookmark_tmp(i).label;
          %% 0 in default
        else
          event(end  ).value = 99;
        end
      end
    end
    clear bookmark_tmp;
  end

elseif ft_hastoolbox('yokogawa')

  % read the dataset header
  hdr = read_yokogawa_header(filename);

  % determine the trigger channels (if not specified by the user)
  if isempty(chanindx)
    chanindx = find(hdr.orig.channel_info(:,2)==handles.TriggerChannel);
  end

  if hdr.orig.acq_type==handles.AcqTypeEvokedRaw
    % read the trigger id from all trials
    fid   = fopen_or_error(filename, 'r');
    value = GetMeg160TriggerEventM(fid);
    fclose(fid);
    % use the standard FieldTrip header for trial events
    % make an event for each trial as defined in the header
    for i=1:hdr.nTrials
      event(end+1).type     = 'trial';
      event(end  ).sample   = (i-1)*hdr.nSamples + 1;
      event(end  ).offset   = -hdr.nSamplesPre;
      event(end  ).duration =  hdr.nSamples;
      if ~isempty(value)
        event(end  ).value    =  value(i);
      end
    end

  elseif hdr.orig.acq_type==handles.AcqTypeEvokedAve
    % make an event for the average
    event(1).type     = 'average';
    event(1).sample   = 1;
    event(1).offset   = -hdr.nSamplesPre;
    event(1).duration =  hdr.nSamples;

  elseif hdr.orig.acq_type==handles.AcqTypeContinuousRaw
    % the data structure does not contain events, but flank detection on the trigger channel might reveal them
    % this is done below
  end

else
  error('cannot determine whether the required Yokogawa toolbox is present');
end

% read the trigger channels and detect the flanks
if ~isempty(chanindx)
  trigger = read_trigger(filename, 'header', hdr, 'denoise', false, 'chanindx', chanindx, 'detectflank', detectflank, 'threshold', threshold, 'combinebinary', combinebinary, 'trigshift', trigshift);
  % combine the triggers and the other events
  event = appendstruct(event, trigger);
end

if isempty(event)
  warning('no triggers were detected, please specify the "trigindx" option');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this defines some usefull constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles = definehandles
handles.output = [];
handles.sqd_load_flag = false;
handles.mri_load_flag = false;
handles.NullChannel         = 0;
handles.MagnetoMeter        = 1;
handles.AxialGradioMeter    = 2;
handles.PlannerGradioMeter  = 3;
handles.RefferenceChannelMark = hex2dec('0100');
handles.RefferenceMagnetoMeter       = bitor( handles.RefferenceChannelMark, handles.MagnetoMeter );
handles.RefferenceAxialGradioMeter   = bitor( handles.RefferenceChannelMark, handles.AxialGradioMeter );
handles.RefferencePlannerGradioMeter = bitor( handles.RefferenceChannelMark, handles.PlannerGradioMeter );
handles.TriggerChannel      = -1;
handles.EegChannel          = -2;
handles.EcgChannel          = -3;
handles.EtcChannel          = -4;
handles.NonMegChannelNameLength = 32;
handles.DefaultMagnetometerSize       = (4.0/1000.0);       % Square of 4.0mm in length
handles.DefaultAxialGradioMeterSize   = (15.5/1000.0);      % Circle of 15.5mm in diameter
handles.DefaultPlannerGradioMeterSize = (12.0/1000.0);      % Square of 12.0mm in length
handles.AcqTypeContinuousRaw = 1;
handles.AcqTypeEvokedAve     = 2;
handles.AcqTypeEvokedRaw     = 3;
handles.sqd = [];
handles.sqd.selected_start  = [];
handles.sqd.selected_end    = [];
handles.sqd.axialgradiometer_ch_no      = [];
handles.sqd.axialgradiometer_ch_info    = [];
handles.sqd.axialgradiometer_data       = [];
handles.sqd.plannergradiometer_ch_no    = [];
handles.sqd.plannergradiometer_ch_info  = [];
handles.sqd.plannergradiometer_data     = [];
handles.sqd.eegchannel_ch_no   = [];
handles.sqd.eegchannel_data    = [];
handles.sqd.nullchannel_ch_no   = [];
handles.sqd.nullchannel_data    = [];
handles.sqd.selected_time       = [];
handles.sqd.sample_rate         = [];
handles.sqd.sample_count        = [];
handles.sqd.pretrigger_length   = [];
handles.sqd.matching_info   = [];
handles.sqd.source_info     = [];
handles.sqd.mri_info        = [];
handles.mri                 = [];
