function allFids = findAllFids(potvals,signal)
% returns allFids = {fidsBeat1, fidsBeat2, .... , FidsLastBeat}
% each fidsBeatN is a numFids - array - struct 'fids' with the fields: 'type' (the fiducial type) and  'value' (the values of the fid in global frame) 
% in short: fidsBeatN is just like the 'fids' struct as it is saved in myProcessingData,
% but in the global frame!!
% Fids are determined based on 'oriFids', die fids done by the user.


%%%%% hardcoded stuff
accuracy=0.90;  % abort condition5
fidsKernelLength=10;  % the kernel indices will be from fidsValue-fidsKernelLength  until fidsValue+fidsKernelLength
kernel_shift=0;       % a "kernel shift", to shift the kernel by kernel_shift
% reminder: it is kernel_idx=fid_start-fidsKernelLength+kernel_shift:fid_start+fidsKernelLength+kernel_shift

window_width=20;   % dont search complete beat,
% ws=bs+loc_fidsValues(fidNumber)-window_width;  
% we=bs+loc_fidsValues(fidNumber)+window_width;

%%%%% set up stuff
global AUTOPROCESSING

%%%% clear any nonglobal fids from oriFids
oriFids=AUTOPROCESSING.oriFids;
toBeCleared=[];
for p=1:length(oriFids)
    if length(oriFids(p).value)~=1   % if not single global value
        toBeCleared=[toBeCleared p];
    end
end
oriFids(toBeCleared)=[];


%%%% beat kernel
bsk=AUTOPROCESSING.bsk;   %start and end of beat
bek=AUTOPROCESSING.bek;

%%%% now find the fid (kernels) to be found
%local fids in the "beat frame"
loc_qrs_start=round(oriFids([oriFids.type]==2).value);
loc_qrs_end=round(oriFids([oriFids.type]==4).value);
loc_t_start=round(oriFids([oriFids.type]==5).value);
loc_t_end=round(oriFids([oriFids.type]==7).value);
loc_t_peak=round(oriFids([oriFids.type]==6).value);


% global fids in the "potvals frame"

glob_qrs_start=bsk-1+loc_qrs_start;        
glob_qrs_end=bsk-1+loc_qrs_end;    
glob_t_start=bsk-1+loc_t_start;        
glob_t_end=bsk-1+loc_t_end;    
glob_t_peak=bsk-1+loc_t_peak; 


%%%% put fids in organised way
fidsTypes=[2 4 5 7 6];   % oder here is important: start of a wave must be imediatly followed by end of same wave. otherwise FidsToEvents failes.
glob_fidsValues = [glob_qrs_start; glob_qrs_end; glob_t_start; glob_t_end; glob_t_peak];
loc_fidsValues = [loc_qrs_start; loc_qrs_end; loc_t_start; loc_t_end; loc_t_peak];
nFids=length(fidsTypes);

%%%% set up the fsk and fek
fsk=glob_fidsValues-fidsKernelLength+kernel_shift;
fek=glob_fidsValues+fidsKernelLength+kernel_shift;


%%%%% find the beats, get rid of beats before user fiducialiced beat
beats=findMatches(signal, signal(bsk:bek), accuracy);

%%%% find oriBeatIdx, the index of the template beat
for beatNumber=1:length(AUTOPROCESSING.beats)
    if (beats{beatNumber}(1)-AUTOPROCESSING.bsk) < 3  % if found beat "close enough" to original Beat 
        oriBeatIdx=beatNumber;
        break
    end
end
AUTOPROCESSING.beats= beats(oriBeatIdx:end)
nBeats=length(AUTOPROCESSING.beats);





%%%% initialice/preallocate allFids
defaultFid(nFids).type=[];
[allFids{1:nBeats}]=deal(defaultFid);


%%%%%%%%%%%%% fill AllFids with values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for beatNumber=1:nBeats %for each beat
    disp('start beat')
    bs=AUTOPROCESSING.beats{beatNumber}(1);  % start of beat

    for fidNumber=1:nFids

        
        %%%% set up windows and kernels
        ws=bs+loc_fidsValues(fidNumber)-window_width;  % dont search complete beat, only around fid
        we=bs+loc_fidsValues(fidNumber)+window_width;
        windows=potvals(:,ws:we);
        kernels=potvals(:,fsk(fidNumber):fek(fidNumber));
        
        
        %%%% find fids
        [globFid, indivFids, variance] = findFid(windows,kernels,'normal');

        %put them in global frame
        indivFids=indivFids+fidsKernelLength-kernel_shift+bs-1+loc_fidsValues(fidNumber)-window_width;  % now  newIndivFids is in "complete potvals" frame.
        globFid=globFid+fidsKernelLength-kernel_shift+bs-1+loc_fidsValues(fidNumber)-window_width;      % put it into "complete potvals" frame


        %%%% put the found newIndivFids in allFids
        allFids{beatNumber}(fidNumber).type=fidsTypes(fidNumber);
        allFids{beatNumber}(fidNumber).value=indivFids;
        allFids{beatNumber}(fidNumber).variance=variance;


        %%%% add the global fid to allFids
        allFids{beatNumber}(nFids+fidNumber).type=fidsTypes(fidNumber);
        allFids{beatNumber}(nFids+fidNumber).value=globFid; 
    end
end





