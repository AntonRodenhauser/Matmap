function balbliblub()

mapfile='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\einzelneTestfiles_Tank_10\34needles_247sock_192torso_channels.mapping';
calfile='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\einzelneTestfiles_Tank_10\calibration.cal8';
ac2file='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\einzelneTestfiles_Tank_10\Run0009.ac2';
global myts
timeframes=[500:1000];   % pick the timeframes that u also picked in the second window of matmap gui
lead=1;                  % pick the lead that you want to be plottet (for potvals only, signal is MRS)

ts=AreadAC2(ac2file, mapfile, calfile, myts.channels);
ts.potvals=ts.potvals(:,timeframes);


rawpotvals=ts.potvals;
rawSignal=getSIGNAL( rawpotvals );

blpts=round([ myts.selectedFids(1,1,1) myts.selectedFids(1,2,1)]*1000);
baselined_ts=DoBaseLineCorrection(ts, blpts, 5);
baselinedRawPotvals=baselined_ts.potvals;

baselinedSignal=getSIGNAL( baselinedRawPotvals );



figure()

subplot(2,2,1)
plot(rawpotvals(lead,:))
title('potvals no calibration')  %exect from calfile and mapfile
line([blpts(1),blpts(1)],[-10 10],'color','red')
line([blpts(2), blpts(2)], [-10 10],'color','red')



subplot(2,2,2)
plot(rawSignal)
title('Signal, no baseline')  % potvals MRS'ed, min substracted and scaled
line([blpts(1),blpts(1)],[0 1],'color','red')
line([blpts(2), blpts(2)], [0 1],'color','red')




subplot(2,2,3)
plot(baselinedRawPotvals(lead,:))
title('baselined Potvals')
line([blpts(1),blpts(1)],[-10 10],'color','red')
line([blpts(2), blpts(2)], [-10 10],'color','red')



subplot(2,2,4)
plot(baselinedSignal)
title('baselined signal')
line([blpts(1),blpts(1)],[0 1],'color','red')
line([blpts(2), blpts(2)], [0 1],'color','red')
































