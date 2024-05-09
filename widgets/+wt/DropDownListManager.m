classdef DropDownListManager < matlab.ui.componentcontainer.ComponentContainer & ...
        wt.mixin.Enableable & wt.mixin.PropertyViewable
    % wt.mixin.FieldColorable & wt.mixin.ButtonColorable &...
    % wt.mixin.FontStyled & wt.mixin.BackgroundColorable &

    % Manage a list of text entries using a dropdown control

    % Copyright 2024 The MathWorks Inc.

    %RJ - supports R2023b and later, but test in earlier releases


    %% Events
    events (HasCallbackProperty, NotifyAccess = protected)

        % Triggered when a button is pushed
        % ButtonPushed

        % Triggered when the value of the list selection changes
        ItemsChanged

    end %events


    %% Public properties
    properties (AbortSet, Dependent, UsedInUpdate = false)

        % Index of displayed items that are currently added to the list
        ValueIndex {mustBeNonnegative, mustBeInteger, mustBeScalarOrEmpty}

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
        NewItemName (1,1) string = "New Item"

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

        function value = get.ValueIndex(obj)
            if isMATLABReleaseOlderThan("R2023b")
                warnState = warning('off','MATLAB:structOnObject');
                s = struct(obj.DropDown);
                warning(warnState);
                value = s.SelectedIndex;
            else
                value = obj.DropDown.ValueIndex;
            end
        end

        function set.ValueIndex(obj,value)
            if isMATLABReleaseOlderThan("R2023b")
                obj.DropDown.Value = obj.DropDown.ItemsData(value);
            else
                obj.DropDown.ValueIndex = value;
            end
        end

        function value = get.Value(obj)
            value = obj.DropDown.Value;
        end

        function set.Value(obj,value)
            obj.DropDown.Value = value;
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
        AddButton matlab.ui.control.StateButton
        RenameButton matlab.ui.control.StateButton
        RemoveButton matlab.ui.control.Button

        % Listen to button pushes in sections
        ButtonPushedListener event.listener

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
            obj.DropDown.Items ={'Item One','Item Two'};
            obj.DropDown.ItemsData = [1 2];
            obj.DropDown.ValueChangedFcn = @(h,e)obj.onValueChanged(e);
            obj.DropDown.Layout.Column = 1;
            obj.DropDown.Layout.Row = 1;

            % Create the EditField
            obj.EditField = uieditfield(obj.Grid);
            obj.EditField.Value = "";
            obj.EditField.ValueChangedFcn = @(h,e)obj.onEditFieldChanged(e);
            obj.EditField.Layout.Column = 1;
            obj.EditField.Layout.Row = 1;
            obj.EditField.Visible = false;

            % Create the buttons
            obj.AddButton = uibutton(obj.Grid,'state');
            obj.AddButton.Icon = "addYellow_24.png";
            obj.AddButton.Text = "";
            obj.AddButton.Layout.Column = 2;
            obj.AddButton.Layout.Row = 1;
            obj.AddButton.ValueChangedFcn = @(src,evt)obj.onAddButton(evt);

            obj.RenameButton = uibutton(obj.Grid,'state');
            obj.RenameButton.Icon = "edit_24.png";
            obj.RenameButton.Text = "";
            obj.RenameButton.Layout.Column = 3;
            obj.RenameButton.Layout.Row = 1;
            obj.RenameButton.ValueChangedFcn = @(src,evt)obj.onRenameButton(evt);

            obj.RemoveButton = uibutton(obj.Grid);
            obj.RemoveButton.Icon = "delete_24.png";
            obj.RemoveButton.Text = "";
            obj.RemoveButton.Layout.Column = 4;
            obj.RemoveButton.Layout.Row = 1;
            obj.RemoveButton.ButtonPushedFcn = @(src,~)obj.onRemoveButton();

            % Update listeners
            % obj.ButtonPushedListener = event.listener(...
            %     [obj.AddButton, obj.RemoveButton],...
            %     'ButtonPushed',@(h,e)obj.onButtonPushed(e) );

            % Update the internal component lists
            % obj.BackgroundColorableComponents = [obj.AddButton, obj.RemoveButton, obj.Grid];
            % obj.FontStyledComponents = [obj.DropDown];
            obj.EnableableComponents = [obj.DropDown, obj.AddButton, obj.RenameButton, obj.RemoveButton];
            % obj.ButtonColorableComponents = [obj.AddButton, obj.RemoveButton];
            % obj.FieldColorableComponents = [obj.DropDown];

        end %function


        function update(obj)

            disp('update start')

            isEditMode = obj.IsAddingNewItem || obj.IsRenamingItem;
            obj.EditField.Visible = isEditMode;
            obj.DropDown.Visible = ~isEditMode;

            % obj.AddButton.Value = obj.IsAddingNewItem;
            % obj.RenameButton.Value = obj.IsRenamingItem;
            % Update the list
            % obj.DropDown.Items = obj.Items;
            % obj.DropDown.ItemsData = 1:numel(obj.Items);

            % Update button enable states
            obj.updateButtonEnables();

            disp('update end');

        end %function


        % function updateEnables(obj)
        %
        %     % Toggle button enables
        %     hasEntries = obj.Enable && ~isempty(obj.Items);
        %     obj.AddButton.Enable = hasEntries;
        %     obj.RemoveButton.Enable = hasEntries;
        %
        % end %function

        function onEditFieldChanged(obj,evt)

            disp(evt);

        end %function


        function onValueChanged(obj,evt)


            % What action was taken?
            if evt.Edited && obj.IsAddingNewItem

                % Data for this event
                action = "Added";
                valueIndex = numel(obj.Items) + 1;
                item = string(evt.Value);
                value = [];

                % Add the new item to the list and select it
                obj.Items(valueIndex) = item;
                obj.ValueIndex = valueIndex;

                % Toggle new item mode OFF
                obj.IsAddingNewItem = false;
                obj.AddButton.Value = false;
                obj.DropDown.Editable = false;

            elseif evt.Edited && obj.IsRenamingItem

                % If previous value is not an integer, a prior callback
                % likely failed. Unable to determine what changed, so
                % cancel the edit.
                if ischar(evt.PreviousValue) || ...
                        ~isscalar(evt.PreviousValue) || ...
                        evt.PreviousValue < 1
                    obj.IsRenamingItem = false;
                    obj.RenameButton.Value = false;
                    obj.DropDown.Editable = false;
                    return
                end

                % Data for this event
                action = "Renamed";
                valueIndex = evt.PreviousValue;
                item = evt.Value;
                value = obj.getItemDataByIndex(valueIndex);

                % Update the list item and select it
                obj.Items(valueIndex) = item;
                obj.ValueIndex = valueIndex;

                % Toggle new item mode OFF
                obj.IsRenamingItem = false;
                obj.RenameButton.Value = false;
                obj.DropDown.Editable = false;
                drawnow

            elseif evt.Edited

                % Some internal failure occurred, such as a prior callback
                % erroring or debugging stopped abruptly. Cancel the edit
                % gracefully.
                obj.IsAddingNewItem = false;
                obj.AddButton.Value = false;
                obj.IsRenamingItem = false;
                obj.RenameButton.Value = false;
                obj.DropDown.Editable = false;
                return

            else

                % Data for this event
                action = "Selected";
                valueIndex = evt.Value;
                item = obj.Items(valueIndex);
                value = obj.getItemDataByIndex(valueIndex);

            end

            % Prepare event data
            evtOut = wt.eventdata.ListManagerEventData();
            evtOut.Action = action;
            evtOut.Item = item;
            evtOut.Value = value;
            evtOut.ValueIndex = valueIndex;

            % Notify listeners
            notify(obj,"ItemsChanged",evtOut);

            % Update button enable states
            obj.updateButtonEnables();

            % % Get the new and old values
            % if isempty(obj.ItemsData)
            %     itemsData = obj.Items;
            % else
            %     itemsData = obj.ItemsData;
            % end
            %
            % if isempty(evt.PreviousValue)
            %     oldValue = itemsData([]);
            % else
            %     oldValue = itemsData(evt.PreviousValue);
            % end
            %
            % if isempty(evt.Value)
            %     newValue = itemsData([]);
            % else
            %     newValue = itemsData(evt.Value);
            % end
            %
            % % Update button enable states
            % obj.updateEnables();
            %
            % % Trigger event
            % evtOut = wt.eventdata.ValueChangedData(newValue, oldValue);
            % notify(obj,"HighlightedValueChanged",evtOut);

        end %function


        function data = getItemDataByIndex(obj,index)
            % Retrieve the ItemsData value for a given index

            items = obj.Items;
            itemsData = obj.ItemsData;
            if ~isnumeric(index) || ~isscalar(index)
                data = [];
            elseif isempty(itemsData)
                data = string(items(index));
            elseif index <= numel(itemsData)
                data = itemsData(index);
            else
                data = [];
            end

        end %function


        % function [valueIndex, item, value, edited] = parseEventData(obj, evt)
        %     % Extract the relevant info from eventdata
        %
        %     % Was an item edited?
        %     edited = evt.Edited;
        %
        %     % Get existing data
        %     items = obj.Items;
        %     itemsData = obj.ItemsData;
        %
        %     % Get value index
        %     if edited && ischar(evt.PreviousValue) && obj.IsAddingNewItem
        %
        %         % Assume we're adding a new one
        %         valueIndex = numel(items) + 1;
        %
        %     elseif isMATLABReleaseOlderThan("R2023b")
        %         warnState = warning('off','MATLAB:structOnObject');
        %         s = struct(obj.ListBox);
        %         warning(warnState);
        %         valueIndex = s.SelectedIndex;
        %     else
        %         valueIndex = evt.ValueIndex;
        %     end
        %
        %     if isequal(valueIndex, -1)
        %         valueIndex = [];
        %     end
        %
        %     % Get item
        %     if edited
        %         item = string(evt.Value);
        %     else
        %         item = items(valueIndex);
        %     end
        %
        %     % Get value
        %     if ~isnumeric(valueIndex) || ~isscalar(valueIndex)
        %         value = [];
        %     elseif isempty(itemsData)
        %         value = items(valueIndex);
        %     elseif valueIndex <= numel(itemsData)
        %         value = itemsData(valueIndex);
        %     else
        %         value = [];
        %     end
        %
        % end %function


        function onAddButton(obj,evt)

            % Confirm existing mode
            if obj.IsAddingNewItem || ~evt.Value

                % Toggle mode off
                obj.IsAddingNewItem = false;
                obj.DropDown.Editable = false;
                drawnow

            elseif evt.Value

                % Toggle mode ON
                obj.IsAddingNewItem = true;

                % Put the dropdown into new mode
                obj.DropDown.Editable = true;
                obj.DropDown.Value = obj.NewItemName;
                obj.DropDown.focus();
                drawnow

            end

            % Update button enable states
            obj.updateButtonEnables();

        end %function


        function onRenameButton(obj,evt)

            % isRen = obj.IsRenamingItem
            % evt
            % obj.RenameButton.Value

            % Confirm existing mode
            if obj.IsRenamingItem %|| ~evt.Value
                disp('make off');
                % Toggle mode off
                obj.IsRenamingItem = false;
                obj.DropDown.Editable = false;
                drawnow

            elseif evt.Value
                disp('make on');
                % Toggle mode ON
                obj.IsRenamingItem = true;

                item = obj.Items(obj.ValueIndex);
                obj.EditField.Value = item;
                drawnow
                obj.EditField.focus();

                % Put the dropdown into new mode
                % obj.DropDown.Editable = true;
                % obj.DropDown.focus();
                % drawnow

            end

            % Update button enable states
            obj.updateButtonEnables();

        end %function


        function onRemoveButton(obj)

            disp("onRemoveButton");

            % What is removed?
            valIdx = obj.ValueIndex;
            removedItem = obj.Items(valIdx);
            removedValue = obj.Value;

            disp(removedItemName)

            % Remove the item from the list
            obj.Items(valIdx) = [];

            % Prepare event data
            evtOut = wt.eventdata.ListManagerEventData();
            evtOut.Action = "Removed";
            evtOut.Item = removedItem;
            evtOut.Value = removedValue;
            evtOut.ValueIndex = valIdx;

            % Notify listeners
            notify(obj,"ItemsChanged",evtOut);

        end %function


        function updateButtonEnables(obj)
            % Update button visibilities

            % What item is selected?
            valIdx = obj.ValueIndex;
            itemSelected = isscalar(valIdx);

            % Can we add an item?
            canAddItem = obj.Enable && ~obj.IsRenamingItem;

            % Can we rename or remove given the current selection?
            canRenameItem = obj.Enable && itemSelected && ...
                obj.AllowItemRename(valIdx) && ...
                ~obj.IsAddingNewItem;
            canRemoveItem = obj.Enable && itemSelected && ...
                obj.AllowItemRemove(valIdx) && ...
                ~obj.IsRenamingItem;

            % Update buttons
            obj.AddButton.Enable = canAddItem;
            obj.RenameButton.Enable = canRenameItem;
            obj.RemoveButton.Enable = canRemoveItem;

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


        function propGroups = getPropertyGroups(obj)
            % Override the ComponentContainer GetPropertyGroups with newly
            % customiziable mixin. This can probably also be specific to each control.

            propGroups = getPropertyGroups@wt.mixin.PropertyViewable(obj);

        end %function

    end %methods

end % classdef