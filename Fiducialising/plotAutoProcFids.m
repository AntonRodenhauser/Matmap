function plotAutoProcFids(varargin)
%this function opens the 4th window and deals with everything related to it


if nargin > 1 % if callback of winAutoProcessing is to be executed
    feval(varargin{1},varargin{2:end});  % execute callback
else
    setUpAllForTesting
    Init; % else initialize and open winAutoProcessing.fig
end
function setUpAllForTesting()
%this is only for testing, remove at the end
%%%%  all input parameters

ats_ets='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\MatMatStuff\Fiducialising\testRuns\ats_ets.mat';

% hard coded params
wantedFids=[0,1,2,3,4,5,6,7];
accuracy=0.95;

%%%%%  process/ get all input parameters only from ats and ets!
%get the complete signal to plot
metastruct=load(ats_ets);
ats=metastruct.ats;  % optained just before sigSlice is called
ets=metastruct.ets;  % optained after fiducialising has been done
signal = preprocessPotvals(ats.potvals); %the complete signal


% get the "beat kernel"
k1=ats.selframes(1);  %for beat-kernel
k2=ats.selframes(2);
kernel=signal(k1:k2);


% get the fiducials of fiducialsed beat and filter out unimportant fids
oriFids=ets.fids;
oriFids=removeUnnecFids(oriFids,wantedFids);


% get the fids for each beat (will be done more sophisticated late)

matches=findMatches(signal, kernel, accuracy);

allFids{length(matches)}=1; %preallocate allFids
for beatNumber=1:length(matches)
    reference=matches{beatNumber}(1);
    shiftedOriFids=oriFids;
    for q=1:length(shiftedOriFids)
        shiftedOriFids(q).value = shiftedOriFids(q).value + reference;
    end
    allFids{beatNumber}=shiftedOriFids;
end



clear global 
global AUTOPROCESSING;
AUTOPROCESSING.allFids=allFids;
AUTOPROCESSING.SELFIDS = 1;  %global, group or local Fids
% set up globals, myScriptData
global TS
TS={};
TS{1}=ats;
global myScriptData
myScriptData=struct();
myScriptData.CURRENTTS=1;
myScriptData.DISPLAYGROUPA=[1 2];  %what groups to display
myScriptData.DISPLAYTYPEA=1; % show global RMS
myScriptData.DISPLAYSCALINGA=1; % what scaling?
myScriptData.GROUPNAME={{'group1', 'group2'}};
myScriptData.CURRENTRUNGROUP=1;
myScriptData.GROUPDONOTPROCESS={{0,0}};
myScriptData.GROUPLEADS={{[1:100],[101:200]}};
myScriptData.GROUPEXTENSION={{'-gr1','-gr2'}};
myScriptData.SAMPLEFREQ=1000;
myScriptData.DISPLAYGRIDA=0;
myScriptData.DISPLAYOFFSETA = 1;
myScriptData.DISPLAYLABELA = 1;
myScriptData.BASELINEWIDTH = 5;


%%%%%%% actuall stuff starts here %%%%%%%%%%%%%%%%%%%%%%%%%

function Init
global AUTOPROCESSING
fig=winAutoProcessing;
InitFiducials(fig)
InitDisplayButtons(fig)
SetupDisplay(fig);
UpdateDisplay;


%%%%%%% functions %%%%%%%%%%%%%%%%%%%%%%

function InitDisplayButtons(fig)
% initialize everything in figure exept the plotting stuff.. 
%%%% set up the listeners for the sliders
sliderx=findobj(allchild(fig),'tag','SLIDERX');
slidery=findobj(allchild(fig),'tag','SLIDERY');

addlistener(sliderx,'ContinuousValueChange',@UpdateSlider);
addlistener(slidery,'ContinuousValueChange',@UpdateSlider);

function SetupDisplay(fig)
%      no plotting, but everything else with axes, particualrely:
%         - sets up some start values for xlim, ylim, sets up axes and slider handles
%         - makes the FD.SIGNAL values,   (RMS and scaling of potvals)
pointer=fig.Pointer;
fig.Pointer='watch';

global TS myScriptData AUTOPROCESSING;

tsindex = myScriptData.CURRENTTS;
numframes = size(TS{tsindex}.potvals,2);
AUTOPROCESSING.TIME = [1:numframes]*(1/myScriptData.SAMPLEFREQ);
AUTOPROCESSING.XLIM = [1 numframes]*(1/myScriptData.SAMPLEFREQ);
AUTOPROCESSING.XWIN = [median([0 AUTOPROCESSING.XLIM]) median([3000/myScriptData.SAMPLEFREQ AUTOPROCESSING.XLIM])];


AUTOPROCESSING.AXES = findobj(allchild(fig),'tag','AXES');
AUTOPROCESSING.XSLIDER = findobj(allchild(fig),'tag','SLIDERX');
AUTOPROCESSING.YSLIDER = findobj(allchild(fig),'tag','SLIDERY');



groups = myScriptData.DISPLAYGROUPA;
numgroups = length(groups);

AUTOPROCESSING.NAME ={};
AUTOPROCESSING.GROUPNAME = {};
AUTOPROCESSING.GROUP = [];
AUTOPROCESSING.COLORLIST = {[1 0 0],[0 0.7 0],[0 0 1],[0.5 0 0],[0 0.3 0],[0 0 0.5],[1 0.3 0.3],[0.3 0.7 0.3],[0.3 0.3 1],[0.75 0 0],[0 0.45 0],[0 0 0.75]};

% set up signals for global RMS, GROUP RMS or individual RMS
switch myScriptData.DISPLAYTYPEA
    case 1   % show global RMS
        ch  = []; 
        for p=groups 
            leads = myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p};
            index = TS{tsindex}.leadinfo(leads)==0;  % index of only the 'good' leads, filter out badleads
            ch = [ch leads(index)];   % ch is leads only of the leads of the groubs selected, not of all leads
        end

        AUTOPROCESSING.SIGNAL = sqrt(mean(TS{tsindex}.potvals(ch,:).^2));
        AUTOPROCESSING.SIGNAL = AUTOPROCESSING.SIGNAL-min(AUTOPROCESSING.SIGNAL);
        AUTOPROCESSING.LEADINFO = 0;
        AUTOPROCESSING.GROUP = 1;
        AUTOPROCESSING.LEAD = 0;
        AUTOPROCESSING.LEADGROUP = 0;
        AUTOPROCESSING.NAME = {'Global RMS'};
        AUTOPROCESSING.GROUPNAME = {'Global RMS'};
        %TODO
%         set(findobj(allchild(fig),'tag','FIDSGLOBAL'),'enable','on'); 
%         set(findobj(allchild(fig),'tag','FIDSGROUP'),'enable','off');
%         set(findobj(allchild(fig),'tag','FIDSLOCAL'),'enable','off');
%         if AUTOPROCESSING.SELFIDS > 1
%             AUTOPROCESSING.SELFIDS = 1;
%             set(findobj(allchild(fig),'tag','FIDSGLOBAL'),'value',1);
%             set(findobj(allchild(fig),'tag','FIDSGROUP'),'value',0);
%             set(findobj(allchild(fig),'tag','FIDSLOCAL'),'value',0);
%         end

    case 2
        AUTOPROCESSING.SIGNAL = zeros(numgroups,numframes);
        for p=1:numgroups
            leads = myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{groups(p)};
            index = find(TS{tsindex}.leadinfo(leads)==0);
            AUTOPROCESSING.SIGNAL(p,:) = sqrt(mean(TS{tsindex}.potvals(leads(index),:).^2)); 
            AUTOPROCESSING.SIGNAL(p,:) = AUTOPROCESSING.SIGNAL(p,:)-min(AUTOPROCESSING.SIGNAL(p,:));
            AUTOPROCESSING.NAME{p} = [myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP}{groups(p)} ' RMS']; 
        end
        AUTOPROCESSING.GROUPNAME = AUTOPROCESSING.NAME;
        AUTOPROCESSING.GROUP = 1:numgroups;
        AUTOPROCESSING.LEAD = 0*AUTOPROCESSING.GROUP;
        AUTOPROCESSING.LEADGROUP = groups;
        AUTOPROCESSING.LEADINFO = zeros(numgroups,1);
        %TODO
%         set(findobj(allchild(fig),'tag','FIDSGLOBAL'),'enable','on');
%         set(findobj(allchild(fig),'tag','FIDSGROUP'),'enable','on');
%         set(findobj(allchild(fig),'tag','FIDSLOCAL'),'enable','off');
%         if AUTOPROCESSING.SELFIDS > 2
%             AUTOPROCESSING.SELFIDS = 1;
%             set(findobj(allchild(fig),'tag','FIDSGLOBAL'),'value',1);
%             set(findobj(allchild(fig),'tag','FIDSGROUP'),'value',0);
%             set(findobj(allchild(fig),'tag','FIDSLOCAL'),'value',0);
%         end

    case 3
        AUTOPROCESSING.GROUP =[];
        AUTOPROCESSING.NAME = {};
        AUTOPROCESSING.LEAD = [];
        AUTOPROCESSING.LEADGROUP = [];
        ch  = []; 
        for p=groups
            ch = [ch myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}]; 
            AUTOPROCESSING.GROUP = [AUTOPROCESSING.GROUP p*ones(1,length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}))];
            AUTOPROCESSING.LEADGROUP = [AUTOPROCESSING.GROUP myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}];
            AUTOPROCESSING.LEAD = [AUTOPROCESSING.LEAD myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}];
            for q=1:length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}), AUTOPROCESSING.NAME{end+1} = sprintf('%s # %d',myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP}{p},q); end 
        end
        for p=1:length(groups)
            AUTOPROCESSING.GROUPNAME{p} = [myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP}{groups(p)}]; 
        end 
        AUTOPROCESSING.SIGNAL = TS{tsindex}.potvals(ch,:);
        AUTOPROCESSING.LEADINFO = TS{tsindex}.leadinfo(ch);
        %TODO
%         set(findobj(allchild(fig),'tag','FIDSGLOBAL'),'enable','on');
%         set(findobj(allchild(fig),'tag','FIDSGROUP'),'enable','on');
%         set(findobj(allchild(fig),'tag','FIDSLOCAL'),'enable','on');
end

% modify signal accourding to chosen Displayscaling
switch myScriptData.DISPLAYSCALINGA
    case 1
        k = max(abs(AUTOPROCESSING.SIGNAL),[],2);
        [m,~] = size(AUTOPROCESSING.SIGNAL);
        k(k==0) = 1;
        s = sparse(1:m,1:m,1./k,m,m);
        AUTOPROCESSING.SIGNAL = s*AUTOPROCESSING.SIGNAL;
    case 2
        k = max(abs(AUTOPROCESSING.SIGNAL(:)));
        [m,~] = size(AUTOPROCESSING.SIGNAL);
        if k > 0
            s = sparse(1:m,1:m,1/k*ones(1,m),m,m);
            AUTOPROCESSING.SIGNAL = s*AUTOPROCESSING.SIGNAL;
        end
    case 3
        [m,~] = size(AUTOPROCESSING.SIGNAL);
        k = ones(m,1);
        for p=groups
            ind = find(AUTOPROCESSING.GROUP == p);
            k(ind) = max(max(abs(AUTOPROCESSING.SIGNAL(ind,:)),[],2));
        end
        s = sparse(1:m,1:m,1./k,m,m);
        AUTOPROCESSING.SIGNAL = s*AUTOPROCESSING.SIGNAL;
end

% if individuals are displayed, give signals an offset, so they dont touch
% in plot
if myScriptData.DISPLAYTYPEA == 3
    AUTOPROCESSING.SIGNAL = 0.5*AUTOPROCESSING.SIGNAL+0.5;
end

numsignal = size(AUTOPROCESSING.SIGNAL,1);
for p=1:numsignal   % stack signals "on top of each other" for plotting..
    AUTOPROCESSING.SIGNAL(p,:) = AUTOPROCESSING.SIGNAL(p,:)+(numsignal-p);
end
AUTOPROCESSING.YLIM = [0 numsignal];
AUTOPROCESSING.YWIN = [max([0 numsignal-6]) numsignal]; %dipsplay maximal 6 singnals simulatniouslyy

fig.Pointer=pointer;

function UpdateDisplay
%plots the FD.SIGNAL,  makes the plot..  also calls  DisplayFiducials
global myScriptData AUTOPROCESSING;
ax=AUTOPROCESSING.AXES;
axes(ax);
cla(ax);
hold(ax,'on');
ywin = AUTOPROCESSING.YWIN;
xwin = AUTOPROCESSING.XWIN;
xlim = AUTOPROCESSING.XLIM;
ylim = AUTOPROCESSING.YLIM;

numframes = size(AUTOPROCESSING.SIGNAL,2);
startframe = max([floor(myScriptData.SAMPLEFREQ*xwin(1)) 1]);
endframe = min([ceil(myScriptData.SAMPLEFREQ*xwin(2)) numframes]);

% DRAW THE GRID
if myScriptData.DISPLAYGRIDA > 1
    if myScriptData.DISPLAYGRIDA > 2
        clines = 0.04*[floor(xwin(1)/0.04):ceil(xwin(2)/0.04)];
        X = [clines; clines]; Y = ywin'*ones(1,length(clines));
        line(ax,X,Y,'color',[0.9 0.9 0.9],'hittest','off');
    end
    disp('ja')
    clines = 0.2*[floor(xwin(1)/0.2):ceil(xwin(2)/0.2)];
    X = [clines; clines]; Y = ywin'*ones(1,length(clines));
    line(ax,X,Y,'color',[0.5 0.5 0.5],'hittest','off');
end



numchannels = size(AUTOPROCESSING.SIGNAL,1);
if myScriptData.DISPLAYOFFSETA == 1
    chend = numchannels - max([floor(ywin(1)) 0]);
    chstart = numchannels - min([ceil(ywin(2)) numchannels])+1;
else
    chstart = 1;
    chend = numchannels;
end

%%%% choose colors and plot
for p=chstart:chend
    k = startframe:endframe;
    color = AUTOPROCESSING.COLORLIST{AUTOPROCESSING.GROUP(p)};
    if AUTOPROCESSING.LEADINFO(p) > 0
        color = [0 0 0];
        if AUTOPROCESSING.LEADINFO(p) > 3
            color = [0.35 0.35 0.35];
        end
    end
    plot(ax,AUTOPROCESSING.TIME(k),AUTOPROCESSING.SIGNAL(p,k),'color',color,'hittest','off');
    if (myScriptData.DISPLAYLABELA == 1)&&(chend-chstart < 30) && (AUTOPROCESSING.YWIN(2) >= numchannels-p+1)
        text(ax,AUTOPROCESSING.XWIN(1),numchannels-p+1,AUTOPROCESSING.NAME{p},'color',color,'VerticalAlignment','top','hittest','off'); 
    end
end
set(AUTOPROCESSING.AXES,'YTick',[],'YLim',ywin,'XLim',xwin);

%%%% do some slider stuff
xlen = (xlim(2)-xlim(1)-xwin(2)+xwin(1));
if xlen < (1/myScriptData.SAMPLEFREQ), xslider = 0.99999; else xslider = (xwin(1)-xlim(1))/xlen; end
if xlen >= (1/myScriptData.SAMPLEFREQ), xfill = (xwin(2)-xwin(1))/xlen; else xfill = myScriptData.SAMPLEFREQ; end
xinc = median([(1/myScriptData.SAMPLEFREQ) xfill/2 0.99999]);
xfill = median([(1/myScriptData.SAMPLEFREQ) xfill myScriptData.SAMPLEFREQ]);
xslider = median([0 xslider 0.99999]);
set(AUTOPROCESSING.XSLIDER,'value',xslider,'sliderstep',[xinc xfill]);

ylen = (ylim(2)-ylim(1)-ywin(2)+ywin(1));
if ylen < (1/myScriptData.SAMPLEFREQ), yslider = 0.99999; else yslider = ywin(1)/ylen; end
if ylen >= (1/myScriptData.SAMPLEFREQ), yfill = (ywin(2)-ywin(1))/ylen; else yfill =myScriptData.SAMPLEFREQ; end
yinc = median([(1/myScriptData.SAMPLEFREQ) yfill/2 0.99999]);
yfill = median([(1/myScriptData.SAMPLEFREQ) yfill myScriptData.SAMPLEFREQ]);
yslider = median([0 yslider 0.99999]);
set(AUTOPROCESSING.YSLIDER,'value',yslider,'sliderstep',[yinc yfill]);

%%%% set all handle lists empty (no lines/patches displaying the fids yet)
for beatNumber=1:length(AUTOPROCESSING.allFids)
    AUTOPROCESSING.EVENTS{beatNumber}{1}.handle = [];
    AUTOPROCESSING.EVENTS{beatNumber}{2}.handle = [];
    AUTOPROCESSING.EVENTS{beatNumber}{3}.handle = [];
end

DisplayFiducials;

function DisplayFiducials
% this functions plotts the lines/patches when u select the fiducials
% (the line u can move around with your mouse)

global myScriptData AUTOPROCESSING;

for beatNumber=1:length(AUTOPROCESSING.EVENTS)   %for each beat
    % GLOBAL EVENTS
    events = AUTOPROCESSING.EVENTS{beatNumber}{1};
     if ~isempty(events.handle), index = find(ishandle(events.handle(:)) & (events.handle(:) ~= 0)); delete(events.handle(index)); end   %delete any existing lines
    events.handle = [];
    ywin = AUTOPROCESSING.YWIN;
    if AUTOPROCESSING.SELFIDS == 1, colorlist = events.colorlist; else colorlist = events.colorlistgray; end

    for p=1:size(events.value,2)   %   for p=[1: anzahl zu plottender linien]
        switch events.typelist(events.type(p))
            case 1 % normal fiducial
                v = events.value(1,p,1);
                events.handle(1,p) = line('parent',events.axes,'Xdata',[v v],'Ydata',ywin,'Color',colorlist{events.type(p)},'hittest','off','linewidth',events.linewidth{events.type(p)},'linestyle',events.linestyle{events.type(p)});
            case {2,3} % interval fiducial/ fixed intereval fiducial
                v = events.value(1,p,1);
                v2 = events.value(1,p,2);
                events.handle(1,p) = patch('parent',events.axes,'Xdata',[v v v2 v2],'Ydata',[ywin ywin([2 1])],'FaceColor',colorlist{events.type(p)},'hittest','off','FaceAlpha', 0.4,'linewidth',events.linewidth{events.type(p)},'linestyle',events.linestyle{events.type(p)});
        end
    end
    AUTOPROCESSING.EVENTS{beatNumber}{1} = events;           

    if myScriptData.DISPLAYTYPEA == 1, continue; end

    % GROUP FIDUCIALS

    events = AUTOPROCESSING.EVENTS{beatNumber}{2};
    if ~isempty(events.handle), index = find(ishandle(events.handle(:)) & (events.handle(:) ~= 0)); delete(events.handle(index)); end
    events.handle = [];
    if AUTOPROCESSING.SELFIDS == 2, colorlist = events.colorlist; else colorlist = events.colorlistgray; end

    numchannels = size(AUTOPROCESSING.SIGNAL,1);
    chend = numchannels - max([floor(ywin(1)) 0]);
    chstart = numchannels - min([ceil(ywin(2)) numchannels])+1;

    index = chstart:chend;

    for q=1:max(AUTOPROCESSING.LEADGROUP)
        nindex = index(AUTOPROCESSING.LEADGROUP(index)==q);
        if isempty(nindex), continue; end
        ydata = numchannels-[min(nindex)-1 max(nindex)];


        for p=1:size(events.value,2)
            switch events.typelist(events.type(p))
                case 1 % normal fiducial
                    v = events.value(q,p,1);
                    events.handle(q,p) = line('parent',events.axes,'Xdata',[v v],'Ydata',ydata,'Color',colorlist{events.type(p)},'hittest','off','linewidth',events.linewidth{events.type(p)},'linestyle',events.linestyle{events.type(p)});
                case {2,3} % interval fiducial/ fixed intereval fiducial
                    v = events.value(q,p,1);
                    v2 = events.value(q,p,2);
                    events.handle(q,p) = patch('parent',events.axes,'Xdata',[v v v2 v2],'Ydata',[ydata ydata([2 1])],'FaceColor',colorlist{events.type(p)},'hittest','off','FaceAlpha', 0.4,'linewidth',events.linewidth{events.type(p)},'linestyle',events.linestyle{events.type(p)});
            end
        end
    end
    AUTOPROCESSING.EVENTS{beatNumber}{2} = events;   

    if myScriptData.DISPLAYTYPEF == 2, continue; end

    % LOCAL FIDUCIALS

    events = AUTOPROCESSING.EVENTS{beatNumber}{3};

    %%%% delete all current handles and set events.handles=[]
     if ~isempty(events.handle)
         index = find(ishandle(events.handle(:)) & (events.handle(:) ~= 0));
         delete(events.handle(index))
     end
    events.handle = [];


    if AUTOPROCESSING.SELFIDS == 3, colorlist = events.colorlist; else colorlist = events.colorlistgray; end


    %%%% index is eg [3 4 5 8 9 10], if those are the leads currently
    %%%% displayed (this changes with yslider!, note 5 8 !

    index = AUTOPROCESSING.LEAD(chstart:chend);
    for q=index     % for each of the 5-7 channels, that one can see in axes
        for idx=find(q==AUTOPROCESSING.LEAD)
            ydata = numchannels-[idx-1 idx];   % y-value, from where to where each local fid is plottet, eg [15, 16]  
            for p=1:size(events.value,2)   % for each fid of that channel
                switch events.typelist(events.type(p))
                    case 1 % normal fiducial
                        v = events.value(q,p,1);
                       events.handle(q,p) = line('parent',events.axes,'Xdata',[v v],'Ydata',ydata,'Color',colorlist{events.type(p)},'hittest','off','linewidth',events.linewidth{events.type(p)},'linestyle',events.linestyle{events.type(p)});
                    case {2,3} % interval fiducial/ fixed intereval fiducial
                        v = events.value(q,p,1);
                        v2 = events.value(q,p,2);
                        events.handle(q,p) = patch('parent',events.axes,'Xdata',[v v v2 v2],'Ydata',[ydata ydata([2 1])],'FaceColor',colorlist{events.type(p)},'hittest','off','FaceAlpha', 0.4,'linewidth',events.linewidth{events.type(p)},'linestyle',events.linestyle{events.type(p)});
                end
            end
        end
    end
    AUTOPROCESSING.EVENTS{beatNumber}{3} = events;
    disp('end of loop')
end
    


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


%%% scaling
k = max(abs(signal),[],2);
[m,~] = size(signal);
k(k==0) = 1;
s = sparse(1:m,1:m,1./k,m,m);
signal = full(s*signal);

%%%%%%% callback functions %%%%%%%%%%%%%%%%%%%%%

function Navigation(handle,mode)
%callback to all navigation buttons (including apply)
global myScriptData

switch mode
case {'prev','next','stop'}
    myScriptData.NAVIGATION = mode;
    set(handle,'DeleteFcn','');
    delete(handle);
case {'apply'}
    %TODO.. what to do when applied is pressed...
    myScriptData.NAVIGATION = 'apply';
    set(handle,'DeleteFcn','');
    delete(handle);
otherwise
    error('unknown navigation command');
end

function scrollFcn(handle, eventData)
%callback for scrolling
diff=(-1)*eventData.VerticalScrollCount*0.05;

yslider=findobj(allchild(handle),'tag','SLIDERY');
value=yslider.Value;

value=value+diff;

if value > 1, value=1; end
if value < 0, value=0; end

yslider.Value=value;

UpdateSlider(yslider)

function UpdateSlider(handle,~)
%callback to slider
global AUTOPROCESSING
tag = get(handle,'tag');
value = get(handle,'value');
switch tag
    case 'SLIDERX'
        xwin = AUTOPROCESSING.XWIN;
        xlim = AUTOPROCESSING.XLIM;
        winlen = xwin(2)-xwin(1);
        limlen = xlim(2)-xlim(1);
        xwin(1) = median([xlim value*(limlen-winlen)+xlim(1)]);
        xwin(2) = median([xlim xwin(1)+winlen]);
        AUTOPROCESSING.XWIN = xwin;
   case 'SLIDERY'
        ywin = AUTOPROCESSING.YWIN;
        ylim = AUTOPROCESSING.YLIM;
        winlen = ywin(2)-ywin(1);
        limlen = ylim(2)-ylim(1);
        ywin(1) = median([ylim value*(limlen-winlen)+ylim(1)]);
        ywin(2) = median([ylim ywin(1)+winlen]);
        AUTOPROCESSING.YWIN = ywin;     
end

UpdateDisplay;

function DisplayButton(cbobj)
%callback function to all the buttons
global myScriptData
myScriptData.(cbobj.Tag)=cbobj.Value;
switch cbobj.Tag
    case {'DISPLAYTYPEA','DISPLAYOFFSETA','DISPLAYSCALINGA','DISPLAYGROUPA'}
        SetupDisplay(cbobj.Parent)
        UpdateDisplay
    otherwise
        UpdateDisplay
end



%%%%%%% util functions %%%%%%%%%%%%%%%%%%%%%%%
function fids=removeUnnecFids(fids,wantedFids)
toBeRemoved=[];
for p=1:length(fids)
    if ~ismember(fids(p).type, wantedFids)
        toBeRemoved=[toBeRemoved p];
    end
end
fids(toBeRemoved)=[];


function InitFiducials(fig)
% sets up .EVENTS
% sets up DefaultEvent
% calls FidsToEvents


global myScriptData TS AUTOPROCESSING;


% for all fiducial types
events.dt = myScriptData.BASELINEWIDTH/myScriptData.SAMPLEFREQ;
events.value = [];
events.type = [];
events.handle = [];
events.axes = findobj(allchild(fig),'tag','AXES');
events.colorlist = {[1 0.7 0.7],[0.7 1 0.7],[0.7 0.7 1],[0.5 0 0],[0 0.5 0],[0 0 0.5],[1 0 1],[1 1 0],[0 1 1],  [1 0.5 0],[1 0.5 0]};
events.colorlistgray = {[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],   [0.8 0.8 0.8],[0.8 0.8 0.8]};
events.typelist = [2 2 2 1 1 3 1 1 1 1 2];
events.linestyle = {'-','-','-','-.','-.','-','-','-','-','-','-'};
events.linewidth = {1,1,1,2,2,1,2,2,2,2,2,1};
events.num = [1 2 3 4 5 7 8 9 10 11];

AUTOPROCESSING.fidslist = {'P-wave','QRS-complex','T-wave','QRS-peak','T-peak','Activation','Recovery','Reference','X-Peak','X-Wave'};     

AUTOPROCESSING.NUMTYPES = length(AUTOPROCESSING.fidslist);
% AUTOPROCESSING.SELFIDS = 1;   TODO  
% set(findobj(allchild(handle),'tag','FIDSGLOBAL'),'value',1);
% set(findobj(allchild(handle),'tag','FIDSGROUP'),'value',0);
% set(findobj(allchild(handle),'tag','FIDSLOCAL'),'value',0);


events.sel = 0;
events.sel2 = 0;
events.sel3 = 0;

events.maxn = 1;
events.class = 1; AUTOPROCESSING.DEFAULT_EVENTS{1} = events;  % GLOBAL EVENTS
events.maxn = length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP});
events.class = 2; AUTOPROCESSING.DEFAULT_EVENTS{2} = events;  % GROUP EVENTS
events.maxn = size(TS{myScriptData.CURRENTTS}.potvals,1);
events.class = 3; AUTOPROCESSING.DEFAULT_EVENTS{3} = events;  % LOCAL EVENTS

FidsToEvents;


function FidsToEvents
%puts ts.fids of a certain beat (specified by beatNumber  to .EVENTS(beatNumber)

global TS myScriptData AUTOPROCESSING;

samplefreq = myScriptData.SAMPLEFREQ;
isamplefreq = 1/samplefreq;

for beatNumber=1:length(AUTOPROCESSING.allFids)  %for each beat
    AUTOPROCESSING.EVENTS{beatNumber}=AUTOPROCESSING.DEFAULT_EVENTS;
    fids=AUTOPROCESSING.allFids{beatNumber};
    
    %%%% loop through fids and fill pval, qval, tval etc with "end of waves" from .fids
    pval = []; qval = []; tval = [];
    pind = []; qind = []; tind = [];
    xind=[]; xval=[];
    for q=1:length(fids)     % type 1, 4, 7 and 27 is end of p-,q-,t- and x-wave (in that order)
        if fids(q).type == 1
            pind = [pind q];
            pval = [pval mean(fids(q).value)*isamplefreq];    
        elseif fids(q).type == 4
            qind = [qind q];
            qval = [qval mean(fids(q).value)*isamplefreq];
        elseif fids(q).type == 7
            tind = [tind q];
            tval = [tval mean(fids(q).value)*isamplefreq];
        elseif fids(q).type==27  % X-Wave
            xind = [xind q]; 
            xval = [xval mean(fids(q).value)*isamplefreq];    
        end
    end

    % if eg.  fids(2).type=4 and fids(3).value=148.32,   then now qind=2 and
    % qval=0.14832



    %%%% loop through fids again
    numchannels = size(TS{myScriptData.CURRENTTS}.potvals,1);
    for p=1:length(fids)

        %%%%  set mtype, val1, ind2, val2 and find the beginning of wave/the
        %%%%  peaks
         switch fids(p).type
            case 0
                mtype = 1;
                val1 = fids(p).value*isamplefreq;
                if isempty(pind), continue; end
                ind2  = find(pval > mean(val1)); 
                if isempty(ind2), continue; end
                ind2 = ind2(pval(ind2)==min(pval(ind2)));
                val2 = fids(pind(ind2(1))).value*isamplefreq;
            case 2
                mtype = 2;
                val1 = fids(p).value*isamplefreq;
                if isempty(qind), continue; end
                ind2  = find(qval > mean(val1)); 
                if isempty(ind2), continue; end
                ind2 = ind2(qval(ind2)==min(qval(ind2)));
                val2 = fids(qind(ind2(1))).value*isamplefreq;
            case 5
                mtype = 3;
                val1 = fids(p).value*isamplefreq;
                if isempty(tind), continue; end
                ind2  = find(tval > mean(val1));
                if isempty(ind2), continue; end
                ind2 = ind2(tval(ind2)==min(tval(ind2)));
                val2 = fids(tind(ind2(1))).value*isamplefreq;          
            case 3
                mtype = 4; val1 = fids(p).value*isamplefreq; val2 = val1;
            case 6
                mtype = 5; val1 = fids(p).value*isamplefreq; val2 = val1;
            case 16
                mtype = 6; val1 = fids(p).value*isamplefreq; val2 = val1+myScriptData.BASELINEWIDTH/samplefreq;
            case 10
                mtype = 7; val1 = fids(p).value*isamplefreq; val2 = val1;
            case 13
                mtype = 8; val1 = fids(p).value*isamplefreq; val2 = val1;
            case 14
                mtype = 9; val1 = fids(p).value*isamplefreq; val2 = val1;
            case 26     % X-Wave
                mtype = 11;
                val1 = fids(p).value*isamplefreq;
                if isempty(xind), continue; end
                ind2  = find(xval > mean(val1));
                if isempty(ind2), continue; end
                ind2 = ind2(xval(ind2)==min(xval(ind2)));
                val2 = fids(xind(ind2(1))).value*isamplefreq;
            case 25   %X-Peak
                mtype = 10; val1 = fids(p).value*isamplefreq; val2 = val1;
            otherwise
                continue;
         end
        %mtype correstponds to: fidslist = {'P-wave','QRS-complex','T-wave','QRS-peak','T-peak','Baseline','Activation','Recovery','Reference','Fbase'};
        % mtype=3 means it's a T-wave, because fidslist{3}='T-Wave'

        %mtype is now fiducial type,
        % val1 is first value of wave/value of peak
        % val2 is second value of wave or val2=val1, if it's a peak
        %ind2 is index in fids where end of wave is


        %%%% now fill events.value with the values from val1, val2
        if (length(val1) == numchannels)&&(length(val2) == numchannels) % if value for each lead
            isgroup = 1;
            for q=1:length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP})
                channels = myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{q};
                if(nnz(val1(channels)-val1(channels(1)))>0), isgroup = 0; end
                if(nnz(val2(channels)-val2(channels(1)))>0), isgroup = 0; end
            end

            if isgroup == 1     % if group fiducials
                gval1 = []; gval2 =[];
                for q=1:length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP})
                    channels = myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{q};
                    gval1(q) = val1(channels(1));
                    gval2(q) = val2(channels(1));
                end
                AUTOPROCESSING.EVENTS{beatNumber}{2}.value(:,end+1,1) = gval1;
                AUTOPROCESSING.EVENTS{beatNumber}{2}.value(:,end,2) = gval2;
                AUTOPROCESSING.EVENTS{beatNumber}{2}.type(end+1) = mtype;                
            else   % if individual fiducials
                AUTOPROCESSING.EVENTS{beatNumber}{3}.value(:,end+1,1) = val1;
                AUTOPROCESSING.EVENTS{beatNumber}{3}.value(:,end,2) = val2;
                AUTOPROCESSING.EVENTS{beatNumber}{3}.type(end+1) = mtype;
            end
        elseif (length(val1) ==1)&&(length(val2) == 1) % if global fiducials
            AUTOPROCESSING.EVENTS{beatNumber}{1}.value(:,end+1,1) = val1;
            AUTOPROCESSING.EVENTS{beatNumber}{1}.value(:,end,2) = val2;
            AUTOPROCESSING.EVENTS{beatNumber}{1}.type(end+1) = mtype;  
        end
    end
end
   
    


