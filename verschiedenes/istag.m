function TagExists( tag )
%TAGEXISTS Summary of this function goes here
%   Detailed explanation goes here

h1=winProcessingScriptMenu2;
h2=winProcessingScriptSettings2;
h3=winSliceDisplay;
h4=winFidsDisplay;

strings={'winProcessingScriptMenu2', 'winProcessingScriptSettings2','winSliceDisplay','winFidsDisplay'};

p=1;
for handle=[h1 h2 h3 h4]
    obj = findobj(allchild(handle),'tag',tag);
    if ~isempty(obj)
        obj
        fprintf('tag exists in %s',strings{p});
        for handle=[h1 h2 h3 h4], delete(handle); end
        return
    end
    p=p+1;
end
disp('tag existiert nicht')
for handle=[h1 h2 h3 h4], delete(handle); end
end

