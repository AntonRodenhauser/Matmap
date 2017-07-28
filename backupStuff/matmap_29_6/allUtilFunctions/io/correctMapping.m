function correctMapping
%TODO this function can be deleted..
mapping=ioReadMapping('256sock_30needles_channels.mapping');

mapping(1017:1024)=1024;


fid=fopen('newmapping.mapping','w+');

fprintf(fid,'first line to be ignored\n');
fprintf(fid,'%d\n',mapping);

fclose(fid);





