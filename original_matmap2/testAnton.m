% 
% 
% plot([1 2 3]);
% 
% set(gcf,'ButtonDownFcn', @myButtonUpFcn)
% set(gcf,'WindowKeyPressFcn',{@myB_downFcnMitAdditionalArguments, 'Argument1','arg2'})
% set(gcf,'WindowButtonMotionFcn',@myMouseMovementFcn)
% set(gcf,'WindowKeyPressFcn',@myKeyPressFkt,'WindowKeyReleaseFcn',@myKeyReleaseFkt )
% 
% 
% 
% 
% function myButtonUpFcn(handle,EventData)
%     line=get(gca,'Children');
%     set(line,'Color', 'red')
%     drawnow
% end
% 
% 
% function myB_downFcnMitAdditionalArguments(handle,EventData, arg1, arg2)
% %neben default arguments handle und EventData wird jetz auch arg1 und arg2
% %ausgegeben
% disp(arg1)   %gibt 'Argument1' aus
% end
% 
% 
% function myMouseMovementFcn(handle, EventData)
% % disp('this is executed at every Mouse Movement')
% 
% mousePosition=get(gcf,'CurrentPoint')  % Position of mouse is saved in CurrentPoint property of figureObject
% %the above line constantly outputs mouseposition to screen whenever mouse
% %is moved
% 
% end
% 
% 
% 
% function myKeyPressFkt(handle, EventData)
% disp('this executes at every key press')
% if EventData.Key=='s'
%     disp('s was just pressed')
% end
% 
% 
% end
% 
% function myKeyReleaseFkt(handle, EventData)
% disp('this executes at every key release')
% if EventData.Key=='a'
%     disp('a was just released')
% end
% end



function testAnton
1;
end


function xxx(x)
disp(x)
end





%differenye between WindowButtonDown und ButtonDown

%handle ist..

% EventData ist:  
% im Fall ButtonDown, ButtonUp, WindowButtonDown etc
% EventData = 
%   WindowMouseData with properties:
% 
%        Source: [1×1 Figure]
%     EventName: 'WindowMousePress'  im Fall von WindowButtonMotionFcn: 'WindowMouseMotion'
% dff

% EventData = 
% 
%   KeyData with properties:
% 
%     Character: 'S'
%      Modifier: {'shift'}
%           Key: 's'
%        Source: [1×1 Figure]
%     EventName: 'WindowKeyRelease'



%im Fall von WindowKeyPressFcn







%useful links
