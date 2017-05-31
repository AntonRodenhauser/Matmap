function plott_stuff()





%%%%%%%%%%%%% some stuff that I often need %%%%%%%%%%%%%
calfile='/Users/anton/Documents/MATLAB/Matlab12/Tank_10_27_2014/Cal/calibration.cal8';
mapfile='/Users/anton/Documents/MATLAB/Matlab12/Tank_10_27_2014/geom/34needles_247sock_192torso_channels.mapping';
ac2file='/Users/anton/Documents/MATLAB/Matlab12/Tank_10_27_2014/ecg_raw_data/Run0009.ac2';

ns=[1:340];
cs=[341:587];
ts=[588:779];







%%%%%%%%%%%% plotting starts here %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% choose your ts to plot %%%%%%%%%%%

ts1=AreadAC2(ac2file, mapfile, calfile, ns);      %will be blue
ts2=DoBaseLineCorrection(ts1,[96, 340],1);        % will be red



% clear global TS
% global TS
% TS{1}=ts1;
% sigDeltaFoverF(1, [1:340])
% ts2=TS{1}





%%%%% plot them

X1=ts1.potvals(1,1:340);
X2=ts2.potvals(1,1:340);



figure()
plot(X1, 'b')
hold
plot(X2, 'r')

legend('1','2')





