
function setHelpMenus(handle)
tag_list={'ACQEXT', 'ACQDIR','SCRIPTFILE','DATAFILE','ACQDIR','MATODIR'};

for p=1:length(tag_list)
    obj=findobj(allchild(handle),'Tag',tag_list{p});
    if isempty(obj)
        continue
    end
    
    c=uicontextmenu(handle);
    obj.UIContextMenu=c;
    
    uimenu(c,'Label','help','Tag',['UICTR_', tag_list{p}],'Callback',@displayHelp);
end


function displayHelp(source,cbdata)

which('setHelpMenus');
[path,~,~]=fileparts(which('setHelpMenus'));

filename=[source.Tag(7:end) '_help.html'];
filename=fullfile(path,'html',filename);
web(filename);



        




    
    
    
    
