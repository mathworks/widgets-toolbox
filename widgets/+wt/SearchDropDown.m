classdef SearchDropDown < wt.abstract.BaseWidget &...
        wt.mixin.Enableable & ...
        wt.mixin.FieldColorable & ...
        wt.mixin.FontStyled & ...
        wt.mixin.Tooltipable
    % Searchable text field with drop down list

    % Copyright 2025 The MathWorks Inc.

    % This is a prototype widget that is like an editable dropdown, but it
    % enables you to search/filter better as you type. It combines an edit
    % field with a listbox below. Space beneath is required for it to work.

    % Known Issues
    % 1. If you are typing in edit field and hit down arrow, it should go
    % into the list below, but instead it completes the edit. But if you
    % tab or enter to finish editing, it should complete the edit.


    %% Events
    events (HasCallbackProperty, NotifyAccess = protected)

        % Triggered on value changed, has companion callback
        ValueChanged

    end %events


    %% Public properties
    properties (AbortSet)

        % Placeholder
        Placeholder (1,1) string = ""

        % List of items to choose from
        Items (:,1) string

        % Confirmed value, selected by the user
        Value (1,1) string

    end %properties


    %% Read-only properties
    properties (SetAccess = protected, UsedInUpdate = false)

        % Current typed value, displayed in the edit field
        EditingValue (1,1) string

    end %properties



    %% Internal Properties
    properties (Hidden)

        Debug (1,1) logical = false

    end %properties


    properties (Dependent, Hidden, SetAccess = immutable)

        % Indicates search panel exists
        SearchExists (1,1) logical

        % Indicates search is open
        SearchOpen (1,1) logical

    end %properties


    properties (Transient, NonCopyable, Hidden, ...
            SetAccess = protected, UsedInUpdate = false)

        % Edit field
        EditField matlab.ui.control.EditField

        % Search panel for drop down
        SearchPanel matlab.ui.container.Panel

        % Grid for drop down
        SearchGrid matlab.ui.container.GridLayout

        % List selection
        ListBox  matlab.ui.control.ListBox

        % Event listeners
        LocationChangedListener event.listener
        FigureCurrentObjectListener event.proplistener
        FigureActivatedListener event.listener
        FigureDeactivatedListener event.listener
        WindowKeyPressListener event.listener

        ListButtonDownListener event.listener
        WindowMouseDownListener event.listener
        WindowMouseReleaseListener event.listener


        LastClick (1,1) string

        % Figure ancestor
        Figure matlab.ui.Figure

    end %properties

    % Accessors
    methods
        function tf = get.SearchOpen(obj)
            tf = obj.SearchExists && obj.SearchPanel.Visible;
        end
        function tf = get.SearchExists(obj)
            tf = isscalar(obj.SearchPanel) && isvalid(obj.SearchPanel);
        end
    end


    %% Protected methods
    methods (Access = protected)

        function setup(obj)

            % Call superclass method
            obj.setup@wt.abstract.BaseWidget()

            % Set default size
            obj.Position(3:4) = [100 30];

            % Configure Main Grid
            % obj.Grid.Padding = 2;

            % Create the edit control for user input
            obj.EditField = uieditfield(obj.Grid, 'text');
            obj.EditField.ValueChangingFcn = @(~,evt)onEditValueChanging(obj,evt);
            obj.EditField.ValueChangedFcn = @(~,evt)onEditValueChanged(obj,evt);

            % Create the search pannel (hidden)
            obj.createSearchPanel()

            % Attach figure
            obj.Figure = ancestor(obj,'figure');

            % Configure listeners
            obj.LocationChangedListener = listener(obj.EditField, ...
                "LocationChanged", @(~,evt)onLocationChanged(obj,evt));

            % Listen to figure change
            obj.createFigureListeners();

            % Update the internal component lists
            % obj.BackgroundColorableComponents = obj.Grid;

        end %function


        function update(obj)

            if obj.Debug
                disp('update');
            end

            % Update the contents
            obj.EditField.Placeholder = obj.Placeholder;
            obj.EditField.Value = obj.Value;
            % obj.EditField.Value = obj.EditingValue;

            % Update filtered list
            % obj.updateFilteredList()

            % Close the search panel
            % (without giving focus to the edit field)
            obj.closeSearchPanel(false);

        end %function


        function createSearchPanel(obj)

            if obj.Debug
                disp('createSearchPanel');
            end

            % Create the search panel content
            obj.SearchPanel = uipanel("Parent",[]);

            % Create the grid layout for the search panel
            obj.SearchGrid = uigridlayout(obj.SearchPanel);
            obj.SearchGrid.RowHeight = {'1x'};
            obj.SearchGrid.ColumnWidth = {'1x'};
            obj.SearchGrid.Padding = 0;

            % Create the list box for displaying search results
            obj.ListBox = uilistbox(obj.SearchGrid);
            obj.ListBox.ValueChangedFcn = @(~,evt)onListValueChanged(obj,evt);


            % Check for clicks
            if isMATLABReleaseOlderThan("R2022b")

            else
                % R2022b and later can use this
                obj.ListBox.ClickedFcn = @(~,evt)onListClicked(obj,evt);
            end

            % Listen for button down on list
            obj.ListButtonDownListener = listener(obj.ListBox, ...
                "ButtonDown", @(~,evt)onListButtonDown(obj,evt));

            % Later: Add more controls for case sensitive, etc.

            % Update the internal component lists
            obj.FontStyledComponents = [obj.EditField, obj.ListBox];
            obj.FieldColorableComponents = [obj.EditField, obj.ListBox];
            obj.EnableableComponents = [obj.EditField];
            obj.TooltipableComponents = [obj.EditField];
            obj.BackgroundColorableComponents = [obj.Grid, obj.SearchPanel, obj.SearchGrid];

        end %function


        function openSearchPanel(obj)

            if obj.Debug
                disp('openSearchPanel');
            end

            % Has figure changed?
            currentFigure = ancestor(obj,'figure');
            if ~isequal(currentFigure, obj.Figure)
                obj.onLocationChanged();
            end

            % Does the search panel exist?
            if ~obj.SearchExists
                obj.createSearchPanel();
            end

            % Show the complete list initially
            items = obj.Items;
            obj.ListBox.Items = items;

            % What to select as default in list?
            if isempty(items)
                % Empty list selection
                obj.ListBox.Value = {};
            else
                % Default to first item
                obj.ListBox.Value = items(1);
            end
            idxInit = find(matches(items, obj.Value), 1);
            if isscalar(idxInit)
                % Default to matching item
                obj.ListBox.Value = items(idxInit);
            else
                % Empty list selection
                obj.ListBox.Value = {};
            end

            % Show the search panel
            obj.SearchPanel.Parent = obj.Figure;

            % Update position
            obj.updateSearchPanelPosition()

            % Toggle visible
            obj.SearchPanel.Visible = 'on';

            % Focus back on edit field
            % disp("  openSearchPanel: Focus EditField");
            % focus(obj.EditField)

        end %function


        function updateSearchPanelPosition(obj)

            if obj.Debug
                disp('updateSearchPanelPosition');
            end

            % if obj.SearchOpen
            if obj.SearchExists

                % Calculate position
                edPos = getpixelposition(obj.EditField, true);
                maxHeight = 300;
                x = edPos(1);
                w = edPos(3);
                h = edPos(2) - 10;
                h = min(h, maxHeight);
                y = edPos(2) - h;
                searchPosition = [x y w h];

                % Set position
                obj.SearchPanel.Position = searchPosition;

            end

        end %function


        function closeSearchPanel(obj, focusEdit)

            arguments
                obj
                focusEdit (1,1) logical = false;
            end

            if obj.Debug
                disp('closeSearchPanel');
            end

            % Is the search panel open?
            if obj.SearchOpen

                % Hide the search panel
                obj.SearchPanel.Visible = 'off';

            end %if

            % Is it in focus? If so, focus to the edit field instead
            if obj.SearchExists

                if obj.Debug
                    disp('  closeSearchPanel: check current focus object');
                end

                curObj = obj.Figure.CurrentObject;

                searchObjs = [
                    obj.SearchGrid
                    obj.SearchPanel
                    obj.ListBox
                    ];

                if isscalar(curObj) && any(curObj == searchObjs) && focusEdit
                    if obj.Debug
                        disp("  closeSearchPanel: Focus EditField");
                    end
                    focus(obj.EditField)
                end

            end

            % curObjNew = obj.Figure.CurrentObject;

        end %function


        function updateFilteredList(obj)
            % display the filtered items in the listbox

            if obj.Debug
                disp('updateFilteredList');
            end

            if obj.SearchExists

                allItems = obj.Items;
                isMatch = contains(allItems, obj.EditingValue, 'IgnoreCase', true);
                items = allItems(isMatch);

                % Update the list contents
                obj.ListBox.Items = items;

                % What to select as default in list?
                % if isempty(items)
                %     % Empty list selection
                %     obj.ListBox.Value = {};
                % elseif isempty(obj.ListBox.Value)
                %     % Default to first item
                %     obj.ListBox.Value = items(1);
                % else
                %     % Leave selection as-is
                % end

            end %if

        end %function


        function onListValueChanged(obj,evt)
            % Triggered after an item in the list has been selected

            if obj.Debug
                fprintf("onListValueChanged EventValue: %s ListboxValue: %s  LastClick: %s\n", evt.Value, string(obj.ListBox.Value), obj.LastClick);
            end

            newValue = evt.Value;
            obj.EditingValue = newValue;

            switch obj.LastClick

                case "ListBox"

                    % Clear state
                    obj.LastClick = "";

                    if isMATLABReleaseOlderThan("R2022b")

                        % Accept the value and close the
                        obj.acceptEditValue();

                        % Close the search panel
                        % and give focus to the edit field
                        obj.closeSearchPanel(true);

                    end

            end %switch

        end %function


        function onListClicked(obj,evt)
            % Triggered after an item in the list has been clicked
            % (R2022b and later only)

            % Get the changed value
            % newValue = string(obj.ListBox.Value)
            idx = evt.InteractionInformation.Item;
            newValue = string(obj.ListBox.Items(idx));

            if obj.Debug
                % disp("onListClicked");
                fprintf("onListClicked Index: %d  ItemValue: %s ListboxValue: %s\n", idx, newValue, string(obj.ListBox.Value));
            end

            % Was an item clicked (rather than empty space)?
            if isscalar(newValue)

                % Complete the action
                obj.EditingValue = newValue;

                % Accept the value
                obj.acceptEditValue();

                % Close the search panel
                % Do not give focus to the edit field
                obj.closeSearchPanel(false);

            end %if

        end %function


        function onFigureButtonDown(obj,evt)
            % Triggered on any click within the figure


            if obj.Debug
                fprintf("onFigureButtonDown ClickOn: %s  ListboxValue: %s\n", class(evt.HitObject), string(obj.ListBox.Value));
            end


            switch evt.HitObject

                case obj.ListBox

                    obj.LastClick = "ListBox";

                    if isMATLABReleaseOlderThan("R2022b")
                        % For R2022a

                        % % Get the changed value
                        % newValue = string(obj.ListBox.Value);
                        %
                        %
                        % fprintf("  onFigureButtonDown (R2022a) - Accepting ListboxValue: %s\n", newValue);
                        %
                        % % Complete the action
                        % obj.EditingValue = newValue;
                        %
                        % % Accept the value and close the
                        % obj.acceptEditValue();
                        %
                        % % Close the search panel
                        % obj.closeSearchPanel(true);


                    else
                        % R2022b and later can use this

                    end

                case obj.EditField

                    obj.LastClick = "EditField";

                    % Do nothing
                    % The dropdown is activated elsewhere?

                otherwise
                    % Clicked any other figure object

                    obj.LastClick = "";

                    % Close the search panel
                    % Do not give focus to the edit field
                    obj.closeSearchPanel(false);

            end %switch

        end %function


        function onFigureButtonUp(obj,evt)
            % Triggered after

            if obj.Debug
                fprintf("onFigureButtonUp Hit: %s  ListboxValue: %s\n", class(evt.HitObject), string(obj.ListBox.Value));
            end

            % newValue = string(obj.ListBox.Value)

            % % Close the search panel
            % obj.closeSearchPanel();

        end %function


        function onListButtonDown(obj,evt)
            % Triggered after a key press in the list field

            % Get the changed value
            % newValue = string(obj.ListBox.Value)
            idx = evt.InteractionInformation.Item;
            newValue = string(obj.ListBox.Items(idx));

            if obj.Debug
                fprintf("onListButtonDown Index: %d  ItemValue: %s ListboxValue: %s\n", idx, newValue, string(obj.ListBox.Value));
            end

            % Complete the action
            obj.EditingValue = newValue;

            % Accept the value
            obj.acceptEditValue();

            % Close the search panel
            % and give focus to the edit field
            obj.closeSearchPanel(true);

        end %function


        function onEditValueChanging(obj,evt)
            % Triggered on edit field typing

            if obj.Debug
                fprintf("onEditValueChanging New EditingValue: %s  Existing Value: %s\n", evt.Value, obj.Value);
            end

            % Get the editing value
            newValue = evt.Value;

            % Update the value property
            obj.EditingValue = newValue;

            % Verify search is open
            if ~obj.SearchOpen
                obj.openSearchPanel();
            end

            % Update filtered list
            obj.updateFilteredList()

        end %function


        function onEditValueChanged(obj,evt)
            % Triggered on edit field enter or loss of focus

            if obj.Debug
                fprintf("onEditValueChanged New EditingValue: %s  Existing Value: %s  LastClick: %s\n", evt.Value, obj.Value, obj.LastClick);
            end

            switch obj.LastClick

                case "EditField"

                    % Clear state
                    obj.LastClick = "";

                    % Are there items available?
                    if isempty(obj.ListBox.Items)
                        % Get the editing value
                        newValue = evt.Value;
                    else
                        % Get the first match in items
                        newValue = obj.ListBox.Items(1);
                    end

                    % Update the value property
                    obj.EditingValue = newValue;

                    % Accept the value
                    obj.acceptEditValue();

                    % Close the search panel
                    %obj.closeSearchPanel(true);
                    % Disabled this in favor of closing in the update method. The
                    % problem is in 22a if we start typing in the edit, then click
                    % an item in the list, this one fires first and hides the list
                    % before the list's selection callback can occur.

            end %switch

        end %function


        function onLocationChanged(obj,~)
            % Triggered on edit field location (figure) changed

            if obj.Debug
                disp("onLoctionChanged");
            end

            % Attach figure
            obj.Figure = ancestor(obj,'figure');

            % Move SearchPanel
            if obj.SearchExists
                obj.SearchPanel.Parent = obj.Figure;
            end

            % Listen to figure events
            obj.createFigureListeners();

        end %function


        function createFigureListeners(obj)
            % Create listeners to figure changes

            if obj.Debug
                disp("createFigureListeners");
            end

            % Get the figure ancestor
            obj.Figure =  ancestor(obj,'figure');

            % Listen to current object (focus) changes
            obj.FigureCurrentObjectListener = listener(obj.Figure, ...
                "CurrentObject", "PostSet", ...
                @(~,evt)onFigureCurrentObjectChanged(obj,evt));

            % Listen to figure activation
            obj.FigureActivatedListener = listener(obj.Figure, ...
                "FigureActivated", ...
                @(~,evt)onFigureActivated(obj,evt));

            % Listen to figure deactivation
            obj.FigureDeactivatedListener = listener(obj.Figure, ...
                "FigureDeactivated", ...
                @(~,evt)onFigureDeactivated(obj,evt));


            obj.WindowMouseDownListener = listener(obj.Figure, ...
                "WindowMousePress", ...
                @(~,evt)onFigureButtonDown(obj,evt));

            obj.WindowMouseReleaseListener = listener(obj.Figure, ...
                "WindowMouseRelease", ...
                @(~,evt)onFigureButtonUp(obj,evt));

            % Listen to key presses
            obj.WindowKeyPressListener = listener(obj.Figure, ...
                "WindowKeyPress", ...
                @(~,evt)onWindowKeyPress(obj,evt));


        end %function


        function onFigureCurrentObjectChanged(obj,~)
            % Triggered after figure's current object (focus) changed


            if obj.Debug
                fprintf("onFigureCurrentObjectChanged CurrentObject: %s\n", class(obj.Figure.CurrentObject));
            end

            obj.checkForSearchActivation();

        end %function


        function onFigureActivated(obj,~)
            % Triggered after figure is activated

            if obj.Debug
                disp("onFigureActivated");
            end

            % Close list
            % obj.closeSearchPanel(false)

        end %function


        function onFigureDeactivated(obj,~)
            % Triggered after figure is deactivated

            if obj.Debug
                disp("onFigureDeactivated");
            end

            % Close list
            % obj.closeSearchPanel(false)

        end %function


        function onWindowKeyPress(obj,evt)
            % Triggered after a key is pressed in the figure


            if obj.Debug
                fprintf("onWindowKeyPress  Key: %s  CurrentObject: %s  LastClick: %s\n", evt.Key, class(obj.Figure.CurrentObject), obj.LastClick);
            end

            obj.LastClick = "";

            % Button presses
            escPressed = evt.Key == "escape" && isempty(evt.Modifier);
            downArrowPressed = evt.Key == "downarrow" && isempty(evt.Modifier);
            % upArrowPressed = evt.Key == "uparrow" && isempty(evt.Modifier);
            enterPressed = evt.Key == "return" && isempty(evt.Modifier);

            % Search state
            searchOpen = obj.SearchOpen;
            searchExists = obj.SearchExists;

            % Edit state
            curObj = obj.Figure.CurrentObject;

            % Edit focus?
            editFocus = isequal(curObj, obj.EditField);

            % Search focus?
            if searchExists
                searchObjs = [
                    obj.SearchGrid
                    obj.SearchPanel
                    obj.ListBox
                    ];
                searchFocus = isscalar(curObj) && any(curObj == searchObjs);
                % searchIndexOne = isequal(obj.ListBox.ValueIndex, 1);
            else
                searchFocus = false;
                % searchIndexOne = false;
            end

            if editFocus && enterPressed
                % If enter pressed, accept the entered value

                obj.acceptEditValue()

                % Close list
                % Do not give focus to the edit field
                obj.closeSearchPanel(false);

            elseif searchOpen && escPressed
                % If ESC is pressed while list is open, close the list

                % Close list
                % and give focus to the edit field
                obj.closeSearchPanel(true);

            elseif searchOpen && editFocus && downArrowPressed
                % Focus the search list

                if obj.Debug
                    disp("  onWindowKeyPress: Focus ListBox 1");
                end
                focus(obj.ListBox)

                % elseif searchOpen && searchFocus && upArrowPressed && searchIndexOne
                %
                %     focus(obj.EditField)

            elseif searchExists && editFocus && downArrowPressed
                % Open and focus the search list

                obj.openSearchPanel();

                if obj.Debug
                    disp("  onWindowKeyPress: Focus ListBox 3");
                end
                focus(obj.ListBox)

            elseif searchExists && ~searchOpen && editFocus
                % Open the search panel

                obj.openSearchPanel();

            elseif searchExists && ~searchOpen && searchFocus
                % If search is hidden but still focused, change to the edit
                % field focus

                % Don't know why search would be closed here

                if obj.Debug
                    disp("  onWindowKeyPress: Focus ListBox 4");
                end

                if isMATLABReleaseOlderThan("R2022b")
                    % Do nothing
                    % The edit field might actually be focused and selected,
                    % causing typing to delete the existing text in the edit
                    % field.
                else
                    focus(obj.EditField)
                end

            end %if

        end %function


        function checkForSearchActivation(obj)
            % Check current object and activate search if conditions met

            % What is in focus?
            focusObject = obj.Figure.CurrentObject;

            if focusObject == obj.EditField
                % Open list
                obj.openSearchPanel();
            elseif isequal(focusObject, obj.ListBox)
                % Ignore - do nothing
            else
                % Close list
                % Do not give focus to the edit field
                obj.closeSearchPanel(false)
            end

        end %function


        function acceptEditValue(obj)
            % Accept the currently selected value


            % Get typed value
            editValue = obj.EditingValue;
            newValue = editValue;

            if obj.Debug
                fprintf("acceptEditValue NewValue: %s  OldValue: %s\n", newValue, obj.Value);
            end

            % % Get list items
            % if obj.SearchExists
            %     items = obj.ListBox.Items;
            % else
            %     items = obj.Items;
            % end
            %
            % % Select the new value intelligently
            % if matches(editValue, items)
            %     newValue = editValue;
            % elseif isempty(items)
            %     newValue = "";
            % else
            %     newValue = items(1);
            % end

            % Prepare event data
            oldValue = obj.Value;
            evtOut = wt.eventdata.PropertyChangedData('Value', ...
                newValue, oldValue);

            % Update the value
            obj.Value = newValue;

            % Request update
            obj.requestUpdate();

            % Close the search panel
            % obj.closeSearchPanel(false);

            % Trigger event
            notify(obj,"ValueChanged",evtOut);

        end %function

    end %methods


end %classdef

