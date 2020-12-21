%% Make a toolbar
tb = wt.Toolbar();
s = wt.toolbar.HorizontalSection();
s.Title = "SEC 1";
s.addButton("", "Push ME");
tb.Section = s;

s.ButtonPushedFcn = @mySectionCallback;
tb.ButtonPushedFcn = @myToolbarCallback;
% tb.ButtonPushedFcn = @(h,e)disp("Toolbar ButtonPushedFcn - " + e.Text);
% (h,e)disp("Section ButtonPushedFcn - " + e.Text)



%%
s.triggerEvent();

%%
s.triggerEventWithData();





%% functions
function mySectionCallback(~,e)
disp("SectionCallback eventdata " + class(e) + " from source class " + class(e.Source));
end

function myToolbarCallback(~,e)
disp("ToolbarCallback eventdata " + class(e) + " from source class " + class(e.Source));
end


%% Notes
% Moved ButtonPushed evt from BaseSection to HorizontalSection