
%% Create components
a = ClassA('Parent',[]);
b = a.InstanceB;

%% Set callbacks
a.EventAFcn = @(src,evt)myCallback("EventAFcn",evt);
b.EventBFcn = @(src,evt)myCallback("EventBFcn",evt);
b.EventSuperBFcn = @(src,evt)myCallback("EventSuperBFcn",evt);



%% Trigger event defined in ClassB
b.triggerEventB();

% Actual Result is incorrect:
%-----------------
% EventAFcn callback, event EventA from original event EventB

% Expected Result:
%-----------------
% EventAFcn callback, event EventA from original event EventB
% EventBFcn callback, event EventB from original event EventB



%% Trigger event defined in SuperClassB
b.triggerEventSuperB();

% Actual Result is incorrect:
%-----------------
% EventAFcn callback, event EventA from original event EventSuperB

% Expected Result:
%-----------------
% EventAFcn callback, event EventA from original event EventSuperB
% EventSuperBFcn callback, event EventSuperB from original event EventSuperB



%% Trigger event defined in ClassB (without internally providing eventdata)
b.triggerEventBwithoutData();

% Actual Result is correct:
%-----------------
% EventAFcn callback, event EventA from original event <not MyEventData type>
% EventBFcn callback, event EventB from original event <not MyEventData type>



%% Trigger event definedin SuperClassB (without internally providing eventdata)
b.triggerEventSuperBwithoutData();

% Actual Result is incorrect:
%-----------------
% EventAFcn callback, event EventA from original event <not MyEventData type>

% Expected Result:
%-----------------
% EventAFcn callback, event EventA from original event <not MyEventData type>
% EventSuperBFcn callback, event EventSuperB from original event <not MyEventData type>



%% Callback Function
function myCallback(cbName,evt)

name = evt.EventName;
if isprop(evt,"Tag")
    tag = evt.Tag;
else
    tag = "<not MyEventData type>";
end

fprintf("%s callback, event %s from original event %s\n", cbName, name, tag);

end %function