classdef ClassA < matlab.ui.componentcontainer.ComponentContainer

    
    %% Events
    events (HasCallbackProperty)
        EventA
    end %events
    
    
    %% Properties
    properties
        InstanceB
        ListenerB
    end
    
    
    %% Protected Methods
    methods (Access = protected)
        
        function setup(obj)
            obj.InstanceB = ClassB('Parent',[]);
            obj.ListenerB = [
                event.listener(obj.InstanceB,'EventB',@(src,evt)onEventB(obj,evt))
                event.listener(obj.InstanceB,'EventSuperB',@(src,evt)onEventB(obj,evt))
                ];
        end
        
        
        function update(~)
        end
        
        
        function onEventB(obj,evt)
            % Repeat the eventdata to EventA
            notify(obj,'EventA',evt)
        end
        
    end %methods
    
    
end %classdef

