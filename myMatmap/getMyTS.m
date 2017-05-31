
function ts=getMyTS()
% returns a ts structure with all the parameters (from files, withBaseline etc) specified in the 'choose parameters here' section of this function
% this function messes with TS, but the result in TS is not reliable (as eg DoBaselineCorrection is applied, but this fkt does not change TS), 
% so only use this fkt to get ts, not change TS



%%%%%%%%%%%%%% Do not change this %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% leads to be evaluated for needles (ns), torso (ts) or sock (cs)
ns=[1:340];
cs=[341:587];
ts=[588:779];



%%%%%%%%%%%% choose parameters here  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%files to be evaluated
calfile='/Users/anton/Documents/MATLAB/Matlab12/Tank_10_27_2014/Cal/calibration.cal8';
mapfile='/Users/anton/Documents/MATLAB/Matlab12/Tank_10_27_2014/geom/34needles_247sock_192torso_channels.mapping';
ac2file='/Users/anton/Documents/MATLAB/Matlab12/Tank_10_27_2014/ecg_raw_data/Run0009.ac2';

% baseline correction parameters
blpts=[1 320]            % start and stop timeframe
blwin=5;                 %baselinewindow, used for calibration


%choose the leads that you want to be processed

leadsToBeProcessed=ns;






%%%%%%%%%%%%%%%%%%  Do all the stuff %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in the ts structure
ts=AreadAC2(ac2file, mapfile, calfile, leadsToBeProcessed);


% do baseline correction

ts=DoBaseLineCorrection(ts, blpts, blwin);





















