classdef MyComponent < matlab.ui.componentcontainer.ComponentContainer

    %% Public properties
    properties (AbortSet)
        
        Name (1,1) string = "My Component"
        
    end %properties
    
    
    %% Internal Properties
    properties (Transient, NonCopyable, Access = protected)
        
       Label matlab.ui.control.Label
       
    end %properties
    
     
    %% Protected methods   
    methods (Access = protected)
        
        function setup(obj)
            
            obj.Position(3:4) = [200 25];
            grid = uigridlayout(obj,[1 1],'Padding',[0 0 0 0]);
            obj.Label = uilabel(grid,'BackgroundColor','green');
            
        end %function
        
        
        function update(obj)
            
            disp("MyComponent update called");
            obj.Label.Text = obj.Name;
            
        end %function
        
    end %methods
    
end %classdef