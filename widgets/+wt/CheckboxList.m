classdef CheckboxList < wt.abstract.BaseWidget & ...
        wt.mixin.FontStyled & ...
        wt.mixin.Enableable & ...
        wt.mixin.Tooltipable
    % List of checkbox items
    
    % Select All shares the item font with bold weight and a font-colored
    % separator below it, with five pixels of spacing on each side.
    % The separator is dimmed against the background when disabled.

    % Copyright 2020-2026 The MathWorks Inc.


    %% Public properties
    properties (AbortSet)

        % Name of each item
        Items (:,1) string = [
            "Item 1"
            "Item 2"
            "Item 3"
            "Item 4"
            "Item 5"
            "Item 6"
            ]

        % The current value shown
        Value (:,1) logical = true(6,1)

        % Show the bold, content-fit Select All field above the items
        ShowSelectAll  (1,1) matlab.lang.OnOffSwitchState = false

    end %properties


    %% Property Accessors
    methods

        function value = get.Value(obj)
            numItems = numel(obj.Items);
            value = obj.Value;
            value(end+1:numItems) = true;
            value(numItems+1:end) = [];
        end

    end % methods


    %% Events
    events (HasCallbackProperty, NotifyAccess = protected)

        % Triggered on value changed, has companion callback
        ValueChanged

    end %events


    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = protected)

        % Item checkboxes
        ItemCheck (1,:) matlab.ui.control.CheckBox

        % Select All checkbox
        AllCheck (1,1) matlab.ui.control.CheckBox

        % Line separating Select All from the items
        SelectAllSeparator (1,1) matlab.ui.container.Panel

    end %properties



    %% Protected methods
    methods (Access = protected)

        function setup(obj)

            % Call superclass method
            obj.setup@wt.abstract.BaseWidget()

            % Set default size
            obj.Position(3:4) = [100 130];

            % Configure Grid
            obj.Grid.Padding = 0;
            obj.Grid.ColumnWidth = {'1x'};
            obj.Grid.RowHeight = {0,0,'fit'};
            obj.Grid.RowSpacing = 5;
            obj.Grid.Scrollable = true;

            % Create the Select All checkbox
            obj.AllCheck = matlab.ui.control.CheckBox(...
                "Parent",obj.Grid,...
                "Text","Select All",...
                "FontWeight","bold",...
                "Visible","off",...
                "ValueChangedFcn",@(h,e)obj.onSelectAllClicked(e));
            obj.AllCheck.Layout.Row = 1;
            obj.AllCheck.Layout.Column = 1;

            obj.SelectAllSeparator = uipanel(obj.Grid, ...
                "BorderType","none", "Visible","off");
            obj.SelectAllSeparator.Layout.Row = 2;
            obj.SelectAllSeparator.Layout.Column = 1;

            % Update the internal component lists
            obj.BackgroundColorableComponents = obj.Grid;
            obj.FontStyledComponents = [obj.AllCheck, obj.ItemCheck];
            obj.EnableableComponents = [obj.AllCheck, obj.SelectAllSeparator, obj.ItemCheck];
            obj.TooltipableComponents = [obj.AllCheck, obj.ItemCheck];

        end %function


        function update(obj)

            % How many items?
            numOld = numel(obj.ItemCheck);
            numNew = numel(obj.Items);

            % Update number of rows
            if numNew > numOld

                % Add rows
                for idx = (numOld+1):numNew
                    obj.ItemCheck(idx) = uicheckbox(obj.Grid,...
                        "Text",obj.Items(idx),...
                        'ValueChangedFcn', @(h,e)obj.onCheckboxClicked(e));
                    obj.ItemCheck(idx).Layout.Row = idx + 2;
                    obj.ItemCheck(idx).Layout.Column = 1;
                end

                % Update the internal component lists
                obj.FontStyledComponents = [obj.AllCheck, obj.ItemCheck];
                obj.EnableableComponents = [obj.AllCheck, obj.SelectAllSeparator, obj.ItemCheck];
                obj.TooltipableComponents = [obj.AllCheck, obj.ItemCheck];

            elseif numOld > numNew

                % Remove rows
                delete(obj.ItemCheck((numNew+1):end));
                obj.ItemCheck((numNew+1):end) = [];

            end %if numNew > numOld

            obj.Grid.RowHeight = [ {0,0}, repmat({'fit'},1,numNew) ];

            % Update each control
            for idx = 1:numNew
                wt.utility.fastSet(obj.ItemCheck(idx),...
                    'Text',obj.Items(idx),...
                    'Value',obj.Value(idx) );
            end

            % Update the Select All control
            if obj.ShowSelectAll
                wt.utility.fastSet( obj.AllCheck, 'Value', all(obj.Value) );
            end

            % Show/hide Select All
            if obj.ShowSelectAll
                obj.AllCheck.Visible = "on";
                obj.SelectAllSeparator.Visible = "on";
                obj.Grid.RowHeight{1} = 'fit';
                obj.Grid.RowHeight{2} = 1;
            else
                obj.AllCheck.Visible = "off";
                obj.SelectAllSeparator.Visible = "off";
            end

        end %function


        function updateFontStyledComponents(obj,varargin)

            % Call superclass method first
            obj.updateFontStyledComponents@wt.mixin.FontStyled(varargin{:});

            % Always make AllCheck bold
            obj.AllCheck.FontWeight = "bold";
            obj.SelectAllSeparator.BackgroundColor = obj.FontColor;

        end %function


        function onSelectAllClicked(obj,evt)
            % Triggered on select all

            % Calculate the new selection
            newValue = obj.Value;
            newValue(:) = evt.Value;

            % Prepare event data
            evtOut = wt.eventdata.PropertyChangedData('Value', newValue, obj.Value);

            % Store new result
            obj.Value = newValue;

            % Trigger event
            notify(obj,"ValueChanged",evtOut);

        end %function


        function onCheckboxClicked(obj,~)
            % Triggered on select all

            % Calculate the new selection
            newValue = [obj.ItemCheck.Value];

            % Prepare event data
            evtOut = wt.eventdata.PropertyChangedData('Value', newValue, obj.Value);

            % Store new result
            obj.Value = newValue;

            % Trigger event
            notify(obj,"ValueChanged",evtOut);

        end %function

    end %methods

end % classdef