%% Calibrate Signal
% Determine wether you want to calibrate the signals. If this checkbox is
% on, all loaded files will be calibrated.

%% Notes
%
% * if Calibrate Signal is ON, either a .cal8 file must be specified or at
% least one file number for calibration must be given. In the latter case,
% a .cal8 file is made of the specified file(s) and those files are used to
% create .cal8 file.
% * the calibration itself takes place in the ioiReadAC2.m file. There one
% finds something similar to these lines:
%
%   cal=ioReadCal8.m;
%   if isfield(options, 'scalemap') % if there is a .cal8 file
%       for i=1:numleads
%           for j=1:numframes
%               cal = options.scalemap(i,gaininfo(i,j)+1);
%               potval(i,j) = potval(i,j)*cal; %potvals are the measured potential values stored in the ts structure
%           end
%       end      
%   end
%
% * the calibration file is created from the specified .ac2 files using the
% ioWriteCal8.m file.