function demoZeugs()
% demonstration and testing of all the functions

%%%% inputs:

data='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\AllMatmapStuff\DataFilesForTesting\mat\Run0006.mat';
withfids='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\AllMatmapStuff\DataFilesForTesting\mat\Run0006-nsWithFids';

fidsTypes2keep=[0,1,2,3,4,5,6,7];   % only try to find these fiducials, ignore other types
accuracy=0.95;  % abort condition to find beats

fidsKernelLength=15;  % the kernel indices will be from fidsValue-fidsKernelLength  until fidsValue+fidsKernelLength

%%%%%  process & prepare inputs
load(data)
potvals = preprocessPotvals(ts.potvals); % time average, no rms

signal=rms(potvals,1);                % rms signal to find beats
signal=signal-min(signal);

% load an example fidsk  "fids kernel" 
load(withfids)     %this loads a ts with fids from run0006


%%%%%%% here actuall stuff starts %%%%%%%%%%%%%%%%%%%%%%


%%%%  get the beat kernel
bsk=ts.selframes(1);    % "beat start kernel"
bek=ts.selframes(2);  %beat end kernel


%%%% get  fidsTypes  and fidsValues
fidsTypes=[];
fidsValues=[];
for p=1:length(ts.fids)
    if length(ts.fids(p).value) ~=1    % if not a global fiducial (or an empty one)
        continue
    elseif ~ismember(ts.fids(p).type,fidsTypes2keep)  % if we want to ignore this fid
        continue
    end
    
    fidsTypes(end+1)=(ts.fids(p).type);
    fidsValues(end+1)=round(ts.fids(p).value);
end
nFids=length(fidsValues);
% now it is:
% fidsTypes=[typenum1, typenum2, .., typenum_nFids],  the typenumbers of the fids to autoprocess
% fidsValues=[val1, val2,  val_nFids],   the corresponding value that will be used to find the fid


%%%% set up the fsk and fek
fsk=fidsValues-fidsKernelLength;
fek=fidsValues+fidsKernelLength;


%%%%% find the beats
beats=findMatches(signal, signal(bsk:bek), accuracy);
% beats= {[bs1,be1], [bs2,be2],...}




