classdef DropDownListManager < matlab.ui.componentcontainer.ComponentContainer & ...
        wt.mixin.BackgroundColorable & ...
        wt.mixin.ButtonColorable &...
        wt.mixin.Enableable & ...
        wt.mixin.FieldColorable & ...
        wt.mixin.FontStyled & ...
        wt.mixin.Tooltipable
    % Manage a list of text entries using a dropdown control

    % Copyright 2024-2025 The MathWorks Inc.

    %RJ - supports R2023b and later, but test in earlier releases


    %% Events
    events (HasCallbackProperty, NotifyAccess = protected)

        % Triggered when the value of the list selection changes
        ItemsChanged

    end %events


    %% Public properties
    properties (AbortSet, Dependent, UsedInUpdate = false)

        % Index of selected list item
        Index {mustBeNonnegative, mustBeInteger, mustBeScalarOrEmpty}

        % The current selection
        Value (1,:)

        % List of items in the dropdown
        Items (1,:) string

    end %properties


    properties (AbortSet)

        % Data associated with items (optional)
        ItemsData (1,:)

    end %properties


    properties (AbortSet)

        % Show the remove button?
        AllowRemove (1,1) matlab.lang.OnOffSwitchState = true

        % Show the rename button?
        AllowRename (1,1) matlab.lang.OnOffSwitchState = true

        % Can each item be removed?
        AllowItemRemove (1,:) logical

        % Can each item be renamed?
        AllowItemRename (1,:) logical

        % List of items to add to the list
        NewItemName (1,1) string = "<New Item>"

    end %properties


    % Accessors
    methods

        function value = get.Items(obj)
            value = string(obj.DropDown.Items);
        end

        function set.Items(obj,value)
            obj.DropDown.Items = value;
            obj.DropDown.ItemsData = 1:numel(value);
        end

        function value = get.Index(obj)
            if isMATLABReleaseOlderThan("R2023b")
                warnState = warning('off','MATLAB:structOnObject');
                s = struct(obj.DropDown);
                warning(warnState);
                value = s.SelectedIndex;
            else
                value = obj.DropDown.ValueIndex;
            end
        end

        function set.Index(obj,value)
            if isMATLABReleaseOlderThan("R2023b")
                obj.DropDown.Value = obj.DropDown.ItemsData(value);
            else
                obj.DropDown.ValueIndex = value;
            end
        end

        function value = get.Value(obj)
            value = obj.Items(obj.Index);
        end

        function set.Value(obj,value)
            isMatch = matches(obj.Items, value);
            if ~any(isMatch)
                id = "wt:DropDownListManager:ValueMustBeInItems";
                msg = "'Value' must be an element defined in the 'Items' property.";
                error(id, msg);
            else
                obj.Index = find(isMatch,1);
            end
        end

        function set.AllowRemove(obj,value)
            obj.AllowRemove = value;
            obj.updateButtonVisibilities();
        end

        function set.AllowRename(obj,value)
            obj.AllowRename = value;
            obj.updateButtonVisibilities();
        end

        function value = get.AllowItemRemove(obj)
            value = resize(obj.AllowItemRemove, numel(obj.Items), ...
                "FillValue", true);
        end

        function value = get.AllowItemRename(obj)
            value = resize(obj.AllowItemRename, numel(obj.Items), ...
                "FillValue", true);
        end

    end %methods



    %% Internal Properties
    properties (UsedInUpdate, SetAccess = protected)

        % Indicates when new item is being entered
        IsAddingNewItem (1,1) logical = false

        % Indicates when an item is being renamed
        IsRenamingItem (1,1) logical = false

    end %properties


    properties (Transient, NonCopyable, Hidden, SetAccess = protected)

        % The dropdown control
        DropDown (1,1) matlab.ui.control.DropDown

        % The edit field
        EditField (1,1) matlab.ui.control.EditField

        % Grid
        Grid (1,1) matlab.ui.container.GridLayout

        % The list sorting buttons
        ListButtons wt.ButtonGrid

        % Buttons
        AddButton matlab.ui.control.Button
        RenameButton matlab.ui.control.Button
        RemoveButton matlab.ui.control.Button

        % Listeners to enable editing to stop
        StopEditingListeners event.listener

    end %properties




    %% Protected methods
    methods (Access = protected)

        function setup(obj)

            % Set default size
            obj.Position(3:4) = [250 30];

            % Construct Default Grid Layout to Manage Building Blocks
            obj.Grid = uigridlayout(obj,[1 3]);
            obj.Grid.ColumnWidth = {'1x',30,30,30};
            obj.Grid.RowHeight = {'1x'};
            obj.Grid.ColumnSpacing = 2;
            obj.Grid.Padding = 0;

            % Create the DropDown
            obj.DropDown = uidropdown(obj.Grid);
            obj.DropDown.Items = {'Item One','Item Two'};
            obj.DropDown.ItemsData = [1 2];
            obj.DropDown.ValueChangedFcn = @(~,evt)obj.onValueChanged(evt);
            obj.DropDown.Layout.Column = 1;
            obj.DropDown.Layout.Row = 1;

            % Create the EditField
            obj.EditField = uieditfield(obj.Grid);
            obj.EditField.Value = "";
            obj.EditField.ValueChangedFcn = @(~,evt)obj.onEditFieldChanged(evt);
            obj.EditField.Layout.Column = 1;
            obj.EditField.Layout.Row = 1;
            obj.EditField.Visible = false;

            % Create the buttons
            obj.AddButton = uibutton(obj.Grid);
            obj.AddButton.Icon = "addYellow_24.png";
            obj.AddButton.Text = "";
            obj.AddButton.Layout.Column = 2;
            obj.AddButton.Layout.Row = 1;
            obj.AddButton.ButtonPushedFcn = @(~,~)obj.onAddButton();

            obj.RenameButton = uibutton(obj.Grid);
            obj.RenameButton.Icon = "edit_24.png";
            obj.RenameButton.Text = "";
            obj.RenameButton.Layout.Column = 3;
            obj.RenameButton.Layout.Row = 1;
            obj.RenameButton.ButtonPushedFcn = @(~,~)obj.onRenameButton();

            obj.RemoveButton = uibutton(obj.Grid);
            obj.RemoveButton.Icon = "delete_24.png";
            obj.RemoveButton.Text = "";
            obj.RemoveButton.Layout.Column = 4;
            obj.RemoveButton.Layout.Row = 1;
            obj.RemoveButton.ButtonPushedFcn = @(~,~)obj.onRemoveButton();

            % Update the internal component lists
            obj.BackgroundColorableComponents = obj.Grid;
            obj.ButtonColorableComponents = [obj.AddButton, ...
                obj.RenameButton, obj.RemoveButton];
            obj.EnableableComponents = [obj.DropDown, obj.EditField, ...
                obj.AddButton, obj.RenameButton, obj.RemoveButton];
            obj.FieldColorableComponents = [obj.DropDown, obj.EditField];
            obj.FontStyledComponents = [obj.DropDown, obj.EditField];
            obj.TooltipableComponents = [obj.DropDown];

        end %function


        function update(obj)

            % Toggle between dropdown and edit field
            isEditMode = obj.IsAddingNewItem || obj.IsRenamingItem;
            obj.EditField.Visible = isEditMode;
            obj.DropDown.Visible = ~isEditMode;

            % Remove any listeners if no longer editing
            if ~isEditMode
                obj.StopEditingListeners(:) = [];
            end

            % Update button enable states
            obj.updateEnableableComponents();

        end %function


        function onEditFieldChanged(obj,evt)
            % Triggered when editing in edit field mode

            if obj.IsRenamingItem

                % Data for this event
                action = "Renamed";
                item = string(evt.Value);
                index = obj.Index;
                data = obj.getItemDataByIndex(index);

                % Strip off any whitespace
                item = strip(item);

                % Update the list item and select it
                obj.Items(index) = item;
                obj.Index = index;

                % Toggle mode OFF
                obj.IsRenamingItem = false;

            elseif obj.IsAddingNewItem

                % Data for this event
                action = "Added";
                item = string(evt.Value);
                index = numel(obj.Items) + 1;
                data = [];

                % Strip off any whitespace
                item = strip(item);

                % Add the new item to the list and select it
                obj.Items(index) = item;
                obj.Index = index;

                % Toggle mode OFF
                obj.IsAddingNewItem = false;

            else
                % Should not get here

                % Toggle mode OFF
                obj.IsRenamingItem = false;
                obj.IsAddingNewItem = false;

                % Exit
                return

            end %if

            % Prepare event data
            evtOut = wt.eventdata.ListManagerEventData();
            evtOut.Action = action;
            evtOut.Item = item;
            evtOut.ItemData = data;
            evtOut.Index = index;

            % Notify listeners
            notify(obj,"ItemsChanged",evtOut);

        end %function


        function onValueChanged(obj,evt)
            % Triggered on dropdown selection

            % Prepare event data
            evtOut = wt.eventdata.ListManagerEventData();
            evtOut.Action = "Selected";
            evtOut.Item = obj.Items(evt.Value);
            evtOut.ItemData = obj.getItemDataByIndex(evt.Value);
            evtOut.Index = evt.Value;

            % Notify listeners
            notify(obj,"ItemsChanged",evtOut);

            % Update button enable states
            obj.updateEnableableComponents();

        end %function


        function data = getItemDataByIndex(obj,index)
            % Retrieve the ItemsData value for a given index

            itemsData = obj.ItemsData;
            if isnumeric(index) && isscalar(index) && ...
                    index <= numel(itemsData)
                data = itemsData(index);
            else
                data = [];
            end

        end %function


        function onAddButton(obj)

                % Toggle mode ON
                obj.IsAddingNewItem = true;

                % Configure the edit field
                obj.EditField.Value = obj.NewItemName;
                drawnow
                obj.EditField.focus();

                % Attach figure listeners to stop editing in special
                % circumstances
                obj.attachStopEditingListeners();

        end %function


        function onRenameButton(obj)

                % Toggle mode ON
                obj.IsRenamingItem = true;
                
                % Get the item being edited
                item = obj.Items(obj.Index);

                % Configure the edit field
                obj.EditField.Value = item;
                drawnow
                obj.EditField.focus();

                % Attach figure listeners to stop editing in special
                % circumstances
                obj.attachStopEditingListeners();

        end %function


        function onRemoveButton(obj)
            % Removes selcted item

                % Data for this event
                action = "Removed";
                index = obj.Index;
                item = obj.Items(index);
                data = obj.getItemDataByIndex(index);

                % Remove the item from the list
                obj.Items(index) = [];
                if index <= numel(obj.ItemsData)
                    obj.ItemsData(index) = [];
                end

                % Prepare event data
                evtOut = wt.eventdata.ListManagerEventData();
                evtOut.Action = action;
                evtOut.Item = item;
                evtOut.ItemData = data;
                evtOut.Index = index;

                % Notify listeners
                notify(obj,"ItemsChanged",evtOut);

        end %function


        function attachStopEditingListeners(obj)
            % Attach listeners to enable stop editing under special
            % circumstances

            % Find the figure
            fig = ancestor(obj,'figure');
            
            % If no figure, just exit
            if isempty(fig)
                return
            end

            % Create listeners
            obj.StopEditingListeners = [
                listener(fig,"WindowKeyPress",@(src,evt)obj.onWindowKeyPress(evt))
                listener(fig,"WindowMousePress",@(src,evt)obj.onWindowMousePress(evt))
                ];

        end %function


        function onWindowKeyPress(obj,evt)
            % Triggered on key presses while editing

            % If the user pressed Escape, cancel editing
            if strcmp(evt.Key, 'escape')

                % Toggle mode OFF
                obj.IsRenamingItem = false;
                obj.IsAddingNewItem = false;

            end
            
        end %function


        function onWindowMousePress(obj,evt)
            % Triggered on mouse presses while editing

            % If the user clicked anywhere except the edit field, cancel
            % editing. 
            if ~isequal(evt.HitObject, obj.EditField)

                % Toggle mode OFF
                obj.IsRenamingItem = false;
                obj.IsAddingNewItem = false;

            end


        end %function


        function updateEnableableComponents(obj)
            % Handle changes to Enable flag

            % What item is selected?
            hasEntries = ~isempty(obj.Items);
            valIdx = obj.Index;

            % Can we add an item?
            isEditMode = obj.IsAddingNewItem || obj.IsRenamingItem;
            canAddItem = obj.Enable && ~isEditMode;

            % Can we rename or remove given the current selection?
            canRenameItem = obj.Enable && hasEntries && ...
                obj.AllowItemRename(valIdx) && ~isEditMode;
            canRemoveItem = obj.Enable && hasEntries && ...
                obj.AllowItemRemove(valIdx) && ~isEditMode;

            % Update buttons
            obj.AddButton.Enable = canAddItem;
            obj.RenameButton.Enable = canRenameItem;
            obj.RemoveButton.Enable = canRemoveItem;

            % Update fields
            obj.EditField.Enable = obj.Enable;
            obj.DropDown.Enable = obj.Enable && hasEntries;

        end %function


        function updateButtonVisibilities(obj)
            % Update button visibilities

            if obj.AllowRename && obj.AllowRemove

                obj.Grid.ColumnWidth = {'1x',30,30,30};

                obj.RenameButton.Parent = obj.Grid;
                obj.RenameButton.Layout.Column = 3;
                obj.RenameButton.Layout.Row = 1;

                obj.RemoveButton.Parent = obj.Grid;
                obj.RemoveButton.Layout.Column = 4;
                obj.RemoveButton.Layout.Row = 1;

            elseif obj.AllowRename

                obj.RemoveButton.Parent(:) = [];

                obj.Grid.ColumnWidth = {'1x',30,30};

                obj.RenameButton.Parent = obj.Grid;
                obj.RenameButton.Layout.Column = 3;
                obj.RenameButton.Layout.Row = 1;

            elseif obj.AllowRemove

                obj.RenameButton.Parent(:) = [];

                obj.Grid.ColumnWidth = {'1x',30,30};

                obj.RemoveButton.Parent = obj.Grid;
                obj.RemoveButton.Layout.Column = 3;
                obj.RemoveButton.Layout.Row = 1;

            else

                obj.RenameButton.Parent(:) = [];
                obj.RemoveButton.Parent(:) = [];

                obj.Grid.ColumnWidth = {'1x',30};

            end

        end %function

    end %methods

end % classdef