
function plotOriginalMatmapData()

global myts
blpts=round([ myts.selectedFids(1,1,1) myts.selectedFids(1,2,1)]*1000);



figure

subplot(2,2,1)
plot(myts.firstBeginFD(1,:));
title('potval beginning')
line([blpts(1),blpts(1)],[-5 5],'color','red')
line([blpts(2), blpts(2)], [-5 5],'color','red')


% plot(myts.firstSigMSR_noScale);
% title('Signal, from beginning, MRS, but no scaling')


subplot(2,2,2)
plot(myts.firstSigMSRscale);
title('Signal beginning')
line([blpts(1),blpts(1)],[0 1],'color','red')
line([blpts(2), blpts(2)], [0 1],'color','red')


subplot(2,2,3)
plot(myts.secondBeginFD(1,:));
title('baselined potvals')
line([blpts(1),blpts(1)],[-5 5],'color','red')
line([blpts(2), blpts(2)], [-5 5],'color','red')


% plot(myts.firstSigMSR_noScale);
% title('baselined Signal, MRS, but no scaling')

subplot(2,2,4)
plot(myts.secondSigMSscale);
title('baselined signal')
line([blpts(1),blpts(1)],[0 1],'color','red')
line([blpts(2), blpts(2)], [0 1],'color','red')


