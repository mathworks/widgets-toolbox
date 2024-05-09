classdef RowEntriesTable < matlab.ui.componentcontainer.ComponentContainer & ...
        wt.mixin.FontStyled & wt.mixin.Tooltipable & ...
        wt.mixin.ButtonColorable & wt.mixin.BackgroundColorable & ...
        wt.mixin.FieldColorable & wt.mixin.PropertyViewable
        % wt.mixin.Enableable & 

    % A table showing status of multiple tasks

    % Copyright 2024 The MathWorks Inc.


    %RJ - Need unit tests
    %RJ - Connect ordering buttons and make them optoinal
    %RJ - Table enable didn't work


    %% Public properties
    properties (AbortSet)

        % Table entries
        Data table

        % Format for new table row
        NewRowFormat (1,:) table = ...
            cell2table({"NewRow",0},"VariableNames",["Name","Value"])

    end %properties


    %% Events
    events (HasCallbackProperty, NotifyAccess = protected)

        % Triggered on value changed, has companion callback
        ValueChanged

    end %events


    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = protected)

        % Indicates whether to allow sort controls
        Sortable  (1,1) matlab.lang.OnOffSwitchState = false

        % Grid
        Grid matlab.ui.container.GridLayout

        % Table for entries
        Table matlab.ui.control.Table

        % Buttons
        AddButton matlab.ui.control.Button
        RemoveButton matlab.ui.control.Button
        UpButton matlab.ui.control.Button
        DownButton matlab.ui.control.Button

    end %properties


    %% Protected methods
    methods (Access = protected)

        function setup(obj)

            % Construct Grid Layout to Manage Building Blocks
            obj.Grid = uigridlayout(obj,[5,2]);
            obj.Grid.ColumnWidth = {'1x',30};
            obj.Grid.RowHeight = {30,30,30,30,'1x'};
            obj.Grid.Padding = 0;
            obj.Grid.ColumnSpacing = 2;
            obj.Grid.RowSpacing = 5;

            % Set default size
            obj.Position(3:4) = [300 200];

            % Create the Table
            obj.Table = uitable(obj.Grid);
            obj.Table.ColumnEditable = true;
            obj.Table.SelectionType = 'row';
            obj.Table.Layout.Column = 1;
            obj.Table.Layout.Row = [1 5];
            obj.Table.CellEditCallback = @(src,evt)obj.onCellEdited(evt);
            obj.Table.SelectionChangedFcn = @(src,evt)obj.onSelectionChanged(evt);

            % Create the buttons
            obj.AddButton = uibutton(obj.Grid);
            obj.AddButton.Icon = "addYellow_24.png";
            obj.AddButton.Text = "";
            obj.AddButton.Layout.Column = 2;
            obj.AddButton.Layout.Row = 1;
            obj.AddButton.ButtonPushedFcn = @(src,evt)obj.onAddButton(evt);

            obj.RemoveButton = uibutton(obj.Grid);
            obj.RemoveButton.Icon = "delete_24.png";
            obj.RemoveButton.Text = "";
            obj.RemoveButton.Layout.Column = 2;
            obj.RemoveButton.Layout.Row = 2;
            obj.RemoveButton.ButtonPushedFcn = @(src,evt)obj.onRemoveButton(evt);

            obj.UpButton = uibutton(obj.Grid);
            obj.UpButton.Icon = "up_24.png";
            obj.UpButton.Text = "";
            obj.UpButton.Layout.Column = 2;
            obj.UpButton.Layout.Row = 3;
            obj.UpButton.ButtonPushedFcn = @(src,evt)obj.onUpButton(evt);

            obj.DownButton = uibutton(obj.Grid);
            obj.DownButton.Icon = "down_24.png";
            obj.DownButton.Text = "";
            obj.DownButton.Layout.Column = 2;
            obj.DownButton.Layout.Row = 4;
            obj.DownButton.ButtonPushedFcn = @(src,evt)obj.onDownButton(evt);

            %RJ - Temporarily hide up/down buttons


            % Update the internal component lists
            obj.FontStyledComponents = obj.Table;
            obj.FieldColorableComponents = obj.Table;
            % obj.EnableableComponents = [obj.Table, obj.AddButton, ...
            %     obj.RemoveButton, obj.UpButton, obj.DownButton];
            obj.TooltipableComponents = obj.Table;
            obj.BackgroundColorableComponents = [obj.Grid, ...
                obj.AddButton, obj.RemoveButton, obj.UpButton, obj.DownButton];

        end %function


        function update(obj)

            % Get the data
            data = obj.Data; 

            % If empty and no vars, use variable names from NewRowFormat
            if width(data) == 0
                data = obj.NewRowFormat([],:);
            end

            % Update the table content
            obj.Table.Data = data;

            % Toggle sorting button visibility
            obj.UpButton.Visible = obj.Sortable;
            obj.DownButton.Visible = obj.Sortable;

            % Update button enables
            obj.updateButtonEnables();

        end %function


        function updateButtonEnables(obj)

            numRows = height(obj.Data);
            selRows = obj.Table.Selection;

            obj.RemoveButton.Enable = ~isempty(selRows);
            obj.UpButton.Enable = ~any(selRows == 1);
            obj.DownButton.Enable = ~any(selRows == numRows);
            
        end %function


        function propGroups = getPropertyGroups(obj)
            % Override the ComponentContainer GetPropertyGroups with newly
            % customiziable mixin. This can probably also be specific to each control.

            propGroups = getPropertyGroups@wt.mixin.PropertyViewable(obj);

        end %function


        function onAddButton(obj,~)
            % Triggered on button pushed

            % Append a new row to the data
            obj.Data = vertcat(obj.Data, obj.NewRowFormat);

        end %function


        function onRemoveButton(obj,~)
            % Triggered on button pushed

            % Get the selection and total rows
            selRows = obj.Table.Selection;
            numSelRows = numel(selRows);
            numRows = height(obj.Data);
            
            % Remove the rows
            obj.Data(selRows,:) = [];

            % Update table selection
            newNumRows = numRows - numSelRows;
            isOver = selRows > newNumRows;
            selRows(isOver) = selRows(isOver) - numSelRows;
            selRows(selRows < 1 | selRows > newNumRows) = [];
            selRows = unique(selRows);
            obj.Table.Selection = selRows;

        end %function


        function onUpButton(obj,~)
            % Triggered on button pushed

            numRows = height(obj.Data);
            selRows = obj.Table.Selection;

        end %function


        function onDownButton(obj,~)
            % Triggered on button pushed

            numRows = height(obj.Data);
            selRows = obj.Table.Selection;

        end %function


        function onSelectionChanged(obj,evt)
            % Triggered on table selection changed
            
            % Update button enables
            obj.updateButtonEnables();

        end %function


        function onCellEdited(obj,evt)
            % Triggered on cell edited

            % Get prior value
            oldValue = obj.Data;

            % Get new value
            newValue = [obj.Table.Data];

            % Store new result
            obj.Data = newValue;

            % Trigger event
            evtOut = wt.eventdata.ValueChangedData(newValue, oldValue);
            notify(obj,"ValueChanged",evtOut);

        end %function

    end %methods


end % classdef