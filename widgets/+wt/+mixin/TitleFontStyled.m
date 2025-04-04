classdef TitleFontStyled < handle
    % Mixin for component with Font properties
    
    % Copyright 2020-2025 The MathWorks Inc.
    
    
    %% Properties
    properties (AbortSet)
        
        % Font name
        TitleFontName char {mustBeNonempty} = 'Helvetica'
        
        % Font size in points
        TitleFontSize (1,1) double {mustBePositive,mustBeFinite} = 14
        
        % Font weight (normal/bold)
        TitleFontWeight (1,1) wt.enum.FontWeightState = 'bold'
        
        % Font angle (normal/italic)
        TitleFontAngle (1,1) wt.enum.FontAngleState = 'normal'
        
    end %properties
    
    
    properties (AbortSet, Dependent)
        
        % Font Color
        TitleColor (1,3) double {mustBeInRange(TitleColor,0,1)}
        
    end %properties
    
    
    properties (AbortSet, NeverAmbiguous)
        
        % Font color mode
        TitleColorMode (1,1) wt.enum.AutoManualState = 'auto'
        
    end %properties
    
    
    %% Internal properties
    properties (AbortSet, Hidden)
        
        % Font Color
        TitleColor_I (1,3) double {mustBeInRange(TitleColor_I,0,1)} = [0.38 0.38 0.38];
        
    end %properties
    
    
    properties (AbortSet, Transient, NonCopyable, Hidden, SetAccess = protected)
        
        % List of graphics controls to apply to
        TitleFontStyledComponents (:,1) matlab.graphics.Graphics
        
    end %properties
    
    
    properties (Transient, NonCopyable, Access = private)
        
        % Listener for theme changes
        ThemeChangedListener event.listener
        
    end %properties
    
    
    %% Property Accessors
    
    methods
        
        function set.TitleFontName(obj,value)
            obj.TitleFontName = value;
            obj.updateTitleFontStyledComponents("FontName",value)
        end
        
        function set.TitleFontSize(obj,value)
            obj.TitleFontSize = value;
            obj.updateTitleFontStyledComponents("FontSize",value)
        end
        
        function set.TitleFontWeight(obj,value)
            obj.TitleFontWeight = value;
            obj.updateTitleFontStyledComponents("FontWeight",value)
        end
        
        function set.TitleFontAngle(obj,value)
            obj.TitleFontAngle = value;
            obj.updateTitleFontStyledComponents("FontAngle",value)
        end
        
        function value = get.TitleColor(obj)
            value = obj.TitleColor_I;
        end
        
        function set.TitleColor(obj, value)
            obj.TitleColorMode = 'manual';
            obj.TitleColor_I = value;
        end
        
        function set.TitleColorMode(obj, value)
            obj.TitleColorMode = value;
            obj.applyTheme();
        end
        
        function set.TitleColor_I(obj,value)
            obj.TitleColor_I = value;
            obj.updateTitleFontStyledComponents("FontColor", obj.TitleColor_I);
        end
        
        function set.TitleFontStyledComponents(obj,value)
            obj.TitleFontStyledComponents = value;
            obj.applyTheme();
            obj.updateTitleFontStyledComponents()
        end
        
    end %methods
    
    
    %% Constructor
    methods
        
        function obj = TitleFontStyled()
            
            % Confirm BaseWidget and R2025a or newer
            if matches("WidgetThemeChanged", events(obj)) ...
                    && ~isMATLABReleaseOlderThan("R2025a")
                
                % Listen to theme changes
                obj.ThemeChangedListener = ...
                    listener(obj, "WidgetThemeChanged", @(~,~)applyTheme(obj));
                
            end %if
            
        end %function
        
    end %methods
    
    
    %% Protected Methods
    methods (Access = protected)
        
        function updateTitleFontStyledComponents(obj,prop,value)
            
            % Get the components
            comps = obj.TitleFontStyledComponents;
            
            % Font color properties in prioritized order
            colorProps = ["TitleColor","FontColor","ForegroundColor"];
            
            % Updating all or a specific property?
            if nargin < 3
                
                % Set all subcomponent properties
                wt.utility.setStylePropsInPriority(comps,"FontName",obj.TitleFontName)
                wt.utility.setStylePropsInPriority(comps,"FontSize",obj.TitleFontSize)
                wt.utility.setStylePropsInPriority(comps,"FontWeight",obj.TitleFontWeight)
                wt.utility.setStylePropsInPriority(comps,"FontAngle",obj.TitleFontAngle)
                wt.utility.setStylePropsInPriority(comps,colorProps, obj.TitleColor_I);
                
            elseif prop == "FontColor"
                % Update just the FontColor property
                
                % Set the subcomponent property
                wt.utility.setStylePropsInPriority(comps, colorProps, value);
                
            else
                
                % Set the subcomponent property
                wt.utility.setStylePropsInPriority(comps, prop, value);
                
            end %if
            
        end %function
        
        
        function color = getDefaultTitleColor(obj)
            % Returns the default color for 'auto' mode (R2025a and later)
            % The result is dependent on theme
            % Widget subclass may override this
            
            try
                color = obj.getThemeColor("--mw-color-secondary"); %#ok<MCNPN>
                
            catch exception
                
                color = obj.TitleColor_I;
                
                id = "wt:applyTheme:getThemeColorFail";
                msg = "Unable to get default theme color: %s";
                warning(id, msg, exception.message)
                
            end %try
            
        end %function
        
    end %methods
    
    
    %% Private Methods
    methods (Access = private)
        
        function applyTheme(obj)
            
            % If color mode is auto, use standard theme color
            if obj.TitleColorMode == "auto" ...
                    && ~isMATLABReleaseOlderThan("R2025a")
                
                % Use standard theme color
                obj.TitleColor_I = obj.getDefaultTitleColor();
                
            end %if
            
        end %function
        
    end %methods
    
    
end %classdef