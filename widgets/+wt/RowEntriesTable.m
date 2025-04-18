classdef RowEntriesTable < wt.abstract.BaseWidget & ...
        wt.mixin.ButtonColorable &...
        wt.mixin.Enableable & ...
        wt.mixin.FieldColorable & ...
        wt.mixin.FontStyled & ...
        wt.mixin.Orderable & ...
        wt.mixin.Tooltipable
    % A table with buttons to add, remove, and order rows.
    
    % Copyright 2025 The MathWorks Inc.
    
    
    %% Public properties
    properties (AbortSet)
        
        % Table entries
        Data table = cell2table(cell(0,2),"VariableNames",{'Name','Value'})
        
        % Format for new table row
        NewRowFormat (1,:) cell = {'NewRow',0}
        
        % Indicates whether to enable buttons for reordering the rows
        Orderable  (1,1) matlab.lang.OnOffSwitchState = false
        
        % Can each item be removed?
        AllowItemRemove (1,:) logical
        
        % Can each item be ordered?
        AllowItemOrdering (1,:) logical
        
    end %properties
    
    
    % Accessors
    methods
        
        function value = get.AllowItemRemove(obj)
            value = wt.utility.resizeVector(obj.AllowItemRemove, height(obj.Data), true);
        end
        
        function value = get.AllowItemOrdering(obj)
            value = wt.utility.resizeVector(obj.AllowItemOrdering, height(obj.Data), true);
        end
        
    end %methods
    
    
    %% Dependent properties
    properties (Dependent, SetAccess = private)
        
        StyleConfigurations
        
    end %properties
    
    properties (Dependent)
        
        TableWidth
        
        TableHeight
        
    end %properties
    
    
    methods
        
        function value = get.TableWidth(obj)
            value = obj.Grid.ColumnWidth{1};
        end
        function set.TableWidth(obj, value)
            obj.Grid.ColumnWidth{1} = value;
        end
        
        function value = get.TableHeight(obj)
            value = obj.Grid.RowHeight{end};
        end
        function set.TableHeight(obj, value)
            obj.Grid.RowHeight{end} = value;
        end
        
        function value = get.StyleConfigurations(obj)
            value = obj.Table.StyleConfigurations;
        end
        
    end %methods
    
    
    %% Events
    events (HasCallbackProperty, NotifyAccess = protected)
        
        % Triggered on value changed, has companion callback
        ValueChanged
        
    end %events
    
    
    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = protected)
        
        % Table for entries
        Table matlab.ui.control.Table
        
        % Buttons
        AddButton matlab.ui.control.Button
        RemoveButton matlab.ui.control.Button
        UpButton matlab.ui.control.Button
        DownButton matlab.ui.control.Button
        
    end %properties
    
    
    %% Public methods
    methods
        
        function addStyle(obj,s,tableTarget,tableIndex)
            % Add a style to the table
            
            arguments
                obj (1,1) wt.RowEntriesTable
                s (1,1) matlab.ui.style.Style
                tableTarget (1,1) string {mustBeMember(tableTarget,...
                    ["table","row","column","cell"])} = "table"
                tableIndex = ""
            end
            
            % Add the style to the internal table
            addStyle(obj.Table, s, tableTarget, tableIndex)
            
        end %function
        
        
        function removeStyle(obj,orderNum)
            % Add a style to the table
            
            arguments
                obj (1,1) wt.RowEntriesTable
                orderNum = []
            end
            
            % Remove the style from the internal table
            if isempty(orderNum)
                removeStyle(obj.Table)
            else
                removeStyle(obj.Table, orderNum)
            end
            
        end %function
        
    end %methods
    
    
    %% Protected methods
    methods (Access = protected)
        
        function setup(obj)
            
            % Verify compatibility - R2022a and later only
            if isMATLABReleaseOlderThan("R2022a")
                id = "wt:RowEntriesTable:ReleaseNotSupported";
                msg = "RowEntriesTable supports R2022a and later.";
                error(id,msg);
            end

            % Call superclass method
            obj.setup@wt.abstract.BaseWidget()
            
            % Set default size
            obj.Position(3:4) = [300 200];

            % Configure grid
            obj.Grid.ColumnWidth = {'1x',30};
            obj.Grid.RowHeight = {30,30,30,30,'1x'};
            obj.Grid.ColumnSpacing = 5;
            obj.Grid.RowSpacing = 5;
            
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
            
            % Update order buttons
            obj.updateOrderButtons();
            
        end %function
        
        
        function updateEnableableComponents(obj)
            % Handle changes to Enable flag
            
            % Update order buttons
            obj.updateOrderButtons();
            
            % Update fields
            obj.Table.Enable = string(obj.Enable);
            
        end %function
        
        
        function updateOrderButtons(obj)
            
            % Which rows are selected?
            numItems = height(obj.Data);
            idxSel = obj.Table.Selection;
            
            % Which items allow removal?
            allowRemove = obj.AllowItemRemove(idxSel);
            canRemove = obj.Enable && ~isempty(idxSel) && all(allowRemove);
            
            % Which items allow ordering
            allItemOrdering = obj.AllowItemOrdering;
            
            % Toggle ordering button visibility
            obj.UpButton.Visible = obj.Orderable;
            obj.DownButton.Visible = obj.Orderable;
            
            % Update button enables
            obj.AddButton.Enable = obj.Enable;
            obj.RemoveButton.Enable = canRemove;
            if obj.Orderable
                [backEnabled, fwdEnabled] = obj.areOrderButtonsEnabled(...
                    numItems, idxSel, allItemOrdering);
                obj.UpButton.Enable = backEnabled;
                obj.DownButton.Enable = fwdEnabled;
            end
            
        end %function
        
        
        function onAddButton(obj,~)
            % Triggered on button pushed
            
            % Get old/new data
            oldData = obj.Data;
            newRowData = obj.NewRowFormat;
            numOldRows = height(oldData);
            
            % Determine placement
            selRowIdx = obj.Table.Selection;
            if isempty(selRowIdx)
                selRowIdx = numOldRows;
            end
            newRowIdx = selRowIdx + 1;
            
            % New row must be same width as table
            msg = "NewRowFormat property must be the same width as Data property.";
            assert(numel(newRowData) == width(oldData), msg)
            
            % Insert new data
            newData = vertcat(...
                oldData(1:selRowIdx,:), ...
                newRowData, ...
                oldData(newRowIdx:end,:) );
            
            % Prepare event data
            evtOut = wt.eventdata.RowEntriesTableChangedData();
            evtOut.Action = "RowAdded";
            evtOut.Row = newRowIdx;
            evtOut.Column = 1:size(newData,2);
            evtOut.Value = newData(newRowIdx,:);
            evtOut.PreviousValue = oldData([],:);
            evtOut.TableData = newData;
            evtOut.PreviousTableData = oldData;
            
            % Store new result and select it
            obj.Table.Data = newData;
            obj.Table.Selection = newRowIdx;
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
            
            obj.shiftSelectedRows(-1);
            
        end %function
        
        
        function onDownButton(obj,~)
            % Triggered on button pushed
            
            obj.shiftSelectedRows(1);
            
        end %function
        
        
        function shiftSelectedRows(obj,shift)
            % Shift the selected rows up/down
            
            numItems = height(obj.Data);
            idxSel = obj.Table.Selection;
            
            % Shift the list indices
            [idxNew, idxSelAfter] = obj.shiftListIndices(shift, numItems, idxSel);
            
            % Get the original value
            oldData = obj.Table.Data;
            
            % Make the shift
            newData = oldData(idxNew,:);
            
            % Prepare event data
            evtOut = wt.eventdata.RowEntriesTableChangedData();
            evtOut.Action = "RowOrdered";
            % evtOut.Row =
            % evtOut.Column =
            evtOut.Value = idxNew;
            % evtOut.PreviousValue =
            evtOut.TableData = newData;
            evtOut.PreviousTableData = oldData;
            
            % Update the table
            obj.Data = newData;
            obj.Table.Selection = idxSelAfter;
            
            % Trigger event
            notify(obj,"ValueChanged",evtOut);
            
            % Update buttons
            obj.updateOrderButtons()
            
        end %function
        
        
        function onSelectionChanged(obj,~)
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