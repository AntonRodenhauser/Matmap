function findFids(potvals, signal)
global FIDSTUFF

%%%%% parameters
accuracy=0.95;  % accuracy to find beats

%%%%% first find the beats
beats=findMatches(FIDSTUFF.signal, FIDSTUFF.signal(b1:b2), accuracy);







