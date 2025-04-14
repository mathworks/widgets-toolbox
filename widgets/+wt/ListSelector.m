classdef ListSelector < wt.abstract.BaseWidget & ...
        wt.mixin.ButtonColorable &...
        wt.mixin.Enableable & ...
        wt.mixin.FieldColorable & ...
        wt.mixin.FontStyled & ...
        wt.mixin.Orderable
    % Select from an array of items and add them to a list

    % Copyright 2020-2025 The MathWorks Inc.

    %% Events
    events (HasCallbackProperty, NotifyAccess = protected)

        % Triggered when a button is pushed
        ButtonPushed

        % Triggered when the value of the list selection changes
        ValueChanged

        % Triggered when the highlighted value changes
        HighlightedValueChanged

    end %events


    %% Public properties
    properties (AbortSet)

        % List of items to add to the list
        Items (1,:) string = ["Item 1" "Item 2" "Item 3" "Item 4"]

        % Data associated with  items (optional)
        ItemsData (1,:)

        % Indicates whether to allow duplicate entries in the list
        AllowDuplicates  (1,1) matlab.lang.OnOffSwitchState = false

         % Indicates whether to allow sort controls
        Sortable  (1,1) matlab.lang.OnOffSwitchState = true

        % Inidicates what to do when add button is pressed (select from
        % Items or custom using ButtonPushed event or ButtonPushedFcn)
        AddSource (1,1) wt.enum.ListAddSource = wt.enum.ListAddSource.Items

         % Width of the buttons
        ButtonWidth = 25

        % Height of the buttons
        ButtonHeight = 25

    end %properties

    methods

        function set.Items(obj, newItems)

            % Get original items and highlight
            oldValue = obj.Value; %#ok<MCSUP>
            oldHighlight = obj.HighlightedValue; %#ok<MCSUP>

            % Retain the matching original value selection
            isPresent = ismember(oldValue, newItems);
            newValue = oldValue(isPresent);

            % Attempt to retain the highlight values
            isPresent = ismember(oldHighlight, newItems);
            newHighlight = oldHighlight(isPresent);

            % Set new items
            obj.Items = newItems;

            % Set selection for consistency
            obj.Value = newValue; %#ok<MCSUP>

            % Set highlight for consistency
            if obj.AllowDuplicates %#ok<MCSUP>
                % If duplicates allowed, it can be inconsistent, so must
                % deselect all instead
                obj.HighlightedValue = []; %#ok<MCSUP>
            else
                % This is the best guess we can make
                obj.HighlightedValue = newHighlight; %#ok<MCSUP>
            end

        end

        
    end %methods


    %% Public dependent properties
    properties (AbortSet, Dependent)

        % Indices of displayed items that are currently added to the list
        ValueIndex (1,:)

        % The current selection
        Value (1,:)

        % The current highlighted selection
        HighlightedValue (1,:)

    end %properties


    methods

        function value = get.ValueIndex(obj)
            value = obj.ListBox.ItemsData;
            value(value > obj.getMaximumValidItemsNumber) = [];
        end

        function set.ValueIndex(obj,value)
            if any(value > numel(obj.Items))
                error("widgets:ListSelector:ValueIndex",...
                        "'ValueIndex' must be within the length of the 'Items' property.")
            end
            if ~isempty(obj.ItemsData) && any(value > numel(obj.ItemsData))
                error("widgets:ListSelector:ValueIndex",...
                        "'ValueIndex' must be within the length of the 'ItemsData' property.")
            end
            obj.ListBox.Items = obj.Items(value);
            obj.ListBox.ItemsData = value;
        end

        function value = get.Value(obj)
            itemIdx = obj.ListBox.ItemsData;
            itemIdx(itemIdx > numel(obj.Items)) = [];
            if isempty(obj.ItemsData)
                value = obj.Items(:, itemIdx);
            else
                value = obj.ItemsData(:, itemIdx);
            end
        end

        function set.Value(obj,value)
            if isempty(value)
                obj.ValueIndex = [];
            else
                if isempty(obj.ItemsData)
                    [tf, selIdx] = ismember(value, obj.Items);
                else
                    [tf, selIdx] = ismember(value, obj.ItemsData);
                end
                if ~all(tf)
                    if isempty(obj.ItemsData)
                        itemValueName = 'Items';
                    else
                        itemValueName = 'ItemsData';
                    end
                    error("widgets:ListSelector:InvalidValue",...
                        "'Value' must be an element defined in the '%s' property.", itemValueName)
                end
                if ~isempty(obj.ItemsData) && numel(tf) > numel(obj.Items)
                    error("widgets:ListSelector:InvalidValue",...
                        "'Value' must be an element defined in the 'ItemsData' property within the length of the 'Items' property.")
                end
                obj.ValueIndex = selIdx;
            end
        end


        function value = get.HighlightedValue(obj)
            selIdx = obj.ListBox.Value;
            if isempty(selIdx) || ~isnumeric(selIdx)
                selIdx = [];
            end
            if isempty(obj.ItemsData)
                value = obj.Items(:,selIdx);
            else
                value = obj.ItemsData(:,selIdx);
            end
        end

        function set.HighlightedValue(obj,value)
            if isempty(value)
                obj.ListBox.Value = {};
                return;
            end
            if isempty(obj.ItemsData)
                [~, obj.ListBox.Value] = ismember(value, obj.Items);
            else
                [~, obj.ListBox.Value] = ismember(value, obj.ItemsData);
            end
        end

    end %methods


    %% Read-only dependent properties
    properties (AbortSet, Dependent, SetAccess = private)

        % Indices of the highlighted items
        HighlightedIndex

    end %properties

    methods

        function value = get.HighlightedIndex(obj)
            value = obj.ListBox.Value;
            if isempty(value)
                value = [];
            end
        end

    end %methods



    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = protected)

        % The ListBox control
        ListBox (1,1) matlab.ui.control.ListBox

        % The list sorting buttons
        ListButtons wt.ButtonGrid

        % Listen to button pushes in sections
        ButtonPushedListener event.listener

    end %properties


    properties (SetAccess = private)

        % Additional user buttons may be attached to this ButtonGrid
        UserButtons wt.ButtonGrid

    end %properties


    %% Hidden compatibility properties
    properties (AbortSet, Dependent, Hidden)

        % Indices of displayed items that are currently added to the list (for backward compatibility - use ValueIndex instead)
        SelectedIndex (1,:)

    end %properties
    
    methods

        function value = get.SelectedIndex(obj)
            value = obj.ValueIndex;
        end

        function set.SelectedIndex(obj,value)
            obj.ValueIndex = value;
        end

    end %methods



    %% Protected methods
    methods (Access = protected)

        function setup(obj)

            % Call superclass method
            obj.setup@wt.abstract.BaseWidget()

            % Set default size
            obj.Position(3:4) = [120 130];

            % Configure grid
            obj.Grid.Padding = 3;
            obj.Grid.ColumnWidth = {'1x','fit'};
            obj.Grid.RowHeight = {'fit','1x'};

            % Create the list buttons
            obj.ListButtons = wt.ButtonGrid(obj.Grid);
            obj.ListButtons.Icon = ["add_24.png", "delete_24.png", "up_24.png", "down_24.png"];
            obj.ListButtons.ButtonTag = ["Add", "Remove", "Up", "Down"];
            obj.ListButtons.Layout.Column = 2;
            obj.ListButtons.Layout.Row = 1;
            obj.ListButtons.Orientation = "vertical";
            obj.ListButtons.ButtonHeight(:) = {25};

            % Create an additional button grid for custom buttons
            obj.UserButtons = wt.ButtonGrid(obj.Grid,"Icon",[]);
            obj.UserButtons.Layout.Column = 2;
            obj.UserButtons.Layout.Row = 2;
            obj.UserButtons.Orientation = "vertical";

            % Create the ListBox
            obj.ListBox = uilistbox(obj.Grid);
            obj.ListBox.Multiselect = true;
            obj.ListBox.ValueChangedFcn = @(h,e)obj.onSelectionChanged(e);
            obj.ListBox.Layout.Column = 1;
            obj.ListBox.Layout.Row = [1 2];

            % Update listeners
            obj.ButtonPushedListener = event.listener(...
                [obj.ListButtons obj.UserButtons],...
                'ButtonPushed',@(h,e)obj.onButtonPushed(e) );

            % Update the internal component lists
            obj.BackgroundColorableComponents = [obj.ListButtons, obj.UserButtons obj.Grid];
            obj.FontStyledComponents = [obj.ListBox, obj.UserButtons, obj.ListButtons];
            obj.EnableableComponents = [obj.ListBox, obj.UserButtons, obj.ListButtons];
            obj.ButtonColorableComponents = [obj.UserButtons obj.ListButtons];
            obj.FieldColorableComponents = [obj.ListBox];

        end %function


        function update(obj)

            % What is selected?
            selIdx = obj.ValueIndex;

            % Is the list sortable?
            if obj.Sortable
                obj.ListButtons.Icon = ["add_24.png", "delete_24.png", "up_24.png", "down_24.png"];
                obj.ListButtons.ButtonTag = ["Add", "Remove", "Up", "Down"];
            else
                selIdx = sort(selIdx);
                obj.ListButtons.Icon = ["add_24.png", "delete_24.png"];
                obj.ListButtons.ButtonTag = ["Add", "Remove"];
            end

            % Update the list
            obj.ListBox.Items = obj.Items(selIdx);
            obj.ListBox.ItemsData = selIdx;

            % Button width and height
            obj.UserButtons.ButtonWidth = obj.ButtonWidth;
            obj.ListButtons.ButtonWidth = obj.ButtonWidth;
            obj.UserButtons.ButtonHeight = obj.ButtonHeight;
            obj.ListButtons.ButtonHeight = obj.ButtonHeight;

            % Update button enable states
            obj.updateEnables();

        end %function


        function updateEnables(obj)

            % Button enables
            if obj.Enable

                % What is selected?
                selIdx = obj.ValueIndex;
                numRows = numel(selIdx);

                % Highlighted selection in list?
                hiliteIdx = obj.getListBoxSelectedIndex();

                % Should the sort buttons be enabled?
                [backEnabled, fwdEnabled] = obj.areOrderButtonsEnabled(numRows, hiliteIdx);

                % How many items selected into list

                % Toggle button enables
                obj.ListButtons.ButtonEnable = [
                    obj.AllowDuplicates || ( numel(selIdx) < numel(obj.Items) ) %Add Button
                    ~isempty(hiliteIdx) % Delete Button
                    backEnabled %Up Button
                    fwdEnabled %Down Button
                    ];

            end %if obj.Enable

        end %function


        function onSelectionChanged(obj,evt)

            % Get the new and old values
            if isempty(obj.ItemsData)
                itemsData = obj.Items;
            else
                itemsData = obj.ItemsData;
            end

            if isempty(evt.PreviousValue)
                oldValue = itemsData([]);
            else
                oldValue = itemsData(evt.PreviousValue);
            end

            if isempty(evt.Value)
                newValue = itemsData([]);
            else
                newValue = itemsData(evt.Value);
            end

            % Update button enable states
            obj.updateEnables();

            % Trigger event
            evtOut = wt.eventdata.ValueChangedData(newValue, oldValue);
            notify(obj,"HighlightedValueChanged",evtOut);

        end %function


        function onButtonPushed(obj,evt)

            % Which button?
            switch evt.Tag

                case 'Add'

                    switch obj.AddSource

                        case wt.enum.ListAddSource.Items
                            obj.promptToAddListItems()

                        case wt.enum.ListAddSource.ButtonPushedFcn
                            notify(obj,"ButtonPushed",evt);

                    end %switch obj.AddSource

                case 'Remove'
                    obj.removeListBoxSelection();

                case 'Up'
                    obj.shiftListBoxIndex(-1);

                case 'Down'
                    obj.shiftListBoxIndex(1);

                otherwise
                    % Trigger event for user buttons
                    notify(obj,"ButtonPushed",evt);

            end %switch

            % Request update
            obj.update();

        end %function


        function promptToAddListItems(obj)
            % Prompt a dialog to add items to the listbox

            % Take ItemsData into account while displaying Items
            items = obj.Items;
            if ~isempty(obj.ItemsData)
                items = items(1:min(numel(items), numel(obj.ItemsData)));
            end

            % Prompt for stuff to add
            if obj.AllowDuplicates
                newSelIdx = listdlg("ListString",items);
            else
                newSelIdx = listdlg(...
                    "ListString",items,...
                    "InitialValue",obj.ListBox.ItemsData);
            end

            % Restore figure focus
            fig = ancestor(obj,"figure");
            if isscalar(fig) && isvalid(fig)
                figure(fig)
            end
            
            if isempty(newSelIdx)
                % User cancelled
                return
            elseif obj.AllowDuplicates
                newSelIdx = [obj.ValueIndex newSelIdx];
            end

            % Was a change made?
            if ~isequal(obj.ValueIndex, newSelIdx)

                % Get the original value
                oldValue = obj.Value;

                % Make the update
                obj.ValueIndex = newSelIdx;

                % Trigger event
                evtOut = wt.eventdata.ValueChangedData(obj.Value, oldValue);
                notify(obj,"ValueChanged",evtOut);

            end %if

        end %function


        function selIdx = getListBoxSelectedIndex(obj)
            % Get the current selected row indices in the listbox

            if isMATLABReleaseOlderThan("R2023b")
                warnState = warning('off','MATLAB:structOnObject');
                s = struct(obj.ListBox);
                warning(warnState);
                selIdx = s.SelectedIndex;
                if isequal(selIdx, -1)
                    selIdx = [];
                end
            else
                selIdx = obj.ListBox.ValueIndex;
            end

        end %function


        function removeListBoxSelection(obj)
            % Removes the currently selected items from the listbox

            % What's currently selected?
            idxSel = obj.getListBoxSelectedIndex();

            % Is there something to remove?
            if ~isempty(idxSel)

                % Get the original value
                oldValue = obj.Value;

                % Remove it
                obj.ListBox.Items(idxSel) = [];
                obj.ListBox.ItemsData(idxSel) = [];

                % Trigger event
                evtOut = wt.eventdata.ValueChangedData(obj.Value, oldValue);
                notify(obj,"ValueChanged",evtOut);

            end %if

        end %function


        function shiftListBoxIndex(obj, shift)
            % Shift selected items up/down within a listbox
            % This assumes ItemsData contains unique values

            % What is the current order and total items?
            idxSel = obj.getListBoxSelectedIndex();
            numItems = numel(obj.ListBox.Items);

            % Shift the list indices
            % [idxNew, idxSelAfter] = obj.shiftListIndices(shift, numItems, idxSel);
            [idxNew, ~] = obj.shiftListIndices(shift, numItems, idxSel);

            % Get the original value
            oldValue = obj.Value;

            % Make the shift
            obj.ListBox.Items = obj.ListBox.Items(idxNew);
            obj.ListBox.ItemsData = obj.ListBox.ItemsData(idxNew);
            % obj.ListBox.Selection = idxSelAfter;

            % Trigger event
            evtOut = wt.eventdata.ValueChangedData(obj.Value, oldValue);
            notify(obj,"ValueChanged",evtOut);

            % Update buttons
            obj.updateEnables()

        end %function

        function val = getMaximumValidItemsNumber(obj)
            % Returns maximum valid selected index.
            % Takes into account ItemsData and Items.

            % Is ItemsData available?
            if ~isempty(obj.ItemsData)
                val = min(numel(obj.ItemsData), numel(obj.Items));
            else
                val = numel(obj.Items);
            end

        end %function

    end %methods

end % classdef