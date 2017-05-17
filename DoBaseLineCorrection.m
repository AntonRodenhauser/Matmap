function ts=sigBaseLine(TSindices,blpts,blwin)

% my own version of sigBaseLine.m
% edited, so it can have either the TSindices OR the ts itself as input!

% input:
%     TSindices: either the index of TS to ts struct or the struct itself
% output: 
%     the ts itself
%     also if index is passed, it also upgrades the TS structure



if isnumerical(TSindices)
    global TS
    e = ones(size(blpts,1),1);
    startframe = median([e blpts(:,1) e*(numframes-blwin+1)],2);
    endframe = median([e blpts(:,2) e*(numframes-blwin+1)],2);


    i = [[0:(blwin-1)]+startframe(1) endframe(1)+[0:(blwin-1)]];
    X = ones(numleads,1)*i;
    Y = TS{TSindices(p)}.potvals(:,i);

    ymean = mean(Y,2);
    xmean = mean(X,2);
    Ymean = ymean*ones(1,length(i));
    Xmean = xmean*ones(1,length(i));
    B = sum(X.*(Y - Ymean),2)./sum((X-Xmean).^2,2);
    A = ymean - B.*xmean;
    e1 = [1:numframes];
    e0 = ones(1,numframes);
    Y = B*e1 + A*e0;
    TS{TSindices(p)}.potvals = TS{TSindices(p)}.potvals - Y;

    tsAddAudit(TSindices(p),sprintf('|sigBaseLine baseline correction: startframe %d endframe %d over a window of %d frames',startframe(1),endframe(1),blwin));
    
    ts=TS{TSindices};
    
elseif isstruct(TSindices)
    ts=TSindices;
    e = ones(size(blpts,1),1);
    startframe = median([e blpts(:,1) e*(numframes-blwin+1)],2);
    endframe = median([e blpts(:,2) e*(numframes-blwin+1)],2);


    i = [[0:(blwin-1)]+startframe(1) endframe(1)+[0:(blwin-1)]];
    X = ones(numleads,1)*i;
    Y = ts.potvals(:,i);

    ymean = mean(Y,2);
    xmean = mean(X,2);
    Ymean = ymean*ones(1,length(i));
    Xmean = xmean*ones(1,length(i));
    B = sum(X.*(Y - Ymean),2)./sum((X-Xmean).^2,2);
    A = ymean - B.*xmean;
    e1 = [1:numframes];
    e0 = ones(1,numframes);
    Y = B*e1 + A*e0;
    ts.potvals = ts.potvals - Y;
    
    
    ts.audit=[ts.audit sprintf('|sigBaseLine baseline correction: startframe %d endframe %d over a window of %d frames',startframe(1),endframe(1),blwin)]
    
    
    dad
    
end
return
