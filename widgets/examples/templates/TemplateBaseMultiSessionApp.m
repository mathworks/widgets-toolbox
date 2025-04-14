classdef TemplateBaseMultiSessionApp < wt.apps.BaseMultiSessionApp
    % Implements a template for a BaseSingleSessionApp

    % Copyright 2022-2025 The MathWorks Inc.

    %% Internal Components
    %   Create properties here for each control, layout, or view component
    %   that will be placed directly into the main app window.
    properties ( Transient, NonCopyable, SetAccess = protected )

        % Once the app is created and debugged, consider also protecting
        % get access to these properties. Leave them accessible to unit
        % tests, however. Use this example:
        % GetAccess = {?matlab.uitest.TestCase, ?wt.apps.BaseApp})

        % Grid Layouts
        % (BaseApp already brings "Grid", the main Grid layout in the window)
        Tab1Grid matlab.ui.container.GridLayout
        Tab2Grid matlab.ui.container.GridLayout
        SessionListPanelGrid matlab.ui.container.GridLayout
        SessionDescriptionPanelGrid matlab.ui.container.GridLayout
        Panel2Grid matlab.ui.container.GridLayout

        % Panels
        SessionListPanel matlab.ui.container.Panel
        SessionDescriptionPanel matlab.ui.container.Panel
        Panel2 matlab.ui.container.Panel

        % Tabs
        TabGroup matlab.ui.container.TabGroup
        Tab1 matlab.ui.container.Tab
        Tab2 matlab.ui.container.Tab

        % Toolbar and sections
        Toolbar wt.Toolbar
        FileSection wt.toolbar.HorizontalSection
        HelpSection wt.toolbar.HorizontalSection

        % Toolbar buttons
        NewButton matlab.ui.control.Button
        OpenButton matlab.ui.control.Button
        SaveButton matlab.ui.control.Button
        SaveAsButton matlab.ui.control.Button
        CloseButton matlab.ui.control.Button
        HelpButton matlab.ui.control.Button

        % View Components
        %View1 namespace.ClassName
        %View2 namespace.ClassName

        % Session information components
        SessionList matlab.ui.control.ListBox
        SessionDescription matlab.ui.control.TextArea

        % Temporary label components
        Panel2Text matlab.ui.control.Label
        Tab1Text matlab.ui.control.Label
        Tab2Text matlab.ui.control.Label

    end %properties



    %% Setup and Configuration of the App
    methods  ( Access = protected )

        function setup(app)
            % Runs once on instantiation of the app

            % Set the name
            app.Name = "My App";

            % Configure the main grid
            app.Grid.ColumnWidth = {300,'1x'};
            app.Grid.RowHeight = {100,'1x',150};
            app.Grid.Padding = 5;

            % Create toolbar (split out for brevity)
            app.createToolbar()

            % Create a panel for session list
            app.SessionListPanel = uipanel(app.Grid);
            app.SessionListPanel.Title = "Sessions";
            app.SessionListPanel.Layout.Row = 2;
            app.SessionListPanel.Layout.Column = 1;

            % Create a panel for session description
            app.SessionDescriptionPanel = uipanel(app.Grid);
            app.SessionDescriptionPanel.Title = "Session Description:";
            app.SessionDescriptionPanel.Layout.Row = 3;
            app.SessionDescriptionPanel.Layout.Column = 1;

            % Create a panel
            app.Panel2 = uipanel(app.Grid);
            app.Panel2.Title = "Panel 2";
            app.Panel2.Layout.Row = 3;
            app.Panel2.Layout.Column = 2;

            % Create a tab group
            app.TabGroup = uitabgroup(app.Grid);
            app.TabGroup.Layout.Row = 2;
            app.TabGroup.Layout.Column = 2;
            app.TabGroup.SelectionChangedFcn = @(h,e)onTabChanged(app,e);

            % Create Tabs, each with a grid
            app.Tab1 = uitab(app.TabGroup);
            app.Tab1.Title = 'Tab 1';

            app.Tab2 = uitab(app.TabGroup);
            app.Tab2.Title = 'Tab 2';

            % Create grid layouts to position content inside each container
            app.SessionListPanelGrid = uigridlayout(...
                app.SessionListPanel, [1,1],"Padding", 0);
            app.SessionDescriptionPanelGrid = uigridlayout(...
                app.SessionDescriptionPanel, [1,1],"Padding", 0);
            app.Panel2Grid = uigridlayout(app.Panel2, [1,1],"Padding", 0);
            app.Tab1Grid = uigridlayout(app.Tab1, [1,1],"Padding", 0);
            app.Tab2Grid = uigridlayout(app.Tab2, [1,1],"Padding", 0);

            % Put a listbox of the sessions
            app.SessionList = uilistbox(app.SessionListPanelGrid);
            app.SessionList.FontSize = 16;
            app.SessionList.ValueChangedFcn = @(~,evt)onSessionListChanged(app,evt);

            % Put a description for the selected session
            app.SessionDescription = uitextarea(app.SessionDescriptionPanelGrid);
            app.SessionDescription.ValueChangedFcn = ...
                @(~,evt)onSessionDescriptionChanged(app,evt);

            % Add contents to other panes
            app.Panel2Text = uilabel(app.Panel2Grid);
            app.Panel2Text.Text = "Panel 2 Contents";
            app.Panel2Text.HorizontalAlignment = "center";
            app.Panel2Text.FontSize = 30;
            app.Panel2Text.Layout.Row = 1;
            app.Panel2Text.Layout.Column = 1;

            app.Tab1Text = uilabel(app.Tab1Grid);
            app.Tab1Text.Text = "Tab 1 Contents";
            app.Tab1Text.HorizontalAlignment = "center";
            app.Tab1Text.FontSize = 30;
            app.Tab1Text.Layout.Row = 1;
            app.Tab1Text.Layout.Column = 1;

            app.Tab2Text = uilabel(app.Tab2Grid);
            app.Tab2Text.Text = "Tab 2 Contents";
            app.Tab2Text.HorizontalAlignment = "center";
            app.Tab2Text.FontSize = 30;
            app.Tab2Text.Layout.Row = 1;
            app.Tab2Text.Layout.Column = 1;

            % Additional examples:
            % (add other views, layouts, and components here as needed)
            %app.View1 = namespace.ClassName( app.Tab1Grid );
            %app.View2 = namespace.ClassName( app.Tab2Grid );

        end %function


        function createToolbar(app)
            % Create the toolbar contents

            % (This method is optional if using a toolbar. It's split out
            % into the separate method here to keep the setup method
            % shorter)

            % Create the toolbar container
            app.Toolbar = wt.Toolbar(app.Grid);
            app.Toolbar.Layout.Row = 1;
            app.Toolbar.Layout.Column = [1 2];

            % File Section
            app.FileSection = wt.toolbar.HorizontalSection();
            app.FileSection.Title = "FILE";
            app.FileSection.ButtonPushedFcn = @(~,evt)onFileToolbarButtonPushed(app,evt);

            app.NewButton = app.FileSection.addButton('add_24.png','New Session');
            app.OpenButton = app.FileSection.addButton('folder_24.png','Open Session');
            app.SaveButton = app.FileSection.addButton('save_24.png','Save Session');
            app.SaveAsButton = app.FileSection.addButton("saveClean_24.png","Save As");
            app.CloseButton = app.FileSection.addButton("close_24.png","Close Session");

            app.FileSection.ComponentWidth(:) = 55;

            % Help Section
            app.HelpSection = wt.toolbar.HorizontalSection();
            app.HelpSection.Title = "HELP";
            app.HelpButton = app.HelpSection.addButton('help_24.png','Help');
            app.HelpButton.ButtonPushedFcn = @(h,e)onHelpButton(app);

            % Add all toolbar sections to the toolbar
            % This is done last for performance reasons
            app.Toolbar.Section = [
                app.FileSection
                app.HelpSection
                ];

        end %function


        function sessionObj = createNewSession(~)
            % Create and return a new session object for this app

            % The session should be a class that inherits wt.model.BaseSession
            %sessionObj = namespace.SessionClassName;

            % For example purposes, using this one:
            sessionObj = wt.model.BaseSession;

        end %function

    end %methods

    %% Update
    methods  ( Access = protected )

        function update(app)
            % Update the display of the app
            % For the main app, app.update() must be called explicitly
            % during callbacks or other changes that require contents to
            % refresh.

            % Get selected session
            selSession = app.SelectedSession;

            % Update the session list
            app.SessionList.Items = app.SessionDisplayNames;
            app.SessionList.ItemsData = app.Session;
            if isempty(selSession) || ~ismember(selSession, app.Session)
                app.SessionList.Value = {};
            else
                app.SessionList.Value = selSession;
            end

            % Update the session description
            if isempty(selSession)
                app.SessionDescription.Value = "";
                app.SessionDescription.Enable = false;
                app.SessionDescription.UserData = [];
            else
                app.SessionDescription.Value = selSession.Description;
                app.SessionDescription.Enable = true;
                app.SessionDescription.UserData = selSession;
            end

            % Update toolbar button enables
            app.updateToolbarEnables()

            % Examples:
            %app.View1.Model = sessionObj;
            %app.View2.Model = sessionObj;

        end %function


        function updateToolbarEnables(app)

            % Get the session states
            selSession = app.SelectedSession;
            hasSelectedSession = isscalar(selSession);
            hasDirtySession = hasSelectedSession && selSession.Dirty;

            % File toolbar enables
            app.SaveButton.Enable = hasDirtySession;
            app.SaveAsButton.Enable = hasSelectedSession;
            app.CloseButton.Enable = hasSelectedSession;

        end %function

    end %methods


    %% Callbacks
    methods

        function onTabChanged(app,evt)
            % Triggered on changing tab

            % (this method is optional if using tabs)

            newTab = evt.NewValue;
            disp("Selected Tab: " + newTab.Title);

        end %function


        function onSessionListChanged(app,evt)
            % Triggered on selecting from the session list

            % (this method is optional if using tabs)

            % What was selected?
            newValue = evt.Value;

            % Select the session
            app.selectSession(newValue);
            
            % Update the app
            app.update();

        end %function


        function onSessionDescriptionChanged(app,evt)
            % Triggered on editing a session description

            % Get the new value
            newValue = join(string(evt.Value), newline);

            % Get the session tied to the field
            % Otherwise, if you click off the field immediately to select
            % another session, it edits the wrong session!
            session = app.SessionDescription.UserData;

            % Update the session description
            session.Description = newValue;

        end %function


        function onFileToolbarButtonPushed(app,evt)

            % Which button was pressed?
            switch evt.Button

                case app.NewButton

                    % Add a new session
                    session = app.newSession();

                    % Select the new session
                    if ~isempty(session)
                        app.selectSession(session);
                    end

                case app.OpenButton

                    % Prompt and load a session
                    session = app.loadSession();

                    % Select the new session
                    if ~isempty(session)
                        app.selectSession(session);
                    end

                case app.SaveButton

                    % Save the selected session
                    app.saveSession(false);

                case app.SaveAsButton

                    % Save the selected session as different file
                    app.saveSession(true);

                case app.CloseButton

                    % Close the currently selected session
                    app.closeSession();

            end %switch

        end %function


        function onHelpButton(app)
            % Triggered when the toolbar button is pressed

            disp("Help Button Pushed!");

        end %function

    end %methods

end %classdef