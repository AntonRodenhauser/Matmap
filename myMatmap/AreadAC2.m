
function ts=AreadAC2(ac2file, mapfile, calfile, leads)
% input:
%     strings with full path to a .ac2, .mapping and a .cal8 file.
%     leads: array with indices of all leads of the ts, that should be evaluated (something like [1:300]  )
% output:
%     -creates global TS und stores ts in it, ts is mapped with mapfile and calibrated with calfile, but nothing else has been done
%     - also returns the ts itself


global TS
TSindices=ioReadTS(ac2file,mapfile, calfile);
%doesnt work if TSindices is an array atm
TS{TSindices}.potvals=TS{TSindices}.potvals(leads,:);
TS{TSindices}.gain=TS{TSindices}.gain(leads,:);
TS{TSindices}.leadinfo=TS{TSindices}.leadinfo(leads,:);
TS{TSindices}.numleads=length(leads);
ts=TS{TSindices};
