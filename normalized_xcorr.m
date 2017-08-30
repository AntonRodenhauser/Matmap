function normalized_xcorr()

window=[1 1 1 2 3 2 1 1 1 1  1  30 1 1  1  1];
% idx   1 2 3 4 5 6 7 8 9 10 11 12 13 14 15

kernel=[1 2 3 2 1];


%%%% normal correlation for comparrsion
[xc, lag]=coef_xcorr(window,kernel); 
[~,index]=max(xc);
start_idx=lag(index)+1;



%%%%%%%%%%%%%%%%%%% compare the methods with real data %%%%%%
data='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\AllMatmapStuff\DataFilesForTesting\mat\Run0006.mat';

fsk=30,
fek=70;


load(data)
time=1:length(window);
window=ts.potvals(1,1:500);
time=1:length(window);

plot(window)

hold on

%plot kernel
plot(time(fsk:fek),window(fsk:fek),'k')


%%% find kernel with matlab

[xc, lag]=coef_xcorr(window,kernel); 
[~,index]=max(xc);
start_idx=lag(index)+1;

kernel_length=length(kernel);







function [xc lag] = zeroAppend_xcorr(window, kernel)
% exactly like normal xcorr, but with 'coef' option
% this is actually NOT what I want!!!  dont use..

%%%% make both the same length;
if length(kernel)<length(window)
    kernel(length(window))=0;
end
%%%% initialize
lag=(-length(window)+1):(length(window)-1);
xc=zeros(1,2*length(window)-1);

%%%% loop through lag, compute n_xc for each lag
maxlag=0;
count=1;
for shift=0:length(window)-1
    w=window(1:1+shift)
    k=kernel(end-shift:end)
    xc(count)=xcorr(w,k,maxlag,'coef');
    corrr=xc(count)
    disp('----------------------')
    count=count+1;    
end
for shift=1:length(window)-1
    w=window(1+shift:end)
    k=kernel(1:end-shift)
    xc(count)=xcorr(w,k, maxlag,'coef');
    corrr=xc(count)
    disp('----------------------')
    count=count+1;    
end


function [xc lags] = coef_xcorr(window, kernel)
%like original xcorr, but with 'coef'.  No Zeros are appended! Instead, window is shortended. No "overlapp"
% can be used exactly like normal xcorr

length_kernel=length(kernel);
lagshift=0;
lags=1:length(window)-length_kernel+1;   %only the lags with "no overlapping"

xc=zeros(1,length(lags));
for lag=lags
    xc(lag)=xcorr(window(lag:lag+length_kernel-1), kernel,lagshift,'coef');
end
lags=lags-1;   % to make it behave like original xcorr
    
    
    


















