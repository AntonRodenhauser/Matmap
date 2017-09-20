function plotProcessedBeats
%%%% a collection of functions to plot the results of fullAutoFiducialicing and plot the found fids

pathToFiles = '/Users/anton/Documents/allMatlabStuff/testingStuff/testOutput';


% %%%% plot a single file
% beat = 1;
% Run = 137;
% plotSingleFile(pathToFiles,Run,beat)


%%%% plot all files of the folder in a nRow x nCol supblot grid
nRows = 8;
step =20; %plot every step th file in folder
plotAllFilesOfFolder(pathToFiles,nRows,step)






%%%%%%%%%%%%%%%%%%%%%%% functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function plotSubplot(ax,pathToFiles, Run,beat)
Run=sprintf('%04d',Run);
beat = num2str(beat);

%%%% load the ns and the cs file
fullPath1 = fullfile(pathToFiles, ['Run' Run '-b' beat '-ns.mat']);
fullPath2 = fullfile(pathToFiles, ['Run' Run '-b' beat '-cs.mat']);

load(fullPath1)
ts1=ts;
load(fullPath2);
ts2=ts;
%%%% get full RMS
combPV = [ts1.potvals; ts2.potvals];
RMS = rms(combPV,1);
RMS = RMS - min(RMS);

%%%% get fidValues
tpeak = ts1.fids([ts1.fids.type] == 6).value;
qstart = ts1.fids([ts1.fids.type] == 2).value;
qend = ts1.fids([ts1.fids.type] == 4).value;
tstart = ts1.fids([ts1.fids.type] == 5).value;
tend = ts1.fids([ts1.fids.type] == 7).value;

%%%% plot stuff
plot(ax,RMS)
set(gca,'YLim', [0, max(RMS)], 'XLim',[1, length(RMS)]);
Ylim = ylim;

% q-wave
patch(ax,[qstart qend qend qstart], [ Ylim(1), Ylim(1), Ylim(2), Ylim(2)], 'red', 'FaceAlpha', 0.1)

% t-wave
patch(ax,[tstart tend tend tstart], [ Ylim(1), Ylim(1), Ylim(2), Ylim(2)], 'blue', 'FaceAlpha', 0.1)

% t-peak
line(ax,[tpeak tpeak], Ylim, 'Color','blue', 'LineStyle','--', 'LineWidth', 2)

title(ax,['Run' Run '-b' beat])



    
    
    
    
    
    
function plotSingleFile(pathToFiles, Run,beat)
figure
Run=sprintf('%04d',Run);
beat = num2str(beat);

%%%% load the ns and the cs file
fullPath1 = fullfile(pathToFiles, ['Run' Run '-b' beat '-ns.mat']);
fullPath2 = fullfile(pathToFiles, ['Run' Run '-b' beat '-cs.mat']);

load(fullPath1)
ts1=ts;
load(fullPath2);
ts2=ts;
%%%% get full RMS
combPV = [ts1.potvals; ts2.potvals];
RMS = rms(combPV,1);
RMS = RMS - min(RMS);

%%%% get fidValues
tpeak = ts1.fids([ts1.fids.type] == 6).value;
qstart = ts1.fids([ts1.fids.type] == 2).value;
qend = ts1.fids([ts1.fids.type] == 4).value;
tstart = ts1.fids([ts1.fids.type] == 5).value;
tend = ts1.fids([ts1.fids.type] == 7).value;

%%%% plot stuff
plot(RMS)
Ylim = ylim;

% q-wave
patch([qstart qend qend qstart], [ Ylim(1), Ylim(1), Ylim(2), Ylim(2)], 'red', 'FaceAlpha', 0.1)

% t-wave
patch([tstart tend tend tstart], [ Ylim(1), Ylim(1), Ylim(2), Ylim(2)], 'blue', 'FaceAlpha', 0.1)

% t-peak
line([tpeak tpeak], Ylim, 'Color','blue', 'LineStyle','--', 'LineWidth', 2)

title(['Run' Run '-b' beat])


function [RunsToPlot, beatsToPlot] = getRunsnBeats(pathToFiles)

cur=cd(pathToFiles);
folderData = dir('Run*.mat');

RunsToPlot=zeros(1,length(folderData));
for p = 1:length(folderData)
    Run = str2num(folderData(p).name(4:7));
    RunsToPlot(p) = Run;
end
RunsToPlot = unique(RunsToPlot);


beatsToPlot=cell(1,length(RunsToPlot));
for p = 1:length(RunsToPlot)
    run=RunsToPlot(p);
    folderData = dir(['Run', sprintf('%04d',run) '*.mat']);
    beats=zeros(1,length(folderData));
    for q = 1:length(folderData)
        file = folderData(q).name;
        beat = str2num(file(10:8+strfind(file(10:end),'-')));
        beats(q) = beat;
    end
    beats=unique(beats);
    beatsToPlot{p} = beats;
end
cd(cur);


function plotAllFilesOfFolder(pathToFiles,nRows,step)

fig = figure;
fig.Position =[229,126, 1904, 1205];
fig.Units = 'pixels';

[RunsToPlot, beatsToPlot] = getRunsnBeats(pathToFiles);

nFiles = 0;
for p=1:length(beatsToPlot)
    nFiles = nFiles + length(beatsToPlot{p});
end
nFilesToPlot=floor(nFiles/step);
nCols = ceil(nFilesToPlot/nRows);

plotCount=1; %how many subplots plotted so far?
fileCount = 0; 
for p = 1:length(RunsToPlot)
    Run = RunsToPlot(p);
    for beat = beatsToPlot{p}
       fileCount = fileCount +1;
       if ~( round(fileCount/step)==fileCount/step || fileCount==1), continue, end  % only plot every step-th file  or the very first file
       
       
        ax = subtightplot(nRows, nCols, plotCount,0.002);
        plotSubplot(ax, pathToFiles, Run, beat);
        ax.Visible = 'off';
        text(ax,0.5, 0.9,[num2str(Run) '-b' num2str(beat)],'Units','normalized','FontSize',10);
        plotCount = plotCount +1;
    end
end




