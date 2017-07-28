function matches=findMatches(signal, kernel, accuracy)
% finds kernel in signal.  retuns matches={[s1:e1], [s2:e2], ..[sn:en]} so that 
%  m=signal(si:ei) matches kernel for all i, "matches" means: xcorr(kernel,m,0,'coeff')>accuracy
% it also:
% - sorts the matches in order they appear in signal (m1 < m2 < .. < mi)
% notes:
% - doesnt blank out everything - so overlap is ok!


blankfraction=0.4;   % only the middle 2*blankfraktion percentage part of match is blanked -> allows for overlap
blanklength=round(blankfraction*length(kernel));

matches={};
while 1
    %%%%  do correlation, find m1 and m2
    [xc, lag]=xcorr(signal,kernel);
    [~,index]=max(abs(xc));
    m1=lag(index)+1;      %start of match
    m2=m1+length(kernel)-1;   %end of match
    
    %plotPartlyBlankedSignal(signal)    % for demonstration only
    
    
    %%%% if signal is already completely blanked
    if ~any(signal),break, end
    
    %%%% if match is at the corners -> blank and continue
    if m1<1
        signal(1:m2)=0;
        continue
    elseif m2>length(signal)
        signal(m1:end)=0;
        continue
    end
    ac=xcorr(kernel,signal(m1:m2),0,'coeff'); %actual correlation with zero lag, normalized
    if ac > accuracy   %if match is good enough
        matches{end+1}=[m1:m2];
        
        % blank parts of it
        middle=round((m1+m2)/2);
        toBeBlanked=[(middle-blanklength):(middle+blanklength)];
        
        signal(toBeBlanked)=0;     
    else
        break
    end
    
end

%%%% sort matches
m1s=zeros(length(matches));
for p=1:length(matches)
    m1s(p)=matches{p}(1);
end
[~,I]=sort(m1s);
matches=matches(I);





%%%% additional functions, mostly for demonstration

function plotPartlyBlankedSignal(signal)
plot(signal)
pause(0.7)








