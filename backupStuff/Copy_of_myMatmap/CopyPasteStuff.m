function bla(orts)

% file paths on my laptop
file1='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\einzelneTestfiles_Tank_10\Ran0001.ac2';
file6='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\einzelneTestfiles_Tank_10\blub0006.ac2';
file9='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\einzelneTestfiles_Tank_10\Run0009.ac2';
file5='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\einzelneTestfiles_Tank_10\Run0005.ac2';
cal='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\einzelneTestfiles_Tank_10\calibration.cal8';

map='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\einzelneTestfiles_Tank_10\34needles_247sock_192torso_channels.mapping';


global TS

index=ioReadTS(file6, cal, map);


blpts=[512 965];
%DoBaseLineCorrection(index,blpts,5);


figure(1)
orY=orts.potvals(24,:);
plot(orY)
title('24')

figure(2)
orY=orts.potvals(122,:);
plot(orY)
title('122')

figure(3)
orY=orts.potvals(149,:);
plot(orY)
title('149')






