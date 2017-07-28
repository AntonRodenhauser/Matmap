function autoProcessSignal()

%%%% get the inputs
ats_ets='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\MatMatStuff\Fiducialising\testRuns\ats_ets.mat';

metastruct=load(ats_ets);
ats=metastruct.ats;  % optained just before sigSlice is called
ets=metastruct.ets;  % optained after fiducialising has been done
k1=ats.selframes(1);
k2=ats.selframes(2);

accuracy=0.95;  % abort condition for matching

%set up globals
global TS
index=1;
TS{index}=ats;

global myScriptData
myScriptData.DO_BASELINE=1;
myScriptData.BASELINEWIDTH=5;
myScriptData.GROUPNAME={{'group1', 'group2'}};
myScriptData.CURRENTRUNGROUP=1;
myScriptData.GROUPDONOTPROCESS={{0,0}};
myScriptData.GROUPLEADS={{[1:100],[101:200]}};
myScriptData.GROUPEXTENSION={{'-gr1','-gr2'}};
myScriptData.MATODIR='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\MatMatStuff\Fiducialising\testRuns\testoutput';
myScriptData.DO_INTEGRALMAPS=0;
myScriptData.DO_ACTIVATIONMAPS=0;

inputfilename='Run0004';   %only needed to name the output


%%%%%%  here the actual stuff starts %%%%%%%%%%%%%%%

%%%% get signal and kernel and compute matches
signal = preprocessPotvals(ats.potvals);
kernel= signal(k1:k2);

matches=findMatches(signal, kernel, accuracy);

%%%% find origin, die index of original kernel
for p=1:length(matches)
    if matches{p}==[k1:k2]
        disp('ja')
        origin=p;
        break
    end
end

%%%%% main loop: process for each match

for p=1:length(matches)
    if p==origin, continue, end
    
    filename=sprintf('%s-b%d',inputfilename,p); 
    processMatch(index,matches{p},filename)
end

    




%%%%% plot stuff
% lead=8;
% sig1=ats.potvals(lead,k1:k2);
% sig2=ets.potvals(lead,:);
% time=1:length(signal);
% plot(signal)
% hold on
% plot(time(k1:k2), kernel)

plot_matchesOnSignal(signal, matches)




















%%%%%%%%%%% functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function signal = preprocessPotvals(potvals)
% do temporal filter and RMS, to get a signal to work with

%%%% temporal filter
A = 1;
B = [0.03266412226059 0.06320942361376 0.09378788647083 0.10617422096837 0.09378788647083 0.06320942361376 0.03266412226059];

D = potvals';
D = filter(B,A,D);
D(1:(max(length(A),length(B))-1),:) = ones(max(length(A),length(B))-1,1)*D(max(length(A),length(B)),:);
potvals = D';

%%%% do RMS
signal=rms(potvals,1);
signal=signal-min(signal);



function plot_matchesOnSignal(signal, matches)
time=1:length(signal);
close all
plot(time,signal)
set(gcf,'Units', 'Inches','Position',[1 1 13 7])

for p=1:length(matches)
    idx=time(matches{p});
    hold on
    plot(time(idx),signal(idx)+1, 'r')
end


function processMatch(index, selframes,inputfilename)
%index: index to orignial ts obtained just before sigSlice in
%myProcessingScript -> mapping, calibration, temporal filter, badleads already done!
%selframes:  frames for slicing  [start:end]
global TS myScriptData

%%%% slice into newIdx
newIdx=tsNew(1);

TS{newIdx}=TS{index};
TS{newIdx}.potvals=TS{newIdx}.potvals(:,selframes);
TS{newIdx}.numframes=length(selframes);
TS{newIdx}.selframes=[selframes(1),selframes(end)];
    
%%%% save the new fids in newIdx
%TODO

%%%%  baseline correction
if myScriptData.DO_BASELINE
    sigBaseLine(newIdx,[],myScriptData.BASELINEWIDTH);
end


%%%% split TS{newIdx} into numGroups smaller ts in grIndices
splitgroup = [];
for p=1:length(myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP})
    if myScriptData.GROUPDONOTPROCESS{myScriptData.CURRENTRUNGROUP}{p} == 0, splitgroup = [splitgroup p]; end
end
% splitgroup is now eg [1 3] if there are 3 groups but the 2 should
% not be processed
channels=myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}(splitgroup);
grIndices = mytsSplitTS(newIdx, channels);    
tsDeal(grIndices,'filename',ioUpdateFilename('.mat',inputfilename,myScriptData.GROUPEXTENSION{myScriptData.CURRENTRUNGROUP}(splitgroup))); 
tsClear(newIdx);


%%%% save the new ts structures using ioWriteTS
olddir = cd(myScriptData.MATODIR);
tsDeal(grIndices,'filename',ioUpdateFilename('.mat',inputfilename,myScriptData.GROUPEXTENSION{myScriptData.CURRENTRUNGROUP}(splitgroup)));
ioWriteTS(grIndices,'noprompt','oworiginal');
cd(olddir);



%%%% do integral maps and save them  
if myScriptData.DO_INTEGRALMAPS == 1
    if myScriptData.DO_DETECT == 0
        msg=sprintf('Need fiducials (at least QRS wave or T wave) to do integral maps for %s.', inputfilename);
        errordlg(msg)
        error('Need fiducials to do integral maps');
    end
    mapindices = fidsIntAll(grIndices);
    if length(splitgroup)~=length(mapindices)
        msg=sprintf('Fiducials (QRS wave or T wave) necessary to do integral maps. However, for %s there are no fiducials for all groups.',inputfilename);
        errordlg(msg)
        error('No fiducials for integralmaps.')
    end

    olddir = cd(myScriptData.MATODIR); 
    fnames=ioUpdateFilename('.mat',inputfilename,myScriptData.GROUPEXTENSION{myScriptData.CURRENTRUNGROUP}(splitgroup),'-itg');

    tsDeal(mapindices,'filename',fnames); 
    tsSet(mapindices,'newfileext','');
    ioWriteTS(mapindices,'noprompt','oworiginal');
    cd(olddir);
    tsClear(mapindices);
end
    
    
%%%%% Do activation maps   

if myScriptData.DO_ACTIVATIONMAPS == 1
    if myScriptData.DO_DETECT == 0 % 'Detect fiducials must be selected'
        error('Need fiducials to do activation maps');
    end

    %%%% make new ts at TS(mapindices). That new ts is like the old
    %%%% one, but has ts.potvals=[act rec act-rec]
    mapindices = sigActRecMap(grIndices);   


    %%%%  save the 'new act/rec' ts as eg 'Run0009-gr1-ari.mat
    % AND clearTS{mapindex}!
    olddir = cd(myScriptData.MATODIR);
    tsDeal(mapindices,'filename',ioUpdateFilename('.mat',inputfilename,myScriptData.GROUPEXTENSION{myScriptData.CURRENTRUNGROUP}(splitgroup),'-ari')); 
    tsSet(mapindices,'newfileext','');
    ioWriteTS(mapindices,'noprompt','oworiginal');
    cd(olddir);
    tsClear(mapindices);
end

   %%%%% save everything and clear TS
%    saveSettings();          TODO
    tsClear(grIndices);











