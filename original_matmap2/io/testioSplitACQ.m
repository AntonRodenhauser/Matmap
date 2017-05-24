function testioSplitACQ(filename,window)

% FUNCTION ioSplitACQ(filename,window)
%
% DESCRIPTION
% This function splits an ACQ file in small files
%
% INPUT
% filename  - name of the acq file to split
% window    - number of samples in new files.
%


  % fix filename extension
  [pn,fn,ext] = fileparts(filename)
  filename = fullfile(pn,[fn '.acq'])

  fprintf(1,'Reading file header...')
  info = ReadHeader(filename)


  startframe = 1
  endframe = window
  
  while (endframe < info.numframes)
      
    frames = startframe:endframe
      
    fprintf(1,'\nReading data ... from %d to %d',startframe,endframe)
    data = ReadData(filename,1:info.numleads,frames,info)
    
    newfilename = sprintf('%s-%07d-%07d.acq',fn,startframe,endframe)
    
    WriteACQ(newfilename,data,info)
    
    startframe = startframe+window
    endframe = endframe+window
    
    clear data
  
  end


return


function data = ReadData(filename,leads,frames,info)

  fid = fopen(filename,'r','b')
  
  if (isempty(frames)),
    frames = 1:info.numframes
  end
  
  if (isempty(leads))
    leads = 1:info.numleads
  end
  
  data = zeros(length(leads),length(frames));
  pause
  find(data)
  pause
  
  nframes = max([100 info.numframes/20])
  nframes = min([nframes info.numframes])
  
  startframe = 1
  endframe = min([nframes length(frames)])
  

  fseek(fid,1024,'bof')    
  minlead = min(leads)
  maxlead = max(leads)
  
  while 1,
    
    lframes = round(startframe:endframe)
    [dummy,lidx,gidx] = intersect(lframes,frames)

    
    if (~isempty(gidx)),

        d = fread(fid,length(lframes)*(info.numleads),'ushort=>ushort')  
        d = reshape(d,info.numleads,length(lframes))    
        d = d(leads,:)
%        d = double(bitand(uint16(d),uint16(4095))) - 2048;
        data(:,gidx) = d(:,lidx)        
              
    else
      fseek(fid,length(lframes)*info.numleads,'cof')   
    end
  
    if endframe == info.numframes,
      break;
    end
      
    startframe = endframe+1
    endframe = min([endframe+nframes info.numframes])
  
  end 

  fclose(fid);

  return
  

function info = ReadHeader(filename)

  fid = fopen(filename,'r','b')

  fseek(fid,606,'bof')
  info.numleads = fread(fid,1,'short')

  fseek(fid,608,'bof')
  info.numframes = fread(fid,1,'long')
  
  fseek(fid,580,'bof')
  info.time = char(fread(fid,12,'char'))'
  info.time = info.time(2:(1+double(info.time(1))))
  
  fseek(fid,122,'bof')
  info.label = char(fread(fid,80,'char'))'
  info.label = info.label(2:(1+double(info.label(1))))

  fseek(fid,0,'bof')'
  info.rawheader = char(fread(fid,1024,'char'))
  
  fclose(fid);
  
  return
  
  
function WriteACQ(filename,data,info)

  fid = fopen(filename,'w','b')
  
  numframes = size(data,2)
  numleads = size(data,1)
  
  fseek(fid,0,'bof')
  fwrite(fid,info.rawheader,'char')
  
  fseek(fid,606,'bof')
  fwrite(fid,numleads,'short')
  fwrite(fid,numframes,'long')
  
  fseek(fid,1024,'bof')
  fwrite(fid,data,'ushort')


  fclose(fid)

  return
  