function AC2_to_UnprocessedMat

file6='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\einzelneTestfiles_Tank_10\blub0006.ac2';


TSindex=ioReadTS(file6);


















function newTSindices = splitUnprocTS(TSindex,channels)
%splits TS{TSindex} in length(channels) new ts and saves the new ts in
%newTSindices. Clears the old TS
%input:
%   - channels:  eg { [1:30], [31:50], [51:100]}

    global TS;
    count = length(channels);
    newindices = tsNew(count);
    for p=1:count
      TS{newindices(p)} = TS{TSindex};
      TS{newindices(p)}.potvals = TS{newindices(p)}.potvals(channels{p},:);
      TS{newindices(p)}.leadinfo = TS{newindices(p)}.leadinfo(channels{p});
      TS{newindices(p)}.numleads = length(channels{p});
    end
    tsClear(TSindex);




