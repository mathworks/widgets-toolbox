classdef (Abstract) BaseWidget < matlab.ui.componentcontainer.ComponentContainer & ...
        wt.mixin.ErrorHandling
    % Base class for a graphical widget

    % Copyright 2020 The MathWorks Inc.
    
    
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
        
    
    
    %% Utilities
    methods (Access = protected)
        
        function callCallback(obj,callbackProp,evt)
            % Call a function handle based callback
            
            fcn = obj.(callbackProp);
            if ~isempty(fcn)
                fcn(obj,evt);
            end
            
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

