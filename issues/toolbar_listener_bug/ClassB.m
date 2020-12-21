classdef ClassB < SuperClassB
    
    %% Events
    events (HasCallbackProperty)
        EventB
    end %events
    
    
    %% Methods
    methods
        
        function triggerEventB(obj)
            %notify(obj,"EventB");
            notify(obj, "EventB", MyEventData("EventB"));
        end %function
        
        function triggerEventSuperB(obj)
            %notify(obj,"EventSuperB");
            notify(obj, "EventSuperB", MyEventData("EventSuperB"));
        end %function
        
    end %methods
    
    
    %% Protected Methods
    methods (Access = protected)
        
        function setup(~)
        end
        
        
        function update(~)
        end
        
    end %methods
    
end %classdef