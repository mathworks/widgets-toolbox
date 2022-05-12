classdef PasswordField <  matlab.ui.componentcontainer.ComponentContainer & ...
    wt.mixin.BackgroundColorable & wt.mixin.PropertyViewable
    
    % A password entry field
    
    % Copyright 2020-2022 The MathWorks Inc.
    
    
    %% Public properties
    properties (AbortSet)
        
        % The current value shown
        Value (1,1) string
        
                
    end %properties
    
    
    %% Events
    events (HasCallbackProperty, NotifyAccess = protected)
        
        % Triggered on value changed, has companion callback
        ValueChanged
        
    end %events
    
    
    
    %% Internal Properties
    properties (Transient, NonCopyable, ...
            Access = {?wt.test.BaseWidgetTest, ?matlab.ui.componentcontainer.ComponentContainer} )
        
        % Grid
        Grid (1,1) matlab.ui.container.GridLayout
        
        % Password control
        PasswordControl (1,1) matlab.ui.control.HTML
        
    end %properties
    
    
    %% Protected methods
    methods (Access = protected)
        
        function setup(obj)
            
            % Set default size
            obj.Position(3:4) = [100 25];
            
            % Construct Grid Layout to Manage Building Blocks
            obj.Grid = uigridlayout(obj);
            obj.Grid.ColumnWidth = {'1x'};
            obj.Grid.RowHeight = {'1x'};
            obj.Grid.RowSpacing = 2;
            obj.Grid.ColumnSpacing = 2;
            obj.Grid.Padding = 0;   

            % Establish Background Color Listener
            obj.BackgroundColorableComponents = obj.Grid;
            
            % Define the HTML source
            html = ['<input type="password" id="pass" name="password" style="width:100%;height:100%" >',...
                '<script type="text/javascript">',...
                'function setup(htmlComponent) {',...
                'htmlComponent.addEventListener("DataChanged", function(event) {',...
                'document.getElementById("pass").value = htmlComponent.Data;',...
                '});',...
                'document.getElementById("pass").addEventListener("input", function() {',...
                'htmlComponent.Data = document.getElementById("pass").value;',...
                '});',...
                '}',...
                '</script>'];
            
            % Create a html password input
            obj.PasswordControl = uihtml(...
                'Parent',obj.Grid,...
                'HTMLSource',html,...
                'DataChangedFcn',@(h,e)obj.onPasswordChanged(e) );

        end %function

 
        function update(obj)
            
            % Update the edit control text
            obj.PasswordControl.Data = obj.Value;
            
        end %function
        
        
        function propGroups = getPropertyGroups(obj)
            % Override the ComponentContainer GetPropertyGroups with newly
            % customiziable mixin. This can probably also be specific to each control.

            propGroups = getPropertyGroups@wt.mixin.PropertyViewable(obj);

        end % function

%         function updateBackgroundColorableComponents(obj)
%             % Override Default BGC Update with Additional Components
%             obj.Grid.BackgroundColor = obj.BackgroundColor;
%             hasProp = isprop(obj.BackgroundColorableComponents,'BackgroundColor');
%             set(obj.BackgroundColorableComponents(hasProp),...
%                 "BackgroundColor",obj.BackgroundColor);
% 
%         end


    end %methods
    
    
    
    %% Private methods
    methods (Access = private)
        
        function onPasswordChanged(obj,evt)
            % Triggered on interaction
            
            % Return early if data hasn't changed
            % The html control may send a double callback on edits
            if strcmp(evt.Data, evt.PreviousData)
                return
            end
            
            % Prepare event data
            evtOut = wt.eventdata.PropertyChangedData('Value',evt.Data, obj.Value);
            
            % Store new result
            obj.Value = evt.Data;
            
            % Trigger event
            notify(obj,"ValueChanged",evtOut);
            
        end %function
    
    end %methods
    
    
    %% Accessors
    methods
        
        function set.Value(obj,value)
            drawnow %needs a moment to render so that display can update
            obj.Value = value;
        end
        
    end % methods
    
    
end % classdef

