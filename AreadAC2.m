
function ts=AreadAC2(ac2file, mapfile, calfile, leads)
global TS
TSindices=ioReadTS(ac2file,mapfile, calfile);
%doesnt work if TSindices is an array atm
TS{TSindices}.potvals=TS{TSindices}.potvals(leads,:);
TS{TSindices}.gain=TS{TSindices}.gain(leads,:);
TS{TSindices}.leadinfo=TS{TSindices}.leadinfo(leads,:);
TS{TSindices}.numleads=length(leads);
ts=TS{TSindices};
