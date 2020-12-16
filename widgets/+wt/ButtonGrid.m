classdef ButtonGrid < wt.abstract.BaseWidget &...
        wt.mixin.Enableable & wt.mixin.FontStyled & wt.mixin.ButtonColorable
    % A grid of buttons with a single callback/event
    
    % Copyright 2020 The MathWorks Inc.
    
    
    %% Events
    events (HasCallbackProperty, NotifyAccess = protected)
        
        % Triggered when a button is pushed
        ButtonPushed
        
    end %events
    

    %% Properties
    
    properties (AbortSet)
        
        % Icons
        Icon (1,:) string = ["up_24.png", "down_24.png"]
        
        % Text
        Text (1,:) string
        
        % Tooltip
        Tooltip (1,:) string
        
        % Tag
        ButtonTag (1,:) string
        
        % Enable of each button (scalar or array)
        ButtonEnable (1,:) matlab.lang.OnOffSwitchState {mustBeNonempty} = true
        
        % Orientation of the buttons
        Orientation (1,1) string {mustBeMember(Orientation,...
            ["horizontal","vertical"])} = "horizontal"
        
        % Alignment of the icon
        IconAlignment (1,1) string {mustBeMember(IconAlignment,...
            ["left", "right", "center", "top", "bottom"])} = "top"
        
    end %properties
    
    
    properties (AbortSet, Dependent, UsedInUpdate = false)
        
        % Width of the buttons
        ButtonWidth
        
        % Height of the buttons
        ButtonHeight
        
    end %properties
    
    
    
    %% Internal Properties
    properties (Access = {?wt.test.BaseWidgetTest}, Transient, NonCopyable)
        
        % Buttons
        Button (1,:) matlab.ui.control.Button
        
    end %properties
    
    
    
    %% Protected methods
    methods (Access = protected)
        
        function setup(obj)
            
            % Call superclass setup to establish the main grid
            obj.setup@wt.abstract.BaseWidget();
            
        end %function
        
        
        function update(obj)
            
            % How many tasks?
            numOld = numel(obj.Button);
            numNew = max( numel(obj.Icon), numel(obj.Text) );
            
            % Update number of rows
            if numNew > numOld
                
                % Add rows
                for idx = (numOld+1):numNew
                    obj.Button(idx) = uibutton(obj.Grid,...
                        "ButtonPushedFcn", @(h,e)obj.onButtonPushed(e) );
                end
                
                % Update the internal component lists
                obj.FontStyledComponents = obj.Button;
                obj.EnableableComponents = obj.Button;
                obj.ButtonColorableComponents = obj.Button;
                
            elseif numOld > numNew
                
                % Remove rows
                delete(obj.Button((numNew+1):end));
                obj.Button((numNew+1):end) = [];
                
            end %if numNew > numOld
            
            % Expand the lists of icons and text to the number of buttons
            icons = obj.Icon;
            icons(1, end+1:numNew) = "";
            
            text = obj.Text;
            text(1, end+1:numNew) = "";
            
            tooltip = obj.Tooltip;
            tooltip(1, end+1:numNew) = "";
            
            tag = obj.ButtonTag;
            tag(1, end+1:numNew) = "";
            
            enable = obj.ButtonEnable;
            enable(1, end+1:numNew) = enable(1);
            if ~obj.Enable
                enable(:) = false;
            end
            
            % Update the names and icons
            for idx = 1:numNew
                
                % Update button content
                obj.Button(idx).Icon = icons(idx);
                obj.Button(idx).Text = text(idx);
                obj.Button(idx).Tooltip = tooltip(idx);
                obj.Button(idx).Tag = tag(idx);
                obj.Button(idx).IconAlignment = obj.IconAlignment;
                obj.Button(idx).Enable = enable(idx);
                
                % Update layout
                if obj.Orientation == "vertical"
                   obj.Button(idx).Layout.Column = 1;
                   obj.Button(idx).Layout.Row = idx;
                else
                   obj.Button(idx).Layout.Column = idx;
                   obj.Button(idx).Layout.Row = 1;
                end %if obj.Orientation == "vertical"
                
            end %for idx = 1:numNew
            
        end %function
        
        
        function onButtonPushed(obj,evt)
            % Triggered on button pushed
            
            % Trigger event
            evtOut = wt.eventdata.ButtonPushedData(evt);
            notify(obj,"ButtonPushed",evtOut);
            
        end %function
        
    end %methods
    
    
    
    %% Accessors
    methods
        
        function value = get.ButtonWidth(obj)
            value = obj.Grid.ColumnWidth;
        end
        function set.ButtonWidth(obj,value)
            obj.Grid.ColumnWidth = value;
        end
        
        function value = get.ButtonHeight(obj)
            value = obj.Grid.RowHeight;
        end
        function set.ButtonHeight(obj,value)
            obj.Grid.RowHeight = value;
        end
        
    end %methods
    
        
end % classdef

