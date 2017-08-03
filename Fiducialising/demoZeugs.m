function demoZeugs()
% demonstration and testing of all the functions

%%%% inputs:

%%%% set params

data='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\AllMatmapStuff\DataFilesForTesting\mat\Run0006.mat';



% user selection bk, bk, fidk, fidk
bsk=50;    %the selected beat by user, "beat start kernel"
bek=450;  %beat end kernel
fsk=180;  %fiducial start kernel     
fek=250; % fiducial end kernel


% window, just for plotting
w1=1;
w2=1000;

accuracy=0.90;  % abort condition

lead=5; %which lead to plot

%%%%%  process & prepare inputs
load(data)
potvals = preprocessPotvals(ts.potvals); % time average, no rms
leadSignal=potvals(lead,w1:w2);          % just for plotting, not important

signal=rms(potvals,1);                % rms signal to find beats
signal=signal-min(signal);

%%%%%%% here actuall stuff starts %%%%%%%%%%%%%%%%%%%%%%


%%%%% first find the beats
beats=findMatches(signal, signal(bsk:bek), accuracy);
% beats= {[bs1,be1], [bs2,be2],...}



%%%% set up the allFids cell array

[allFids{1:10}]=deal(struct()); %  allFids={fid1, fid2,..., fids of last beat} %to do more than one fid
type_s=0; % type number in fid for start and end of fiducial %to do more than one fid
type_e=1;




%%%% fill fids in allFids with data for each beat
nLeads=size(potvals,1);
for p=1:length(beats)
    
    
    bs=beats{p}(1);  % start & end of p th beat, look here for f
    be=beats{p}(2);
    
    
    % for each fid    %to do more than one fid
    
    
    %%%% find individual matches in a beat for each lead
    fs=zeros(nLeads,1);   %start of indiv fid
    fe=zeros(nLeads,1);   % end of indiv fid
    for p=1:nLeads
        [xc, lag]=xcorr(potvals(p,bs:be),potvals(p,fsk:fek));
        [~,index]=max(abs(xc));
        fs(p)=lag(index)+1;      %start of fid
        fe(p)=fs(p)+fsk-fek;   %end of fid
    end
    
    %%%% put individual matches in fids    
    allFids{p}(1).type=type_s;   %to do more than one fid
    allFids{p}(2).type=type_e;
    
    allFids{p}(1).value=fs(p);   %to do more than one fid
    allFids{p}(2).value=fe(p);
    
    
    %%%% compute the global fid
    allFids{p}(3).type=type_s;   %to do more than one fid
    allFids{p}(4).type=type_e;
    
    allFids{p}(3).value=mean(fs(p));   %to do more than one fid
    allFids{p}(4).value=mean(fe(p));  
end















%%%%% plot stuff
time=1:length(leadSignal);
close all
plot(time,leadSignal)
set(gcf,'Units', 'Inches','Position',[1 1 13 7])

% % plot matches
% shift=0.3;
% for p=1:length(matches)
%     idx=time(matches{p});
%     hold on
%     plot(time(idx),leadSignal(idx)+1+shift, 'r')
%     shift=-shift;
% end
% % plot kernel
% hold on
% plot(time(k1:k2),leadSignal(k1:k2),'k')


% plot user selection/fiducialiced beat

ax=plot(time(bsk:bek),leadSignal(bsk:bek));
ywin=ylim;
patch('Xdata',[fsk fsk fek fek],'Ydata',[ywin ywin([2 1])],'FaceColor','r','hittest','off','FaceAlpha', 0.4);













function potvals = preprocessPotvals(potvals)
% do temporal filter and RMS, to get a signal to work with

%%%% temporal filter
A = 1;
B = [0.03266412226059 0.06320942361376 0.09378788647083 0.10617422096837 0.09378788647083 0.06320942361376 0.03266412226059];
D = potvals';
D = filter(B,A,D);
D(1:(max(length(A),length(B))-1),:) = ones(max(length(A),length(B))-1,1)*D(max(length(A),length(B)),:);
potvals = D';

% %%%% do RMS
% signal=rms(potvals,1);
% signal=signal-min(signal);



function bestMatch=findBestMatch(signal, kernel)
%returns best match [s,e] ,  the start/end indices, so that signal(s:e) has
%highest correlation with kernel

[xc, lag]=xcorr(signal,kernel);
[~,index]=max(abs(xc));
s=lag(index)+1;      %start of match
e=s+length(kernel)-1;   %end of match

best=[s,e];





