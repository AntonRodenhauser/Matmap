function bla()

% file paths on my laptop
file1='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\einzelneTestfiles_Tank_10\Ran0001.ac2';
file6='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\einzelneTestfiles_Tank_10\blub0006.ac2';
file9='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\einzelneTestfiles_Tank_10\Ru0009.ac2';
cal='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\einzelneTestfiles_Tank_10\calibration.cal8';
map='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\einzelneTestfiles_Tank_10\34needles_247sock_192torso_channels.mapping';




%ioReadTS(file1, cal, map);


newFilenames=ioUpdateFilename('.mat','run0009',{'-a','-b','-c'});
 
% indices=tsSplitTS(1,{[1:10],[20:40],[40:80]},newFilenames);


%tsDeal([2,3,4], 'filename',newFilenames)
tsDeal([2,3,4], 'newfileext','')

ioWriteTS([2,3,4],'noprompt','oworiginal');


