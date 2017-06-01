
function myProcessingScript(varargin)
    %this is the first function to be called from the command line
    %jobs:
%         - Init myscriptdata
%         - Init myprocessingdata
%         - Open the mainMenu.fig (das hauptfenster), wo alle einstellungen gemacht werden
%         - Open the Settings.fig
%         - Update mainMenu.fig and Settings.fig with data from myscriptdata
%         - Update Groups with myUpdateGroups
%         - Update/setup File list, (callback for "choose input directory)
%         - if input is char (a callback function), then only that char is
%         evaluated
    
    
    if nargin > 1 && ischar(varargin{1})
        feval(varargin{1},varargin{2:end});
        return
    end
    
    
    initMyScriptData();    %init myScriptData mit default values or with data from scriptfile, if there is one.
    
    getAC2Labels          % get individual label of each .ac2 file in input folder and store them in MSD.ac2Label
    initMyProcessingData();  % initialise myScriptData with default values
    loadMyProcessingData;    % load myProcessingData form MSD.DATAFILE (whose default is pwd)
    
    main_handle=mainMenu();            % open the figure
    myUpdateFigure(main_handle);      % and update it 
    
    setting_handle=SettingsDisplay();    %Open the settings Display
    myUpdateFigure(setting_handle);     % and update it
    
    myUpdateGroups        % analogous to UpdateGroups  (initialize Group Buttons)
    
    myUpdateACQFiles      % get ACQ Files from input dir to display analog to UpdateACQFiles and get ACQ LABELS
    

    
    
end


function initMyScriptData()
    % - Sets up global myScriptData as empty struct
    % - initializes myScriptData with Default Values for everything
    %                   -myScriptData.SCRIPTFILE=myScriptDataFile;
    %                  
    % - check if myScriptData.SCRIPTFILE exists
    %       -> if yes: -load data from myScriptData.mat (and thus
    %                   overwrite/update current myScriptData)
    %       -> if no: save myScriptData as myScriptData.mat in current
    %       directory
    
    
    defaultsettings = { 'PWD','','file',...
                    'MAPPINGFILE','','file', ...
                    'PACINGLEAD',[],'double', ...
                    'CALIBRATIONFILE','','file', ...
                    'CALIBRATIONACQ','','vector', ...
                    'CALIBRATIONACQUSED','','vector',...
                    'CALIBRATIONMAPPINGUSED','','file',...
                    'SCRIPTFILE','myScriptData.mat','file',...
                    'ACQLABEL','','string',...
                    'ACQLISTBOX','','listbox',...
                    'ACQFILES',[],'listboxedit',...
                    'ACQPATTERN','','string',...
                    'ACQFILENUMBER',[],'vector',...
                    'ACQINFO',{},'string',...
                    'ACQFILENAME',{},'string',...
                    'ACQNUM',0,'integer',...
                    'DATAFILE','myProcessingData.mat','file',...
                    'TSDFDIR','autoprocessing','file',...
                    'ACQDIR','','file',...
                    'ACQCONTAIN','','string',...
                    'ACQCONTAINNOT','','string',...
                    'ACQEXT','.acq,.ac2','string',...   % was tag for fileextension. I dont use it.. TODO
                    'BASELINEWIDTH',5,'integer',...
                    'GROUPNAME','GROUP','groupstring',... 
                    'GROUPLEADS',[],'groupvector',...
                    'GROUPEXTENSION','-ext','groupstring',...
                    'GROUPTSDFC','group.tsdfc','groupfile',...
                    'GROUPGEOM','','groupfile',...
                    'GROUPCHANNELS','','groupfile',...
                    'GROUPBADLEADSFILE','','groupfile',...
                    'GROUPBADLEADS',[],'groupvector',...
                    'GROUPDONOTPROCESS',0,'groupbool',...
                    'GROUPDONOTDISPLAY',0,'groupbool',...
                    'GROUPSELECT',0,'select',...
                    'DO_CALIBRATE',1,'bool',...
                    'DO_BLANKBADLEADS',1,'bool',...
                    'DO_SLICE',1,'bool',...
                    'DO_SLICE_USER',1,'bool',...
                    'DO_ADDBADLEADS',0,'bool',...
                    'DO_SPLIT',1,'bool',...
                    'DO_BASELINE',1,'bool',...
                    'DO_BASELINE_RMS',0,'bool',...
                    'DO_BASELINE_USER',1,'bool',...
                    'DO_DELTAFOVERF',0,'bool',...
                    'DO_DETECT',1,'bool',...
                    'DO_DETECT_USER',1,'bool',...
                    'DO_DETECT_LOADTSDFC',1,'bool',...
                    'DO_DETECT_AUTO',1,'bool',...
                    'DO_DETECT_PACING',1,'bool',...
                    'DO_LAPLACIAN_INTERPOLATE',1,'bool',...
                    'DO_INTERPOLATE',0,'bool',...
                    'DO_INTEGRALMAPS',1,'bool',...
                    'DO_ACTIVATION',0,'bool',...
                    'DO_ACTIVATIONMAPS',1,'bool',...
                    'DO_FILTER',0,'bool',...
                    'NAVIGATION','apply','string',...
                    'DISPLAYTYPE',1,'integer',...
                    'DISPLAYTYPEF',1,'integer',...
                    'DISPLAYSCALING',1,'integer',...
                    'DISPLAYSCALINGF',1,'integer',...
                    'DISPLAYOFFSET',1,'integer',...
                    'DISPLAYGRID',1,'integer',...
                    'DISPLAYGRIDF',1,'integer',...
                    'DISPLAYLABEL',1,'integer',...
                    'DISPLAYLABELF',1,'integer',...
                    'DISPLAYTYPEF1',1,'integer',...
                    'DISPLAYTYPEF2',1,'integer',...
                    'DISPLAYPACING',1,'integer',...
                    'DISPLAYPACINGF',1,'integer',...
                    'DISPLAYGROUP',1,'vector',...
                    'DISPLAYGROUPF',1,'vector',...
                    'DISPLAYSCALE',1,'integer',...
                    'CURRENTTS',1,'integer',...
                    'ALIGNSTART','detect','integer',...
                    'ALIGNSIZE','detect','integer',...
                    'ALIGNMETHOD',1,'integer',...
                    'ALIGNSTARTENABLE',1,'integer',...
                    'ALIGNSIZEENABLE',1,'integer',...
                    'ALIGNRMSTYPE',1,'integer',...
                    'ALIGNTHRESHOLD',0.9,'double',...
                    'AVERAGEMETHOD',1,'integer',...
                    'AVERAGERMSTYPE',1,'integer',...
                    'AVERAGECHANNEL',1,'integer',...
                    'AVERAGEMAXN',5,'integer',...
                    'AVERAGEMAXRE',0.1,'double',...
                    'KEEPBADLEADS',1,'integer',...
                    'FIDSLOOPFIDS',1,'integer',...
                    'FIDSAUTOACT',1,'integer',...
                    'FIDSAUTOREC',1,'integer',...
                    'FIDSAUTOPEAK',1,'integer',...
                    'FIDSACTREV',0,'integer',...
                    'FIDSRECREV',0,'integer',...
                    'TSDFODIR','tsdf','string',...
                    'TSDFODIRON',1,'bool',...
                    'MATODIR','mat','string',...
                    'MATODIRON',1,'bool',...      %kann weg
                    'SCIMATODIR','scimat','string',...
                    'SCIMATODIRON',0,'bool',...
                    'ACTWIN',7,'integer',...
                    'ACTDEG',3,'integer',...
                    'ACTNEG',1,'integer',...
                    'RECWIN',7,'integer',...
                    'RECDEG',3,'integer',...
                    'RECNEG',0,'integer',...
                    'ALEADNUM',1,'integer',...
                    'ADOFFSET',0.2,'double',...
                    'ADISPLAYTYPE',1,'integer',...
                    'ADISPLAYOFFSET',1,'integer',...
                    'ADISPLAYGRID',1,'integer',...
                    'ADISPLAYGROUP',1,'vector',...
                    'OPTICALLABEL','','string',...
                    'FILTERFILE','','string',...
                    'FILTERNAME','NONE','string',...
                    'FILTERNAMES',{'NONE'},'string',...
                    'FILTER',[],'string',...
                    'INPUTTSDFC','','string'
            };
    global myScriptData;

    myScriptData = struct();
    myScriptData.TYPE = struct();
    myScriptData.DEFAULT = struct();

    for p=1:3:length(defaultsettings)
        if strncmp(defaultsettings{p+2},'group',5)
            myScriptData.(defaultsettings{p})={};
        else
            myScriptData.(defaultsettings{p})=defaultsettings{p+1};
        end
        myScriptData.TYPE.(defaultsettings{p})=defaultsettings{p+2};
        myScriptData.DEFAULT.(defaultsettings{p})=defaultsettings{p+1};
    end

    % now check if myScriptData.mat exists. If yes, load it (and thus
    % overwrite old myScriptData)
    myScriptDataFile=fullfile(pwd,'myScriptData.mat');
    myScriptData.SCRIPTFILE=myScriptDataFile;
    if exist(myScriptDataFile, 'file')==2
        load('myScriptData')
    else
        save('myScriptData','myScriptData');
    end
end


function initMyProcessingData()
% initializes myProcessingData with default values

    global myProcessingData myScriptData 
    myScriptData.DATAFILE=fullfile(pwd,'myProcessingData.mat'); %default to pwd
    if exist(myScriptData.DATAFILE,'file')    % if mpd exists in current folder, load it
        loadMyProcessingData
    else                                      % else set default and save that
        myProcessingData = struct;
        myProcessingData.SELFRAMES = {};
        myProcessingData.REFFRAMES = {};
        myProcessingData.AVERAGESTART = {};
        myProcessingData.AVERAGEEND = {};
        myProcessingData.FILENAME={};
        save(myScriptData.DATAFILE,'myProcessingData')
    end
    
    
end

function loadMyProcessingData()
    % just load myProcessingData from a mat file, if it exists. Thus the
    % old myProcessingData is overwritten
    global myScriptData myProcessingData; 
    if exist(myScriptData.DATAFILE,'file')           
        load(myScriptData.DATAFILE,'-mat');
    end
end

function ExportUserSettings(filename,index,fields)
    % save TS{index}.fids.(fields) in myProcessingData 
    % if fields doesnt exist in ts, it will be set to [] in mps. It's no
    % problem if field doesnt exist in mps at beginning
    
    global myProcessingData TS;
    % FIRST FIND THE FILENAME
    filenum = find(strcmp(filename,myProcessingData.FILENAME));

    % IF ENTRY DOES NOT EXIST MAKE ONE
    if isempty(filenum)
        myProcessingData.FILENAME{end+1} = filename;
        filenum = length(myProcessingData.FILENAME);
    end
    
    for p=1:length(fields)
        if isfield(TS{index},lower(fields{p}))
            value = TS{index}.(lower(fields{p}));
            if isfield(myProcessingData,fields{p})
                data = myProcessingData.(fields{p});
            else
                data = {};
            end
            data{filenum(1)} = value;
            myProcessingData.(fields{p})=data;
        else
            value = [];
            if isfield(myProcessingData,fields{p})
                data = myProcessingData.(fields{p});
            else
                data = {};
            end
            data{filenum(1)} = value;
            myProcessingData.(fields{p})=data;
        end
    end
    saveMyProcessingData;
    
end

function ImportUserSettings(filename,index,fields)
    % Imports the fields from myProcessingData in the corresponding ts structure of
    % TS. Identification via filename. 

    global myProcessingData TS;
    % FIRST FIND THE FILENAME
    filenum = find(strcmp(filename,myProcessingData.FILENAME'));
    % THEN RETRIEVE THE DATA FROM THE DATABASE
    
    if ~isempty(filenum)
        for p=1:length(fields)
            if isfield(myProcessingData,fields{p})
                data = myProcessingData.(fields{p});
                if length(data) >= filenum(1)
                    if ~isempty(data{filenum(1)})
                        TS{index}.(lower(fields{p}))=data{filenum(1)};
                    end
                end
            end
        end
    end
end

function saveMyProcessingData()
% analogous to function SaveScriptData
% 

    global myScriptData myProcessingData;
    
    save(myScriptData.DATAFILE,'myProcessingData');
end


function myUpdateFigure(handle)
% changes all Settings in the figure ( that belongs to handle) according to
% myScriptData.  %Updates everything, including File Listbox etc..

    global myScriptData;
    
    if isempty(myScriptData)
        initMyScriptData;    
    end
    
    fn = fieldnames(myScriptData);
    for p=1:length(fn)
        obj = findobj(allchild(handle),'tag',fn{p});
        if ~isempty(obj)
            objtype = myScriptData.TYPE.(fn{p});
            switch objtype
                case {'file','string'}
                    set(obj,'string',myScriptData.(fn{p}));
                case {'listbox'}
                    cellarray = myScriptData.(fn{p});
                    if ~isempty(cellarray) 
                        values = intersect(myScriptData.ACQFILENUMBER,myScriptData.ACQFILES);
                        set(obj,'string',cellarray,'max',length(cellarray),'value',values,'enable','on');
                    else
                        set(obj,'string',{'NO ACQ or AC2 FILES FOUND','',''},'max',3,'value',[],'enable','off');
                    end
                case {'double','vector','listboxedit','integer'}
                    set(obj,'string',mynum2str(myScriptData.(fn{p})));
                case {'bool'}
                    set(obj,'value',myScriptData.(fn{p}));
                case {'select'}   % case of dropdown menu to choose groups,  msd.GROUPSELECT
                    value = myScriptData.(fn{p});    % which group is selected
                    if value == 0, value = 1; end
                    set(obj,'value',value);
                    selectnames = myScriptData.GROUPNAME;
                    selectnames{end+1} = 'NEW GROUP';
                    set(obj,'string',selectnames);
                case {'groupfile','groupstring','groupdouble','groupvector','groupbool'}
                    group = myScriptData.GROUPSELECT;
                    if (group > 0)
                        set(obj,'enable','on','visible','on');
                        cellarray = myScriptData.(fn{p});
                        if length(cellarray) < group
                            cellarray{group} = myScriptData.DEFAULT.(fn{p});
                        end
                        switch objtype(6:end)
                            case {'file','string'}
                                set(obj,'string',cellarray{group});
                            case {'double','vector','integer'}
                                set(obj,'string',mynum2str(cellarray{group}));
                            case {'bool'}
                                set(obj,'value',cellarray{group});
                        end
                        myScriptData.(fn{p})=cellarray;
                    else
                        set(obj,'enable','inactive','visible','off');
                    end
            end
        end
    end
end


function getAC2Labels()
% get individual label of each .ac2 file in input folder and store them in
% MSD.ACQLABEL, used for SCRIPTDATA..
% orignial doesnt work, it always asigns msd.ASQLABEL='' 
end




function myUpdateGroups()
% not entirely sure..  like UpdateGroups, 
% sets default values for all the group cellarrays, if no values for a group have been set by the user
    global myScriptData;
    len = length(myScriptData.GROUPNAME);
    fn = fieldnames(myScriptData.TYPE);
    for p=1:length(fn)
        if strncmp(myScriptData.TYPE.(fn{p}),'group',5)   % GROUPNAME, GROUPLEADS, GROUPEXTENSION, GROUPEXTENSION, GROUPBADLEADS etc.  
            cellarray = myScriptData.(fn{p});
            default = myScriptData.DEFAULT.(fn{p});
            if length(cellarray) < len, cellarray{len} = default; end
            for q=1:len
                if isempty(cellarray{q}), cellarray{q} = default; end
            end
        end
    end
end

function GetACQFiles
% this function finds all files in ACQDIR and updates the following fields accordingly:
%     SCRIPT.ACQFILENUMBER     double array of the form
%     [1:NumberOfFilesDisplayedInListbox
%     SCRIPT.ACQLISTBOX        cellarray with strings for the listbox
%     SCRIPT.ACQFILENAME       cellarray with all filenames in ACQDIR
%     SCRIPT.ACQINFO           cellarray with a label for each file
%     SCRIPT.ACQFILES          double array of selected files in the
%     listbox
    

    global myScriptData;
   
    oldfilenames = {};
    if ~isempty(myScriptData.ACQFILES)
        for p=1:length(myScriptData.ACQFILES)
            if myScriptData.ACQFILES(p) <= length(myScriptData.ACQFILENAME)
                oldfilenames{end+1} = myScriptData.ACQFILENAME{myScriptData.ACQFILES(p)};
            end
        end
    end
    %oldfilenames is now  cellarray with filenamestrings of only the
    %selected files in listbox, eg {'Run0005.ac2'}, not of all files in dir
 
    
    
    
    olddir = pwd;
    %change into myScriptData.ACQDIR,if it exists and is not empty
    if ~isempty(myScriptData.ACQDIR)
        if exist(myScriptData.ACQDIR,'dir')
            if ~isempty(dir(myScriptData.ACQDIR))
                cd(myScriptData.ACQDIR);
            end
        end
    end
    
    
    filenames = {};
    exts = commalist(myScriptData.ACQEXT);  % create cellarray with all the allowed file extensions specified by the user
    for p=1:length(exts)
        d = dir(sprintf('*%s',exts{p}));
        for q= 1:length(d)
            filenames{end+1} = d(q).name;
        end
    end
    % filenames is cellarray with all the filenames of files in folder, like 
    %{'Ran0001.ac2'    'Ru0009.ac2'}
    
    filenames = sort(filenames);   
    
    options.scantsdffile = 1;
   
    myScriptData.ACQFILENUMBER = [];
    myScriptData.ACQLISTBOX= {};
    myScriptData.ACQFILENAME = {};
    myScriptData.ACQINFO = {};
    myScriptData.ACQFILES = [];
    
    if isempty(filenames)
        cd(olddir)
        return
    end
    
    h = waitbar(0,'INDEXING AND READING FILES'); drawnow;
    T = ioReadTSdata(filenames,options);    % read in all the file data in cellarray T
    waitbar(0.8,h);
    
    for p = 1:length(T)
        if ~isfield(T{p},'time'), T{p}.time = 'none'; end
        if ~isfield(T{p},'label'), T{p}.label = 'no label'; end
        myScriptData.ACQFILENUMBER(p) = p;
        myScriptData.ACQLISTBOX{p} = sprintf('%04d % 35s   %12s  %40s',myScriptData.ACQFILENUMBER(p),T{p}.filename,T{p}.time,T{p}.label);
        myScriptData.ACQFILENAME{p} = T{p}.filename;
        myScriptData.ACQINFO{p} = T{p}.label;
    end
    
    [~,~,myScriptData.ACQFILES] = intersect(oldfilenames,myScriptData.ACQFILENAME);
    myScriptData.ACQFILES = sort(myScriptData.ACQFILES);
    
    waitbar(1,h); drawnow;
    close(h);
    
    cd(olddir);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Callback functions %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Browse(handle,ext,mode)
%callback function for the browse buttons
    global myScriptData;
    if nargin == 1
        ext = 'mat';
        mode = 'file';
    end
    
    if nargin == 2
        mode = 'file';
    end
    
    updateACQFile=0;
    if nargin == 3 && strcmp(mode, 'input')
      updateACQFile=1;
      mode='dir';
    end
    
    tag = get(handle,'tag');
    tag = tag(8:end);
    
    filename = myScriptData.(tag);
    
    switch mode
        case 'file'
            [fn,pn] = uigetfile(['*.' ext],'SELECT FILE',filename);
            if (fn == 0), return; end
            myScriptData.(tag)=fullfile(pn,fn);
        case 'dir'
            pn  = uigetdir(pwd,'SELECT DIRECTORY');
            if (pn == 0), return; end
            myScriptData.(tag)=pn;   
    end
    
    parent = get(handle,'parent');
    myUpdateFigure(parent);
    
    if updateACQFile
        myUpdateACQFiles(handle)
    end
end


function myUpdateACQFiles(~)
% callback function to "Choose Input Directory"

% this function:
%   - Updates MSD.acqdir
%   - Updates MSD.FileLabels  (by calling getAC2Labels )
%   - calls GetAC2Files
%           - update ACQFILENUMBER, ACQFILENAME, ACQINFO, ACQLISTBOX  by
%           already initialising the TS cell!
%   - Update screen by calling myUpdateFigure

    getAC2Labels;   % upate msd.ACQLABEL
    GetACQFiles;    %update all the file related cellarrays, load files into TS cellarray
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));



end




function setScriptData(handle, mode)
% callback function to almost all buttons on the Settings and the Main Menu
% Display
% It updates myScriptData with the user input made on the Settings and the Main Menu
% Display
% After that, it updates the Displays again with the updated data from
% myScriptData (by calling myUpdateFigure) 

% notes on how it works:
% the tag property of each object in the figure display is used to locate that object
% the tag of each each grafic object is also the fieldname of the
% corresponding fiel in myScriptData.  To further differentiate how each
% object is being dealt, the objecttype=myScriptData.TYPE.(tag) is used.

    global myScriptData;
    tag = get(handle,'tag');     
    if isfield(myScriptData.TYPE,tag)
        objtype = myScriptData.TYPE.(tag);
    else
        objtype = 'string';
    end
    switch objtype
        case {'file','string'}
            myScriptData.(tag)=get(handle,'string');
        case {'double','vector','integer'}
            myScriptData.(tag)=mystr2num(get(handle,'string'));
        case 'bool'
            myScriptData.(tag)=get(handle,'value');
        case 'select'
            myScriptData.(tag)=get(handle,'value');
        case 'listbox'
            myScriptData.ACQFILES = myScriptData.ACQFILENUMBER(get(handle,'value'));
        case {'listboxedit'}
            myScriptData.(tag)=mystr2num(get(handle,'string'));
        case {'groupfile','groupstring','groupdouble','groupvector','groupbool'}
            group = myScriptData.GROUPSELECT;
            if (group > 0)
                if isfield(myScriptData,tag)
                    cellarray = myScriptData.(tag);
                else
                    cellarray = {};
                end
                switch objtype(6:end)
                    case {'file','string'}
                        cellarray{group} = get(handle,'string');
                    case {'double','vector'}
                        cellarray{group} = mystr2num(get(handle,'string'));
                    case {'bool'}
                        cellarray{group} = get(handle,'value');
                end
                myScriptData.(tag)=cellarray;
            end
    end
    if nargin == 2
        if strcmp(mode,'input')   %if call was by input bar
            getAC2Labels;   % upate msd.ACQLABEL
            GetACQFiles;    %update all the file related cellarrays, load files into TS cellarray
        end
    end
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));    

end



function loadSettings(handle)
% callback function to the 'load settings from file' button
% - asks user for a myScriptData.mat file
% - loads the data of the chosen myScriptData in the myScriptData struct
% - uptdates all gui objects with data from myScriptData
% - sets myScriptData.SCRIPTFILE to the full path of the chosen
%    myScriptData.mat file
    
    global myScriptData;
    [filename,pathname] = uigetfile('*.mat','Choose myScriptData file');
    filename = fullfile(pathname,filename);
    
    if exist(filename,'file')
        load(filename,'-mat');        
    end      
    myUpdateACQFiles(handle);
    myUpdateGroups;
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));
    
    myScriptData.SCRIPTFILE=filename;

end 


function saveSettings(~)
%callback function for Save Settings Button
% save myScriptData as a matfile in the filename/path specified in
% myScriptData.SCRIPTFILE
    global myScriptData;
    filename = myScriptData.SCRIPTFILE;
    save(filename,'myScriptData','-mat');
end



function removeGroup(handle)
%callback function to 'Remove this Group' button

    global myScriptData;
    group = myScriptData.GROUPSELECT;
    if group > 0
       fn = fieldnames(myScriptData.TYPE);
       for p=1:length(fn)
           if strncmp(fn{p},'GROUP',5)
               cellarray = myScriptData.(fn{p});
               ind = 1:length(cellarray);
               ind = ind(find(ind ~= group));
               cellarray = cellarray(ind);
               myScriptData.(fn{p})=cellarray;
           end
       end
       myScriptData.GROUPSELECT = 0;
   end
   
   myUpdateFigure(handle);

end

function selectAllACQ(~)
%callback function to "select all" button at file listbox
    global myScriptData;
    myScriptData.ACQFILES = myScriptData.ACQFILENUMBER;
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));
end

function selectNoneACQ(~)
%callback to 'clear selection' button
    global myScriptData;
    myScriptData.ACQFILES = [];
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));
end

function ACQselectLabel(~)
%callback to 'select label containing..' 
    
    global myScriptData;
    pat = myScriptData.ACQPATTERN;
    sel = [];
    for p=1:length(myScriptData.ACQINFO),
        if ~isempty(strfind(myScriptData.ACQINFO{p},pat)), sel = [sel myScriptData.ACQFILENUMBER(p)]; end
    end
    myScriptData.ACQFILES = sel;
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));
end

function openSettings(~)
%callback to 'Settings Windwow'
handle=SettingsDisplay;
myUpdateFigure(handle)


end

function runScript(handle)
%callback to 'apply' button, this starts the whole processing process!

%this function
%   - saves all settings in msd.SCRIPTFILE, just in case programm crashes
%   - checks if all settings are correkt (in particular, if groups have
%     been selected
%   - loads myProcessingData
%   - calls PreLoopScript, which:
%       - find a individual label for each file (for MPD) (havent really
%       figuret that out yet
%       - checks if mapfile etc exist (I do that already earlier?!)
%       - generates a CALIBRATION file, if none is supplied but
%       Do_Calibration is on
%       - sets up SCRIPT.GBADLEADS,  SCRIPT.MAXLEAD and mpd.LIBADLEADS
%       mpd.LI, ALIGNSTART, ALIGNSIZE
%   - starts the MAIN LOOP: for each file:  Process file
%   - at very end when everything is processed: update figure and groups
%       
    global myScriptData

    saveSettings(handle);
    
    loadMyProcessingData;  
    
    h = [];   %for waitbar
%     olddir =pwd;      %why?     seems not important TODO
%     cd(myScriptData.PWD);
    
    PreLoopScript;
    saveSettings(handle);

    if isempty(myScriptData.GROUPNAME)
        errordlg('you need to define groups for processing the data');
        return;
    end

    %% MAIN LOOP %%%
    acqfiles = unique(myScriptData.ACQFILES);
    h  = waitbar(0,'SCRIPT PROGRESS'); drawnow;

    p = 1;
    while (p <= length(acqfiles))

        myScriptData.ACQNUM = acqfiles(p);            
        ProcessACQFile(myScriptData.ACQFILENAME{acqfiles(p)},myScriptData.ACQDIR);

        switch myScriptData.NAVIGATION
            case 'prev'
                p = p-1; 
                if p == 0, p = 1; end
                continue;
            case {'redo','back'}
                continue;
            case 'stop'
                break;
        end
        waitbar(p/length(acqfiles),h);
        p = p+1;
    end

    close(h);
    
    myUpdateGroups;
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU')); 
    
    disp('fertig')
end



%%%%%%%%%%%%%%script functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function PreLoopScript
    %this function is called right before main loop starts. Its jobs are: 
%       - checks if mapfile etc exist (I do that already earlier?!)
%       - generates a CALIBRATION file, if none is supplied but
%       Do_Calibration is on
%       - set up SCRIPT.GBADLEADS,  SCRIPT.MAXLEAD and mpd.LIBADLEADS
%       mpd.LI, ALIGNSTART, ALIGNSIZE
    

    global myScriptData myProcessingData   
    myScriptData.ALIGNSTART = 'detect';
    myScriptData.ALIGNSIZE = 'detect';
     
    
    %%%% -create filenames, which holds all the filename-strings of only the files selected by user.  
    % -create index, which holds all the indexes of filenames, that contain '-acq' or '.ac2'
    filenames = myScriptData.ACQFILENAME(myScriptData.ACQFILES);    % only take the files selected by the user
    index = [];
    for r=1:length(filenames)
        if ~isempty(strfind(filenames{r},'.acq')) || ~isempty(strfind(filenames{r}, '.ac2')), index = [index r]; end
    end   
    
    
    
    if ~isempty(index)
        
        %%%% check mapping file, eg for existes %%%%%%%%%%%%%%%%%%%%%% 
        mappingfile = myScriptData.MAPPINGFILE;
        if isempty(mappingfile)
            % MAKE SURE mappingfile IS OF STRING TYPE
            % THESE MAKES CODING DOWNSTREAM MORE EASY
            mappingfile = '';
        elseif ~exist(mappingfile,'file')
            errordlg('The mapping file does not exist');
            error('ERROR')
        end  
    
    
        
        %%%%%%  start generating calibration file %%%%%%%%%%%%%%%
        %% somehwhere here sigCalibrate8 is called
        if myScriptData.DO_CALIBRATE == 1  % if 'calibrate Signall' button is on
            
            %%% if no calibration file and no CALIBRATIONACQ is given: exit
            %%% and make error message
            if isempty(myScriptData.CALIBRATIONACQ) && isempty(myScriptData.CALIBRATIONFILE)
                errordlg('Specify the filenumbers of the calibration measurements or a calibration file');
                error('ERROR'); 
            end   
		    
            %%% if cal is empty, initialise it as 'calibration.cal8'
            if isempty(myScriptData.CALIBRATIONFILE)
                myScriptData.CALIBRATIONFILE = 'calibration.cal8';
            end
            
            
            %%% if file ext is .'cal', change it to '.cal8'
            calfile = myScriptData.CALIBRATIONFILE;
            [pn,fn,ext] = fileparts(calfile); 
            if (strcmp(ext,'.cal') ~= 1)
                calfile = fullfile(pn,[fn '.cal8']);
            end
            
            
            %%% if calfile doesnt exist OR msd.MAPPINGFILE is not
            %%% msd.CALIBRATIONMAPPINGUSED OR msd.CALIBRATIONACQ und
            %%% CALIBRATIONACQUSED dont match exactly
		    if ~isempty(myScriptData.CALIBRATIONACQ)
			    if (~exist(calfile,'file')) || (strcmp(myScriptData.MAPPINGFILE,myScriptData.CALIBRATIONMAPPINGUSED) ~= 1) | ( ~isempty(setxor(myScriptData.CALIBRATIONACQ,myScriptData.CALIBRATIONACQUSED))), 
				    %for comptability with either ac2 or acq files
                    if ~isempty(strfind(myScriptData.ACQEXT,'.acq'))
                    acqcalfiles = ioACQFilename(myScriptData.ACQLABEL,myScriptData.CALIBRATIONACQ);
                    else
                        acqcalfiles = ioAC2Filename(myScriptData.ACQLABEL,myScriptData.CALIBRATIONACQ);
                    end
                    
				    if ~iscell(acqcalfiles), acqcalfiles = {[acqcalfiles]}; end 
				    for p=1:length(acqcalfiles), acqcalfiles{p} = fullfile(myScriptData.ACQDIR,acqcalfiles{p}); end
				    pointer = get(gcf,'pointer'); set(gcf,'pointer','watch');
				    sigCalibrate8(acqcalfiles{:},mappingfile,calfile,'displaybar');
				    set(gcf,'pointer',pointer);                    myScriptData.CALIBRATIONFILE = calfile;
				    myScriptData.CALIBRATIONACQUSED = myScriptData.CALIBRATIONACQ;
				    myScriptData.CALIBRATIONMAPPINGUSED = myScriptData.MAPPINGFILE;
			    end
		    end 
        end
    end
    %% end calibration file %%%
    
    
    
    %%%% RENDER A GLOBAL LIST OF ALL THE BADLEADS,  set msd.GBADLEADS%%%%  
    for p=1:length(myScriptData.GROUPBADLEADS)
        badleads = myScriptData.GROUPBADLEADS{p};
        if ~isempty(myScriptData.GROUPBADLEADSFILE{p})
            bfile = load(myScriptData.GROUPBADLEADSFILE{p},'-ASCII');
            badleads = union(bfile(:)',badleads);
        end
        
        leads = myScriptData.GROUPLEADS{p};
        ind = find((badleads>0)&(badleads<=length(leads)));
        badleads = badleads(ind);
        myScriptData.GBADLEADS{p} = badleads;
    end
    % bad leads from badleadsfile now alsow used
    % now GBADLEADS are only lead index between 1 and length(leads) (why?) 
    % start counting at 1 for each group?!
    
    
    %%%% FIND MAXIMUM LEAD
    maxlead = 1;
    for p=1:length(myScriptData.GROUPLEADS)
        maxlead = max([maxlead myScriptData.GROUPLEADS{p}]);
    end
    myScriptData.MAXLEAD = maxlead;
    
    
    
    
    if myScriptData.DO_INTERPOLATE == 1
        
        if myScriptData.DO_SPLIT == 0
            errordlg('Need to split the signals before interpolation');
            error('ERROR');
        end
        
        for q=1:length(myScriptData.GROUPNAME)
            myProcessingData.LIBADLEADS{q} = [];   % TRIGGER INITIATION
            myProcessingData.LI{q} = [];
        end
    end
end






function ProcessACQFile(inputfilename,inputfiledir)

%this function does all the processing, in particular:
% - checks if mappingfile and calibration file exist and loads
% inputfilename in TS using all available files
% - check if potvals are in accourdance with group lead choise 
% - do pacing stuff (get rid of???)
% - ImportUserSettings
% - store GBADLEADS in TS
% - DO Temporal Filter of ts
% - DO THE SCLICING STUFF:
%        - call SliceDisplay
%        - some Navigation stuff
%        -  does some upgrades to bad leads 
%        -  ExportUserSettings
%        - calls sigSlice, which in this case:  updates TS{currentIndex} bei
%           keeping only the timeframe-window specified (does it change to
%           local or global frame for fids?) 
% - Do 'blank leads', if that option is selected
% - DO ALL THE BASELINE STUFF
%       - shift fiducials to local frame (I think?!)
%       - Do 'Pre-RMS baseline correction (call sigBaseline) if that button
%       is pressed
%       - if DO_BASELINE_USER:  open FidsDisplay. User chosses bl fids,
%       which are stored in .. fids of type 16!?
%       - some navigation stuff  & ExportUserSettings
%       - Do_DeltaFoverF if selected (get rid of??)
%       - Do baseline correction, call sigBaseLine(index,[],baselinewidth),
%       which asks for fidsFindFids(..'baseline') to get blpts..
% - DO_LABLACIAN_INTERPOLATE, if selected.
% - Detect the other fiducials, if user interaction is on
%       - do fids shift, same as before with baseline
%       - correct baseline values, just as before (why?)
%       - open FidsDisplay, in mode 1 this time, do navigation stuff and
%       Export User Settings
% - split current ts into n_groups sub-ts structures, delete original ts
% - Do_interpolation again, for each sub-ts
% - SAVE the ts structures, 
% - do integral maps, if selected and save them
% - do Activation maps, if that option is selected


    olddir = pwd;
    global myScriptData TS SCRIPTDATA;
    

%%%%% create cellaray files={full acqfilename, mappingfile, calibration file}, if the latter two are needet & exist    
    filename = fullfile(inputfiledir,inputfilename);
    [d1,d2,ext] = fileparts(inputfilename); 
    files{1} = filename;
    if ~isempty(myScriptData.MAPPINGFILE)
        files{end+1} = myScriptData.MAPPINGFILE;
    end
    if myScriptData.DO_CALIBRATE == 1
        if ~isempty(myScriptData.CALIBRATIONFILE)
            if exist(myScriptData.CALIBRATIONFILE,'file')
                files{end+1} = myScriptData.CALIBRATIONFILE;
            end
        end
    end
    

%%%%%%% read in the files in TS.  index is index with TS{index}=current ts
%%%%%%% structure
    index = ioReadTS(files{:});
 
    

    
%%%%%% check if dimensions of potvals are correct, issure error msg if not
    if size(TS{index}.potvals,1) < myScriptData.MAXLEAD
        errordlg('Maximum lead in settings is greater than number of leads in file');
        cd(olddir);
        error('ERROR');
    end
    

    
%%% set up Pacing Lead %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(myScriptData.PACINGLEAD) && (myScriptData.PACINGLEAD > 0) && (myScriptData.PACINGLEAD <= size(TS{index}.potvals,1))
         sigDetectPacing(index,myScriptData.PACINGLEAD);  
        % CURRENTLY BLANK THE DETECTED FIDUCIALS AS WE WON'T USE THEM RIGHT
        % NOW. THE PACING IS ALSO STORED AS A VECTOR IN PACING, WHICH IS
        % MORE ACCESSIBLE.      
        TS{index}.fids = [];
        TS{index}.fidset = {};
    end
    
    
    
%%%% ImportUserSettings (put Data from myProcessingData in TS{currentTS} %%%%%%%%%%    
    fieldstoload = {'SELFRAMES','AVERAGEMETHOD','AVERAGESTART','AVERAGECHANNEL','AVERAGERMSTYPE','AVERAGEEND','AVERAGEFRAMES','TEMPLATEFRAMES'};
    if myScriptData.DO_ADDBADLEADS, fieldtoload{end+1} = 'LEADINFO'; end   % DO_ADDBA.. doesnt exist.. remove? TO DO
        
    ImportUserSettings(inputfilename,index,fieldstoload);
    

    
    
%%%%  store the GBADLEADS also in the ts structure (in ts.leadinfo)%%%%          
    for p=1:length(myScriptData.GBADLEADS), tsSetBad(index,myScriptData.GBADLEADS{p}); end
    % I feel like this is done wrong! if gr1=1:10 and gr2=11:20 and
    % gr1_badleads=[1, 2] and gr2_badleads=[2 15],  only
    % leadinfo([1,2,3])=1.  15 is out of 1:length(groupleads von gr2 )  ...

    

%%%%% do the temporal filter of current file %%%%%%%%%%%%%%%%
% this uses the matlab 'filter' function, which uses a rational transfer
% function
% some more notes on this:
% initialised as follows:
%     'FILTERNAME','NONE','string',...
%     'FILTERNAMES',{'NONE'},'string',...
%     'FILTER',[],'string',...
% and then all ov above is never changed again or is a tag..
    if myScriptData.DO_FILTER      % if 'apply temporal filter' is selected
        if 0 %isfield(myScriptData,'FILTER')     % this doesnt work atm, cause buttons for Filtersettings etc have been removed
            myScriptData.FILTERSETTINGS = [];
            for p=1:length(myScriptData.FILTER)
                if strcmp(myScriptData.FILTER(p).label,myScriptData.FILTERNAME)
                    myScriptData.FILTERSETTINGS = myScriptData.FILTER(p);
                end
            end
        else
            myScriptData.FILTERSETTINGS.B = [0.03266412226059 0.06320942361376 0.09378788647083 0.10617422096837 0.09378788647083 0.06320942361376 0.03266412226059];
            myScriptData.FILTERSETTINGS.A = 1;
        end

        myTemporalFilter(index);    % no add audit? shouldnt it be recordet somewhere that this was filtered??? TODO
    end
        

%%%%%  call SliceDisplay (if UserInterface is selected) %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this block does the following:
% - call SliceDisplay
% - some Navigation stuff
% -  does some upgrades to bad leads 
% - calls sigSlice, which in this case:  updates TS{currentIndex} bei
% keeping only the timeframe-window specified in ts.selframes
    



    if myScriptData.DO_SLICE == 1   % DO_SLICE is 1 by default and is never changed, so always 1 -> obsolete?! DOTO  
        if myScriptData.DO_SLICE_USER == 1  %if 'user interaction' button is pressed
            handle = mySliceDisplay(index); % this only changes selframes? I think it also uses ts.averageframes (and all from export userlist bellow?)
            waitfor(handle);
           

            

            
            switch myScriptData.NAVIGATION
                case {'prev','next','stop','back'}, cd(olddir); tsClear(index); return; 
            end
            
            % RELOAD THE BADLEADSETTINGS INTO THE USERINTERFACE
            % REMEMBER BADLEADS ARE RECORDED AS THE NUMBER OF THE LEAD ON
            % THAT PARTICULAR SURFACE. SO WE NEED TO TRANSLATE THEM BACK TO
            % THE LOCAL SYSTEM. HENCE THE intersect COMMAND
            
            
            if myScriptData.KEEPBADLEADS == 1
                badleads = tsIsBad(index);
                for p=1:length(myScriptData.GROUPBADLEADS) 
                    [~,localindex] = intersect(myScriptData.GROUPLEADS{p},badleads);
                    myScriptData.GROUPBADLEADS{p} = localindex;
                end
            end
            
            % SO STORE ALL THE SETTINGS/CHANGES WE MADE
            
            ExportUserSettings(inputfilename,index,{'SELFRAMES','AVERAGEMETHOD','AVERAGECHANNEL','AVERAGERMSTYPE','AVERAGESTART','AVERAGEEND','AVERAGEFRAMES','TEMPLATEFRAMES','LEADINFO'});
        end
        % CONTINUE AND DO THE SLICING/AVERAGING OPERATION

%         global ats ets  TODO  remove this
         TS{index}.('selframes')=[300,500];
%         ats=TS{index};
        sigSlice(index);   % keeps only the selected timeframes in the potvals, using ts.selframes as start and endpoint
        % this also uses ts.averageframe, if exist!
%         ets=TS{index};
    end
    
%%%%%% if 'blank bad leads' button is selected,   set all values of the bad leads to 0   
    if myScriptData.DO_BLANKBADLEADS == 1
        badleads = tsIsBad(index);
        TS{index}.potvals(badleads,:) = 0;
        tsSetBlank(index,badleads);
        tsAddAudit(index,'|Blanked out bad leads');
    end

    
    
    
 %%%%%% import more Usersettings from myProcessingData into TS{index} %%%%
    fieldstoload = {'FIDS','FIDSET','STARTFRAME'};
    ImportUserSettings(inputfilename,index,fieldstoload);
    
    
%%%%%%%%%% start baseline stuff %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (myScriptData.DO_BASELINE == 1)||(myScriptData.DO_DELTAFOVERF == 1)
        
    
    %%%% shift fiducial shift ficucials to the new local frame %%%%%%%%%%%%
    % fids are always in local frame, but because user selected new local
    % frame (the selframe), the local frame changed!
        if ~isfield(TS{index},'startframe'), TS{index}.startframe = 1; end
        newstartframe = TS{index}.selframes(1);  
        oldstartframe = TS{index}.startframe(1);          
        fidsShiftFids(index,oldstartframe-newstartframe);    
        TS{index}.startframe = newstartframe;  % TODO shouldnt this be directly after the slicing? fits better inhaltlich
        
 
    %%%%  get baseline (the intervall ) from TS (so default or from ImportSettings. If values are weird, set to [1, numframes]
    % and set that as new fiducial
        baseline = fidsFindFids(index,'baseline');
        framelength = size(TS{index}.potvals,2);
        baselinewidth = myScriptData.BASELINEWIDTH;       % also upgrade baselinewidth
        TS{index}.baselinewidth = baselinewidth;
        if length(baseline) < 2
            fidsRemoveFiducial(index,'baseline');
            fidsAddFiducial(index,1,'baseline');
            fidsAddFiducial(index,framelength-baselinewidth+1,'baseline');
        end
     
        
    %%%% if 'Pre-RMS Baseline correction' button is pressed, do baseline
    %%%% corection of current index (before user selects anything..
        if myScriptData.DO_BASELINE_RMS == 1
            baselinewidth = myScriptData.BASELINEWIDTH;
            sigBaseLine(index,[],baselinewidth);
        end
        
        
        
    %%%%   open Fidsdisplay in mode 2, let user select fids, also do some navigation 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if myScriptData.DO_BASELINE_USER == 1
            handle = FidsDisplay(index,2);    % this changes fids, but nothing else
            waitfor(handle);
            switch myScriptData.NAVIGATION
                case {'prev','next','stop','redo','back'}, cd(olddir); tsClear(index); return; 
            end     
        end
    %%%% and save user selections in myProcessingScript    
        ExportUserSettings(inputfilename,index,{'SELFRAMES','AVERAGEMETHOD','AVERAGECHANNEL','AVERAGERMSTYPE','AVERAGESTART','AVERAGEEND','AVERAGEFRAMES','TEMPLATEFRAMES','LEADINFO','FIDS','FIDSET','STARTFRAME'});

        
        
        
    %%%% Do_DeltaFOVERF, if that option is selected  (get rid of??)
        if myScriptData.DO_DELTAFOVERF == 1 
            fidsFindFids(index,20)
            fidsFindFids(index,21)
            if isempty(fidsFindFids(index,20))||isempty(fidsFindFids(index,21))  %this is always the case?! since 20 and 21 dont exist in fids fkt
                han = errordlg('No interval specified for DetlaF over F correction, skipping correction');
                waitfor(han);
            else            
                sigDeltaFoverF(index);
            end
        end          
        
        
    %%%% now do the final baseline correction
        if myScriptData.DO_BASELINE == 1
            baselinewidth = myScriptData.BASELINEWIDTH;
            if length(fidsFindFids(index,'baseline')) < 2 
                han = errordlg('At least two baseline points need to be specified, skipping baseline correction');
                waitfor(han);
            else
                sigBaseLine(index,[],baselinewidth);
            end
        end    
        
  
    end
    
    
    return
    
    %%% Do_LAPLACIAN_INTERPOLATE %%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if myScriptData.DO_LAPLACIAN_INTERPOLATE == 1
         
        splitgroup = [];
        for p=1:length(myScriptData.GROUPNAME)
            if myScriptData.GROUPDONOTPROCESS{p} == 0, splitgroup = [splitgroup p]; end
        end
        
        for q=1:length(splitgroup)
            
            if isempty(myScriptData.GBADLEADS{splitgroup(q)})
                continue;
            end
                
            if ~isfield(myScriptDataDATA,'LIBADLEADS')
                myScriptDataDATA.LIBADLEADS{q} = [];
            end
            
            if ~isempty(setdiff(myScriptData.GBADLEADS{splitgroup(q)},myProcessingData.LIBADLEADS{q}))
                myProcessingData.LI{splitgroup(q)} = [];
                
                if myScriptData.GROUPDONOTPROCESS{splitgroup(q)} == 1
                    continue;
                end
                
                files = {};
                files{1} = myScriptData.GROUPGEOM{splitgroup(q)};
                if isempty(files{1})
                    continue;
                end
                if ~isempty(myScriptData.GROUPCHANNELS{splitgroup(q)})
                    files{2} = myScriptData.GROUPCHANNELS{splitgroup(q)};
                end

                SCRIPTDATA.LI{splitgroup(q)} = sparse(triLaplacianInterpolation(files{:},SCRIPT.GBADLEADS{splitgroup(q)},length(SCRIPT.GROUPLEADS{splitgroup(q)})));
            end
            
            if isempty(SCRIPTDATA.LI{splitgroup(q)})
                continue;
            end
            
            leads = myScriptData.GROUPLEADS{splitgroup(q)};
            
            TS{index}.potvals(leads,:) = SCRIPTDATA.LI{splitgroup(q)}*TS{index}.potvals(leads,:);
            tsSetInterp(index,leads(myScriptData.GBADLEADS{splitgroup(q)}));
          
        end
        tsAddAudit(index,'|Interpolated bad leads (Laplacian interpolation)');
    end
    
    
    
    %%%%%%%% now detect the rest of fiducials, if 'detect fids' was selected   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fieldstoload = {'FIDS','FIDSET','STARTFRAME'};
    ImportUserSettings(inputfilename,index,fieldstoload);
    
    if myScriptData.DO_DETECT == 1
        
        %%% fids shift, same as in baseline stuff, to get to local frame?!
        if ~isfield(TS{index},'startframe'), TS{index}.startframe = 1; end      
        newstartframe = TS{index}.selframes(1);
        oldstartframe = TS{index}.startframe(1);        
        fidsShiftFids(index,oldstartframe-newstartframe);    
        TS{index}.startframe = newstartframe;
        
        
        %%% check if baseline values are correct. if not, choose [1,
        %%% lastframe] (why is this here again?)
        baseline = fidsFindFids(index,'baseline');
        framelength = size(TS{index}.potvals,2);
        baselinewidth = myScriptData.BASELINEWIDTH;
        if length(baseline) < 2
            fidsRemoveFiducial(index,'baseline');
            fidsAddFiducial(index,1,'baseline');
            fidsAddFiducial(index,framelength-baselinewidth+1,'baseline');
        end
        
        
        %%%%%% open FidsDisplay again, this time to select fiducials
        if myScriptData.DO_DETECT_USER == 1
            handle = FidsDisplay(index);
            waitfor(handle);
            switch myScriptData.NAVIGATION
                case {'prev','next','stop','redo','back'}, cd(olddir); tsClear(index); return; 
            end     
        end    
        % save the user selections (stored in ts) in myProcessingData
        ExportUserSettings(inputfilename,index,{'SELFRAMES','AVERAGEMETHOD','AVERAGERMSTYPE','AVERAGECHANNEL','AVERAGESTART','AVERAGEEND','AVERAGEFRAMES','TEMPLATEFRAMES','LEADINFO','FIDS','FIDSET','STARTFRAME'});
    end
    
    
    
    
    %%%% this blog does the splitting. In detail it
    % - creates numgroups new ts structures (one for each group) using
    % tsSplitTS
    % - it sets ts.'tsdfcfilename' to myScriptData.GROUPTSDFC(splitgroup)
    % - it sets ts.filename to  exact the same..  'including some tsdf
    % stuff
    % - original ts (the one thats splittet) is cleared
    % - index is now index array of the splittet sub ts!!
    
    %I think this part needs some updating (get rid of tsdf) TODO
    
    if myScriptData.DO_SPLIT == 1     % DO_SPLIT is never changed?! Remove it? TODO
        splitgroup = [];
        for p=1:length(myScriptData.GROUPNAME)
            if myScriptData.GROUPDONOTPROCESS{p} == 0, splitgroup = [splitgroup p]; end
        end
        % splitgroup is now eg [1 3] if there are 3 groups but the 2 should
        % not be processed
        
        channels=myScriptData.GROUPLEADS(splitgroup);
        newfileexts=ioUpdateFilename('.tsdf',inputfilename,myScriptData.GROUPEXTENSION(splitgroup));
        indices = tsSplitTS(index,channels,newfileexts);  %the new ts have a field called newfileext
        
        tsDeal(indices,'filename',ioUpdateFilename('.mat',inputfilename,myScriptData.GROUPEXTENSION(splitgroup))); 
        tsSet(indices,'newfileext','');  % now that new field is set to ''
        tsClear(index);        
        index = indices;
    end

    
    
    %%%% do trilaplacian interpolation for each ts 
    if myScriptData.DO_INTERPOLATE == 1     % if second 'Interpolate' button is on
        if myScriptData.DO_SPLIT == 0
            error('Need to split the signal before interpolating');
        end
        for q=1:length(index)    %remember, index is now array
            
            if isempty(myScriptData.GBADLEADS{splitgroup(q)})
                continue;
            end
                
            if ~isempty(setdiff(myScriptData.GBADLEADS{splitgroup(q)},SCRIPTDATA.LIBADLEADS{q}))
                SCRIPTDATA.LI{splitgroup(q)} = [];
                
                if myScriptData.GROUPDONOTPROCESS{splitgroup(q)} == 1
                    continue;
                end
                
                files = {};
                files{1} = myScriptData.GROUPGEOM{splitgroup(q)};
                if isempty(files{1})
                    continue;
                end
                if ~isempty(myScriptData.GROUPCHANNELS{splitgroup(q)})
                    files{2} = myScriptData.GROUPCHANNELS{splitgroup(q)};
                end

                SCRIPTDATA.LI{splitgroup(q)} = sparse(triLaplacianInterpolation(files{:},SCRIPT.GBADLEADS{splitgroup(q)},length(myScriptData.GROUPLEADS{splitgroup(q)})));
            end
            
            if isempty(SCRIPTDATA.LI{splitgroup(q)})
                continue;
            end
            
            TS{index(q)}.potvals = SCRIPTDATA.LI{splitgroup(q)}*TS{index(q)}.potvals;
            tsSetInterp(index(q),myScriptData.GBADLEADS{splitgroup(q)});
            tsAddAudit(index(q),'|Interpolated bad leads (Laplacian interpolation)');
            
        end
    end
    
    myScriptData.MATODIRON
    %%%% save the new ts structures using ioWriteTS
    if myScriptData.MATODIRON == 1   %TODO    do I ever want this to be off?

        olddir = cd(myScriptData.MATODIR);
        tsDeal(index,'filename',ioUpdateFilename('.mat',inputfilename,myScriptData.GROUPEXTENSION(splitgroup)));
        ioWriteTS(index,'noprompt','oworiginal');
        cd(olddir);
    end
    

    
    %%%% do integral maps and save them  --> I worry about this later
    if myScriptData.DO_INTEGRALMAPS == 1
        if myScriptData.DO_DETECT == 0
            error('Need fiducials to do integralmaps');
        end
        mapindices = fidsIntAll(index);

        if (myScriptData.MATODIRON==1)
            olddir = cd(myScriptData.MATODIR); 
            tsDeal(mapindices,'filename',ioUpdateFilename('.mat',inputfilename,myScriptData.GROUPEXTENSION(splitgroup),'-itg')); 
            tsSet(mapindices,'newfileext','');
            ioWriteTS(mapindices,'noprompt','oworiginal');
            cd(olddir);
        end     
        tsClear(mapindices);
    end
    
    
   if myScriptData.DO_ACTIVATIONMAPS == 1
        if myScriptData.DO_DETECT == 0
            error('Need fiducials to do activation maps');
        end
        mapindices = sigActRecMap(index);
        
        if (myScriptData.MATODIRON == 1)
            olddir = cd(myScriptData.MATODIR);
            tsDeal(mapindices,'filename',ioUpdateFilename('.mat',inputfilename,myScriptData.GROUPEXTENSION(splitgroup),'-ari')); 
            tsSet(mapindices,'newfileext','');
            ioWriteTS(mapindices,'noprompt','oworiginal');
            cd(olddir);
        end       
        tsClear(mapindices);
        s = tsNew(length(index));
        
        for j=1:length(index)
            acttime = floor(fidsFindLocalFids(index(j),'act'));
            acttime = round(median([ones(size(acttime)) acttime  (TS{index(j)}.numframes-1)*ones(size(acttime))],2));
            for p=1:TS{index(j)}.numleads
%                keyboard
                if ~isempty(acttime)
                    %dvdt(p) = (TS{index(j)}.potvals(p,acttime(p)+1) - TS{index(j)}.potvals(p,acttime(p)))/TS{index(j)}.samplefrequency;    
                else
                    %dvdt(p) = 0;
                end
            end
           % TS{index(j)}.dvdt = dvdt;
            TS{s(j)} = TS{index(j)};
            %TS{s(j)}.potvals = dvdt;
            TS{s(j)}.numframes = 1;
            TS{s(j)}.pacing = [];
            TS{s(j)}.fids = [];
            TS{s(j)}.fidset = {};
            TS{s(j)}.audit = '| Dv/Dt at activation';
            
        end

        tsClear(s);

   end
   
   
   %%%%% save everything and clear TS
    saveMyProcessingData;
    saveSettings();
    tsClear(index);
end









%%%%%%%%%%%%%%%%%%%%%%%% utility functions %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str = mynum2str(vec)
    % converts vectoren in strings
    % also outputs special format for the listboxedit  ( mitte unten, wo
    % man [1:19] eingibt
    if length(vec) == 1
        str = num2str(vec);
    else
        if nnz(vec-round(vec)) > 0
            str = num2str(vec);
        else
            vec = sort(vec);
            str = '';
            ind = 1;
            len = length(vec);
            while (ind <= len)
                if (len-ind) > 0
                     step = vec(ind+1)-vec(ind);
                     k = 1;
                     while (k+ind+1 <= len)
                         if vec(ind+k+1)-vec(ind+k) == step
                             k = k + 1;
                         else
                             break;
                         end
                     end
                     if k > 1
                         if step == 1
                            str = [str sprintf('%d:%d ',vec(ind),vec(ind+k))]; ind = ind + k+1;
                        else
                            str = [str sprintf('%d:%d:%d ',vec(ind),step,vec(ind+k))]; ind = ind + k+1;
                        end
                     else
                         str = [str sprintf('%d ',vec(ind))]; ind = ind + 1;
                     end
                 else
                     for p = ind:len
                         str = [str sprintf('%d ',vec(p))]; ind = len + 1;
                     end
                 end
             end
         end
     end
end

function vec = mystr2num(str)
    vec = eval(['[' str ']']);
end

function strs = commalist(str)
    %converts input like 'a,b,c' or 'a, b, c' oder 'a;b, c' in a cell array
    %{'a', 'b', 'c'}
    str = str(find(isspace(str)==0));
    ind = [0 sort([strfind(str,',') strfind(str,';')]) length(str)+1];
    for p=1:(length(ind)-1)
        strs{p} = str((ind(p)+1):(ind(p+1)-1));
    end
    
end