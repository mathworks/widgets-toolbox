classdef (Abstract) BaseWidget < matlab.ui.componentcontainer.ComponentContainer & ...
        wt.mixin.ErrorHandling
    % Base class for a graphical widget

    % Copyright 2020-2021 The MathWorks Inc.
    
    
    %% Internal properties
    properties (AbortSet, Access = protected)
        
        % List of graphics controls that BackgroundColor should apply to
        BackgroundColorableComponents (:,1) matlab.graphics.Graphics
        
    end %properties

    
    
    %% Debugging Methods
    methods
        
        function forceUpdate(obj)
           % Forces update to run (For debugging only!)
           
            obj.update();
            
        end %function
        
    end %methods
    
    
    
    %% Setup
    properties ( Transient, NonCopyable, ...
            Access = {?wt.abstract.BaseWidget, ?wt.test.BaseWidgetTest} )
        
        % The internal grid to manage contents
        Grid matlab.ui.container.GridLayout
        
    end %properties
    
    
    methods (Access = protected)
        
        function setup(obj)
            % Configure the widget
            
            % Grid Layout to manage building blocks
            obj.Grid = uigridlayout(obj);
            obj.Grid.ColumnWidth = {'1x'};
            obj.Grid.RowHeight = {'1x'};
            obj.Grid.RowSpacing = 2;
            obj.Grid.ColumnSpacing = 2;
            obj.Grid.Padding = [0 0 0 0];
            
            % Listen to BackgroundColor changes
            addlistener(obj,'BackgroundColor','PostSet',...
                @(h,e)obj.updateBackgroundColorableComponents());
            
        end %function
        
    end %methods
    
    
    
    %% Protected Methods
    methods (Access = protected)
        
        function updateBackgroundColorableComponents(obj)
            
            obj.Grid.BackgroundColor = obj.BackgroundColor;
            hasProp = isprop(obj.BackgroundColorableComponents,'BackgroundColor');
            set(obj.BackgroundColorableComponents(hasProp),...
                "BackgroundColor",obj.BackgroundColor);
            
        end %function
        
    end %methods
    
    
    
    %% Display customization
    methods (Hidden, Access = protected)
        
        function groups = getPropertyGroups(obj)
            % Customize how the properties are displayed
            
            % Ignore most superclass properties for default display
            persistent superProps
            if isempty(superProps)
                superProps = properties('matlab.ui.componentcontainer.ComponentContainer');
            end
            
            % Get the relevant properties
            propNames = setdiff(properties(obj), superProps);
            
            % Split out the callbacks, fonts
            isCallback = endsWith(propNames, "Fcn");
            isFont = startsWith(propNames, "Font");
            normalProps = propNames(~isCallback & ~isFont);
            callbackProps = propNames(isCallback);
            
            % Define the groups
            groups = [
                matlab.mixin.util.PropertyGroup(callbackProps)
                matlab.mixin.util.PropertyGroup(normalProps)
                matlab.mixin.util.PropertyGroup(["Position", "Units"])
                ];
            
        end %function
        
    end %methods
    
    
    
    %% Accessors
    methods
        
        function set.BackgroundColorableComponents(obj,value)
            obj.BackgroundColorableComponents = value;
            obj.updateBackgroundColorableComponents()
        end
        
    end %methods
    
    
end %classdef

