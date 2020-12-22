classdef MyEventData < event.EventData
    
    
    %% Properties
    properties
        Tag (1,1) string = ""
    end
    
    
    %% Constructor
    methods
        function obj = MyEventData(tag)
            obj.Tag = tag;
        end
    end %constructor
    
    
end %classdef

