function DemoFindMatches()

%%%% set params
data='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\MatMatStuff\Fiducialising\testRuns\Run0004.mat';

k1=1475;   %kernel start and end
k2=1490;

accuracy=0.90;  % abort condition



%%%% get signal (RMS) from testrun 
metastruct=load(data);
potvals=metastruct.ts.potvals;
signal = preprocessPotvals(potvals);
signal=signal(1:3000);


%%%% initialize kernel
kernel=signal(k1:k2);


%%%%% find the matchs
matches=findMatches(signal, kernel,accuracy);

%%%% plot stuff
time=1:length(signal);
close all
plot(time,signal)
set(gcf,'Units', 'Inches','Position',[1 1 13 7])


length(signal)
% plot matches
shift=0.3;
for p=1:length(matches)
    idx=time(matches{p});
    hold on
    plot(time(idx),signal(idx)+1+shift, 'r')
    shift=-shift;
end
% plot kernel
hold on
plot(time(k1:k2),signal(k1:k2),'k')









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





