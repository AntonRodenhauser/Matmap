function xxxx()

accuracy = 0.85;
global aaa
signal =  aaa.signal;

bsk = 451;
bek = 866;
kernel = signal(bsk:bek);
peakPos = newFindMatches(signal, kernel, accuracy);


xccoef=aaa.xc_coef;




len=5000;
shift=25000;
st = 1+shift;
e = st+len;
xval=(1:length(xccoef));
step = 1;




%%%%%%%%%%%%%%%%%%% plot stuff %%%%

figure
hold on
plot(xval(st:step:e),xccoef(st:step:e))

%%%% plot peaks
Ylim=ylim;
for xval = peakPos
    if xval < e && xval > st
        line([xval xval], [Ylim(1), Ylim(2)], 'Color','red')
    end
end




















function exactPeakLags = newFindMatches(signal, kernel, accuracy)

%%%% hardcoded:
stepSize  = 20;



%%%% stuff starts here %%%%%%%%%%%%%%%%%

%%%% set up stuff
sigLength = length(signal);
kernelLength = length(kernel);
estNumBeats = round(sigLength/330);    % very rough estimation of numBeats in signal.. a beat is usually 330 frames long

%%%% get stepLags: the evenly spaced lags (with distance stepSize) to go through. First possible lag would be 0! ("lag frame")
stStepLag = 0.5 * stepSize;   % first lag
endStepLag = sigLength  - kernelLength - 0.5 * stepSize; % last lag
nStepLags = ceil((endStepLag - stStepLag)/stepSize) + 1;
stepLags = round(linspace(stStepLag, endStepLag, nStepLags));


%%%% get stepXC - the corresponding correlations for each stepLag
count = 1;
stepXCs = zeros(1,nStepLags);
for lag = stepLags
    stepXCs(count)=xcorr(signal(lag:lag+kernelLength-1), kernel,0,'coef');
    count = count +1;
end


%%%% get the peakLags and corresponding peakXCs,  the correlations values and corresponding lags with high peak values
peakLags = zeros(1,estNumBeats);
peakXCs = peakLags;

count=1;
pval = 1;  %peak value

while pval > accuracy
    %get max val and corresponding lag
    [pval, pidx] = max(stepXCs);
    plag =  stepLags(pidx);
    
    % clear valus around pidx
    s = pidx - 4;
    e = pidx + 4;
    if s < 1, s=1; end
    if e > nStepLags, e = nStepLags; end,
    stepXCs(s:e) = 0;
    
    % save peak value pval und peak lag plag:
    peakLags(count) =  plag;
    peakXCs(count) = pval;
    
%    plotEstiPeak(plag)               % for testing only

    count = count +1;
end

%plotBlankedSteppedXcor(stepXCs,stepLags)

% get rid of zeros at the end of peakLags and peakXCs  (in case estNumBeats was to high)
idx=find(peakXCs == 0);
if ~isempty(idx)
    peakXCs(idx(1):end)=[];
    peakLags(idx(1):end)=[];
end


plotAllEstimatedPeaks(peakLags)


%%%% for each peakXC, find the real peak, which must be somewhere close to peakXC 
count=1;
exactPeakLags = zeros(1,length(peakXCs));
for pl = peakLags  % for each "estimated" peak
    
    %%%% first, get the sl ("start lag") and the el ("end lag"). The exact peak position is searched between el and sl
    % pl ("peak lag", pv ("peak value"),  av/bv ("after/before value")  al/bl ("after/before lag")
    bl = pl - 0.5*stepSize;
    bv = xcorr(signal(bl+1:bl+kernelLength), kernel,0,'coef');
    pv = peakXCs(count);
    if bv > pv
        sl = bv;
        el = pl;
        sv = bv;
        ev = pv;
    else
        al = pl + 0.5*stepSize; 
        av = xcorr(signal(al+1:al+kernelLength), kernel,0,'coef');
        
        if bv < av
            sl = pl;
            el = al;
            sv = pv;
            ev = av;
        else
            sl = bl;
            el = pl;
            sv = bv;
            ev = pv;
        end
    end
    
    
    %%%% now search for exact peak position between sl and el using a "divide and conquer" algorythm
    while sl ~= el
        
        
        if sv < ev
            sl = ceil((el+sl)/2);
            sv = xcorr(signal(sl+1:sl+kernelLength), kernel,0,'coef');
        else
            el = floor((el+sl)/2);
            ev = xcorr(signal(el+1:el+kernelLength), kernel,0,'coef');
        end
    end
    
    exactPeakLags(count) = sl;
    count = count + 1;
end

% from "lag frame" (starts at 0) to "index frame" (starts at 1)
exactPeakLags = exactPeakLags + 1; 








function [xc, lags] = coef_xcorr(window,kernel)
% just like matlabs xcorr, but with the 'coef' option for every lag
kernelLength=size(kernel,2);
lagshift=0;
nLags=size(window,2)-kernelLength+1;   %only the lags with "no overlapping"
xc=zeros(1,nLags);   %the cross correlation values
for lag=1:nLags
    xc(lag)=xcorr(window(lag:lag+kernelLength-1), kernel,lagshift,'coef');
end 
lags = 0:nLags-1;




%%%%%%%%%  plot functions %%%%%%%%%%%%%%%%%%%%
function plotPeakProgress(sl,el,pl)
global aaa
xccoef=aaa.xc_coef;
xvalues= 1:length(xccoef);

st = pl-25;
e = pl + 25;

plot(xvalues(st:e), xccoef(st:e))
Ylim=ylim;
patch([sl el el sl], [ Ylim(1), Ylim(1), Ylim(2), Ylim(2)], 'red', 'FaceAlpha', 0.1)

pause(1)


function plotEstiPeak(plag)
global aaa
xc_coef = aaa.xc_coef;
xvalues= 1:length(xc_coef);

idx=plag + 1;

s=idx-30;
e=idx+30;
if s<1, s=1;end
if e>length(xc_coef), e = length(xc_coef); end




plot(xvalues(s:e),xc_coef(s:e))
Y=ylim;
line([idx, idx], [Y(1), Y(2)], 'color','r')


pause(0.5)




function plotBlankedSteppedXcor(stepXCs,stepLags)
s=25000;
e=30000;

figure
idx=find( and(stepLags < e, stepLags > s));

xvalues=1:length(stepXCs);
plot(stepLags(idx),stepXCs(idx))

function plotAllEstimatedPeaks(peakLags)

global aaa
xccoef = aaa.xc_coef;
xval= 1:length(xccoef);

s=26000;
e=29000;



figure
hold on
plot(xval(s:e),xccoef(s:e))

%%%% plot peaks
Ylim=ylim;
for xval = peakLags
    if xval < e && xval > s
        line([xval xval], [Ylim(1), Ylim(2)], 'Color','red')
    end
end





