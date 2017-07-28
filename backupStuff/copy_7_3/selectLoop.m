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

loopString=strrep(num2str(myScriptData.LOOP_ORDER),'  ', ', ');

obj=findobj(allchild(handle), 'Tag', 'LOOP_ORDER');

set(obj,'String', loopString)
end


function set_LOOP_ORDER(handle)
%callback, sets myScriptData.LOOP_ORDER according to user input
global myScriptData 
userInput=processUserInput(get(handle,'String'));
myScriptData.LOOP_ORDER=userInput;
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
 end
 
end

