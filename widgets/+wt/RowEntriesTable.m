classdef RowEntriesTable < matlab.ui.componentcontainer.ComponentContainer & ...
        wt.mixin.BackgroundColorable & ...
        wt.mixin.ButtonColorable &...
        wt.mixin.Enableable & ...
        wt.mixin.FieldColorable & ...
        wt.mixin.FontStyled & ...
        wt.mixin.Tooltipable
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
        NewRowFormat (1,:) cell = {"NewRow",0}

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

            % Update the internal component lists
            obj.BackgroundColorableComponents = obj.Grid;
            obj.ButtonColorableComponents = [obj.AddButton, ...
                obj.RemoveButton, obj.UpButton, obj.DownButton];
            obj.EnableableComponents = [obj.Table, obj.AddButton, ...
                obj.RemoveButton, obj.UpButton, obj.DownButton];
            obj.FieldColorableComponents = obj.Table;
            obj.FontStyledComponents = obj.Table;
            obj.TooltipableComponents = obj.Table;

        end %function


        function update(obj)

            % Get the data
            data = obj.Data;

            % If empty and no vars, use NewRowFormat
            if width(data) == 0
                data = cell(0, numel(obj.NewRowFormat));
            end

            % Update the table content
            obj.Table.Data = data;

            % Toggle sorting button visibility
            obj.UpButton.Visible = obj.Sortable;
            obj.DownButton.Visible = obj.Sortable;

        end %function


        function updateEnableableComponents(obj)
            % Handle changes to Enable flag

            % Which rows are selected?
            numRows = height(obj.Data);
            selRows = obj.Table.Selection;

            % Update buttons
            obj.AddButton.Enable = obj.Enable;
            obj.RemoveButton.Enable = obj.Enable && ~isempty(selRows);
            obj.UpButton.Enable = obj.Enable && ~any(selRows == 1);
            obj.DownButton.Enable = obj.Enable && ~any(selRows == numRows);

            % Update fields
            obj.Table.Enable = string(obj.Enable);

        end %function


        function onAddButton(obj,~)
            % Triggered on button pushed

            % Prepare new data
            oldData = obj.Data;
            selRow = obj.Table.Selection;
            if isempty(selRow)
                selRow = height(oldData);
            end
            newRow = selRow + 1;
            newData = [
                oldData(1:selRow,:)
                obj.NewRowFormat
                oldData(newRow:end,:)
                ];

            % Prepare event data
            evtOut = wt.eventdata.RowEntriesTableChangedData();
            evtOut.Action = "RowAdded";
            evtOut.Row = newRow;
            evtOut.Column = 1:size(newData,2);
            evtOut.Value = newData(newRow,:);
            evtOut.PreviousValue = oldData([],:);
            evtOut.TableData = newData;
            evtOut.PreviousTableData = oldData;

            % Store new result and select it
            obj.Table.Data = newData;
            obj.Table.Selection = newRow;
            obj.Data = newData;

            % Trigger event
            notify(obj,"ValueChanged",evtOut);

        end %function


        function onRemoveButton(obj,~)
            % Triggered on button pushed

            % Get the selection and total rows
            selRows = obj.Table.Selection;
            if isempty(selRows)
                return
            end
            numSelRows = numel(selRows);
            numRows = height(obj.Data);

            % Prepare the new data
            oldData = obj.Data;
            removedData = oldData(selRows,:);
            newData = oldData;
            newData(selRows,:) = [];

            % Calculate new row selection
            newSelRows = selRows;
            newNumRows = numRows - numSelRows;
            isOver = newSelRows > newNumRows;
            newSelRows(isOver) = newSelRows(isOver) - numSelRows;
            newSelRows(newSelRows < 1 | newSelRows > newNumRows) = [];
            newSelRows = unique(newSelRows);
           
            % Prepare event data
            evtOut = wt.eventdata.RowEntriesTableChangedData();
            evtOut.Action = "RowRemoved";
            evtOut.Row = selRows;
            evtOut.Column = 1:size(oldData,2);
            evtOut.Value = removedData([],:);
            evtOut.PreviousValue = removedData;
            evtOut.TableData = newData;
            evtOut.PreviousTableData = oldData;

            % Store new result and update selection
            obj.Table.Data = newData;
            obj.Table.Selection = newSelRows;
            obj.Data = newData;

            % Trigger event
            notify(obj,"ValueChanged",evtOut);

        end %function


        function onUpButton(obj,~)
            % Triggered on button pushed

            numRows = height(obj.Data);
            selRows = obj.Table.Selection;

            %RJ - needs implementation
            
        end %function


        function onDownButton(obj,~)
            % Triggered on button pushed

            numRows = height(obj.Data);
            selRows = obj.Table.Selection;

            %RJ - needs implementation

        end %function


        function onSelectionChanged(obj,evt)
            % Triggered on table selection changed

            % Update button enables
            obj.updateEnableableComponents();

        end %function


        function onCellEdited(obj,evt)
            % Triggered on cell edited

            % Prepare event data
            evtOut = wt.eventdata.RowEntriesTableChangedData();
            evtOut.Action = "CellEdited";
            evtOut.Row = evt.Indices(1);
            evtOut.Column = evt.Indices(2);
            evtOut.Value = evt.NewData;
            evtOut.PreviousValue = evt.PreviousData;
            evtOut.EditValue = evt.EditData;
            evtOut.TableData = [obj.Table.Data];
            evtOut.PreviousTableData = obj.Data;
            evtOut.Error = evt.Error;

            % Store new result
            obj.Data = [obj.Table.Data];

            % Trigger event
            notify(obj,"ValueChanged",evtOut);

        end %function

    end %methods


end % classdef