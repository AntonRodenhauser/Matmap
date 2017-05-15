
function TSindices=AreadAC2(ac2file, mapfile, calfile, window)
global TS
TSindices=ioReadTS(ac2file,mapfile, calfile);
%doesnt work if TSindices is an array atm
TS{TSindices}.potvals=TS{TSindices}.potvals(window,:);
TS{TSindices}.gain=TS{TSindices}.gain(window,:);
TS{TSindices}.leadinfo=TS{TSindices}.leadinfo(window,:);
TS{TSindices}.numleads=length(window);
