function selectLoop(varargin)

if nargin > 0 && ischar(varargin{1})    
    feval(varargin{1},varargin{2:end});
    return
end

global myScriptData

handle=winSelectLoopOrder;
setLoopOrderWindow(handle)

end


function setLoopOrderWindow(handle)
% set the LoopOrdernWindow. Mainly: set the edit text window accordingly to
% myScriptData.LOOPORDER
global myScriptData
loop_order=myScriptData.LOOP_ORDER;

%find the start of the loop
currentIndex=[];
for p=1:length(loop_order)
    if p==loop_order(p)
        continue
    else
        currentIndex=p;
        nextIndex=loop_order(currentIndex);   
        break
    end
end

loopString=[];
if ~isempty(currentIndex)
    while 1
        loopString=[loopString currentIndex];
        currentIndex=nextIndex;
        nextIndex=loop_order(currentIndex);   
        if ~isempty(find(currentIndex==loopString, 1))
            break   
        end
    end
end

loopString=strrep(num2str(loopString),'  ', ', ');

obj=findobj(allchild(handle), 'Tag', 'LOOP_ORDER');

set(obj,'String', loopString)
end


function set_LOOP_ORDER(handle)
%callback, sets myScriptData.LOOP_ORDER according to user input
global myScriptData FIDSDISPLAY

userInput=processUserInput(get(handle,'String'));

nextList=1:length(FIDSDISPLAY.fidslist);

userInput(end+1)=userInput(1);
for p=1:length(userInput)-1
    nextList(userInput(p))=userInput(p+1);
end

myScriptData.LOOP_ORDER=nextList;

end


function proc_input = processUserInput(input)
% converts inputs like '1, 2,  QRS-complex, 4' or '1, 2, 2, 4' in array
% [1 2 2 4] and returns that.

global FIDSDISPLAY

input=strtrim(input);
input=strsplit(input,', ');
proc_input=[];
 for q=1:length(input)
     s=strtrim(input{q});
     if isstrprop(s,'digit')
         proc_input=[proc_input str2double(s)];
     else
         index=find(ismember(FIDSDISPLAY.fidslist,s));
         if isempty(index)
             errordlg(sprintf('%s is not a known fiducial.',s))
             setLoopOrderWindow(findobj(allchild(0),'Tag','loopOrderWindow'))
             error('ERROR')
         else
             proc_input=[proc_input index];
         end
     end
 end
 
 if ~isequal(sort(proc_input), unique(proc_input))
    errordlg('Input must not contain dublicates!')
    setLoopOrderWindow(findobj(allchild(0),'Tag','loopOrderWindow'))
    error('ERROR')
 elseif length(proc_input) > length(FIDSDISPLAY.fidslist)
    errordlg('List contains more elements than there are fiducials!')
    setLoopOrderWindow(findobj(allchild(0),'Tag','loopOrderWindow'))
    error('ERROR')
     
 end
end