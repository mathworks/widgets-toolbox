classdef ClassB < SuperClassB
    
    %% Events
    events (HasCallbackProperty)
        EventB
    end %events
    
    
    %% Methods
    methods
        
        function triggerEventB(obj)
            
            % Trigger notify
            evt = MyEventData("EventB");
            notify(obj, "EventB", evt);
            
            % I need to manually call the callback for it to work!
            %obj.EventBFcn(obj,evt);
            
        end %function
        
        
        function triggerEventSuperB(obj)
            
            % Trigger notify
            evt = MyEventData("EventSuperB");
            notify(obj, "EventSuperB", evt);
            
            % I need to manually call the callback for it to work!
            %obj.EventSuperBFcn(obj,evt);
            
        end %function
        
        
        
        function triggerEventBwithoutData(obj)
            
            % If I don't provide eventdata, it behaves differently!
            notify(obj,"EventB");
            
        end %function
        
        
        function triggerEventSuperBwithoutData(obj)
            
            % Trigger notify
            notify(obj,"EventSuperB");
            
            % I need to manually call the callback for it to work!
            %evt = event.EventData();
            %obj.EventSuperBFcn(obj, evt);
            
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