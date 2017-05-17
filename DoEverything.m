
function DoEverything()

%%%%%%%%%%%%%% Do not change this %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% leads to be evaluated for needles (ns), torso (ts) or sock (cs)
ns=[1:340];
cs=[341:587];
ts=[588:779];



%%%%%%%%%%%% choose parameters     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%files to be evaluated
calfile='/Users/anton/Documents/MATLAB/Matlab12/Tank_10_27_2014/Cal/calibration.cal8';
mapfile='/Users/anton/Documents/MATLAB/Matlab12/Tank_10_27_2014/geom/34needles_247sock_192torso_channels.mapping';
acq2file='/Users/anton/Documents/MATLAB/Matlab12/Tank_10_27_2014/ecg_raw_data/Run0005.ac2';

% choose the leads, that u want to process:
leadsToBeProcessed=ns;




%%%%%%%%%%%%%%%%%%  Do all the stuff %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in the ts structure
ts=AreadAC2(ac2file, mapfile, calfile, leadsToBeProcessed)


% do baseline correction
















