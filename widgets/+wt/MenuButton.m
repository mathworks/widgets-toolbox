classdef MenuButton < wt.abstract.BaseWidget & ...
        wt.mixin.ButtonColorable
    % Implements a button that provides a custom context menu

    % Copyright 2025 The MathWorks Inc.


    %% Events
    events (HasCallbackProperty, NotifyAccess = protected)

        % Triggered when a menu item is selected
        MenuSelected

        % Triggered when the button is pushed
        ButtonPushed

    end %events


    %% Properties

    properties (AbortSet)

        % Icons
        Icon (1,1) string = "kebabMenu_50.png"

        % Tooltip
        Tooltip (1,1) string = ""

    end %properties


    %% Read-only properties
    properties (SetAccess = protected)

        % Root-level menu
        Menu matlab.ui.container.ContextMenu

    end %properties


    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = protected)

        % The button
        Button matlab.ui.control.Button

    end %properties


    %% Public methods
    methods

        function newItem = addMenuItems(obj, names, tags)
            % Add simple menu items

            arguments
                obj
                names (:,1) string
                tags (:,1) string = repmat("",size(names))
            end

            % Validate tags is the same length as names
            validateattributes(tags, {'string'}, {'vector', 'numel', length(names)});

            % Remove the dummy menu items
            oldItems = obj.Menu.Children;
            if numel(oldItems) == 2
                isDummy = startsWith({oldItems.Tag}, "dummy");
                delete(oldItems(isDummy))
            end

            % Create menu items based on provided names and tags
            newItem = matlab.ui.container.Menu.empty(0,1);
            for idx = 1:length(names)
                newItem(idx,1) = uimenu("Parent", obj.Menu,...
                    "Text", names(idx),...
                    "Tag", tags(idx),...
                    "MenuSelectedFcn", @(~,evt)onMenuSelected(obj,evt) );
            end

        end %function


        function newItem = addSubMenuItems(obj, parent, names, tags)
            % Add sub-menu items to an existing menu item

            arguments
                obj
                parent (1,1) matlab.ui.container.Menu
                names (:,1) string
                tags (:,1) string = repmat("",size(names))
            end

            % Validate tags is the same length as names
            validateattributes(tags, {'string'}, {'vector', 'numel', length(names)});

            % Create menu items based on provided names and tags
            newItem = matlab.ui.container.Menu.empty(0,1);
            for idx = 1:length(names)
                newItem(idx,1) = uimenu("Parent", parent,...
                    "Text", names(idx),...
                    "Tag", tags(idx),...
                    "MenuSelectedFcn", @(~,evt)onMenuSelected(obj,evt) );
            end

        end %function


        function openMenu(obj)
            % Opens the menu (also triggered by button pushed)

            % Find the figure and attach the context menu
            fig = ancestor(obj,'figure');
            obj.Menu.Parent = fig;

            % Find the button's location in the figure
            pos = getpixelposition(obj.Button, true);
            pos = [pos(1)+pos(3), pos(2)]; %lower-right

            % Open the menu
            obj.Menu.open(pos);

        end %function

    end %methods


    %% Protected methods
    methods (Access = protected)

        function setup(obj)

            % Call superclass method
            obj.setup@wt.abstract.BaseWidget()

            % Set default size
            obj.Position(3:4) = [30 30];

            % Create the button
            obj.Button = uibutton(obj.Grid);
            obj.Button.Text = "";
            obj.Button.Icon = "kebabMenu_50.png";

            % Set the callback for the button
            obj.Button.ButtonPushedFcn = @(~,~)obj.onButtonPushed();

            % Create the context menu
            obj.Menu = matlab.ui.container.ContextMenu;

            % Add two dummy items
            obj.addMenuItems(["Item 1","Item 2"], ["dummy1","dummy2"]);

            % Find the figure and attach it
            fig = ancestor(obj,'figure');
            obj.Menu.Parent = fig;

            % Update component list
            obj.ButtonColorableComponents = obj.Button;

        end %function


        function update(obj)

            % Update the button
            obj.Button.Icon = obj.Icon;
            obj.Button.Tooltip = obj.Tooltip;

        end %function


        function onButtonPushed(obj)

            % Notify listeners
            notify(obj, 'ButtonPushed');

            % Open the menu
            obj.openMenu();

        end %function


        function onMenuSelected(obj,evt)

            % Create eventdata for listeners / callback
            evtOut = wt.eventdata.MenuSelectedData(evt);

            % Notify listeners
            notify(obj, 'MenuSelected', evtOut);

        end %function

    end %methods

end %classdef