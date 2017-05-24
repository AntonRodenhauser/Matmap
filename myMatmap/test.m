    function LoadSettings(handle)
    
    global SCRIPT;
    [filename,pathname] = uigetfile('*.mat','Choose processing script file');
    SCRIPT.SCRIPTFILE = fullfile(pathname,filename);
    filename = SCRIPT.SCRIPTFILE;
    
    script = [];
    if exist(filename,'file'),
        load(filename,'-mat');
        script
        script = rmfield(script,'TYPE');
        script = rmfield(script,'DEFAULT');
    
        disp('x')
        if exist('script','var'),
    
            % COMPATIBILITY CONVERSIONS
            
            % RENAMED THIS ONE TO BE MORE CONSISTENT
            if ~isfield(script,'TSDFODIR'),
                script.TSDFODIR = script.TSDFDIR;
            end
            
            fn = fieldnames(script);
            for p = 1:length(fn),
                SCRIPT = setfield(SCRIPT,fn{p},getfield(script,fn{p}));
            end
        end
 
%         UpdateACQFiles(handle);
        
        %d = dir(sprintf('%s-*.acq',SCRIPT.ACQLABEL));
        %if length(d) == 0, 
        %    GetACQLabel;
        %    fprintf(1,'Looking for ACQ Files in this directory\n');
        %    GetACQFiles;        
        %end
        
    end        

%     UpdateGroup;
%     UpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
%     UpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));

    return