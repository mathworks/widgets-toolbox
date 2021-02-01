classdef ButtonColorable < handle
    % Mixin for component with colorable button
    %

    % Copyright 2020-2021 The MathWorks Inc.
    
    
    %% Properties
    properties (AbortSet)
        
        % Button Color
        ButtonColor (1,3) double {wt.validators.mustBeBetweenZeroAndOne} = [1 1 1] * 0.96
        
    end %properties
    
    
    
    %% Internal properties
    properties (AbortSet, Access = protected)
        
        % List of graphics controls to apply to
        ButtonColorableComponents (:,1) matlab.graphics.Graphics
        
    end %properties
    
    
    
    %% Accessors
    methods
        
        function set.ButtonColor(obj,value)
            obj.ButtonColor = value;
            obj.updateButtonColorableComponents()
        end
        
        function set.ButtonColorableComponents(obj,value)
            obj.ButtonColorableComponents = value;
            obj.updateButtonColorableComponents()
        end
        
    end %methods
    
    
    
    %% Methods
    methods (Access = protected)
        
        function updateButtonColorableComponents(obj)
            
            wt.utility.fastSet(obj.ButtonColorableComponents,...
                "BackgroundColor",obj.ButtonColor);
            
        end %function
        
    end %methods
    
end %classdef