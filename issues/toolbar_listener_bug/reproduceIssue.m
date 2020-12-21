
%%
a = ClassA('Parent',[]);
b = a.InstanceB;

a.EventAFcn = @(src,evt)myCallback("EventAFcn",evt);
b.EventBFcn = @(src,evt)myCallback("EventBFcn",evt);
b.EventSuperBFcn = @(src,evt)myCallback("EventSuperBFcn",evt);



%%
b.triggerEventB();
%%
b.triggerEventSuperB();



%% functions
function myCallback(cbName,evt)

type = class(evt);
name = evt.EventName;
if isprop(evt,"Tag")
    tag = evt.Tag;
else
    tag = "<wrong eventdata type>";
end

fprintf("Callback (%s) for event %s coming from %s (%s)\n", cbName, name, tag, type);

end %function