classdef ContextualViewExample < wt.apps.BaseMultiSessionApp
    % Example app showing a tree with contextual views

    % Copyright 2024 The MathWorks Inc.


    %% Internal properties
    properties (Hidden, Transient, SetAccess = private)

        % Toolbar at top of the app window
        Toolbar wt.Toolbar

        % Navigation tree on the left of the app
        Tree matlab.ui.container.Tree

        % Contextual pane to show view/controller for selected tree node
        ContextualView wt.ContextualView

        ExhibitAddButton
        ExhibitDeleteButton


        % NewSelection (:,1) wt.model.BaseModel {mustBeScalarOrEmpty}

    end %properties


    %% Protected Methods
    methods  (Access = protected)

        % Declarations for methods in separate files
        updateTreeHierarchy(app)


        function session = createNewSession(app)

            if app.Debug
                disp("wtexample.app.ContextualViewExample.createNewSession");
            end

            session = wtexample.model.Session;

        end %function


        function setup(app)
            % Initial setup / creation of the app

            if app.Debug
                disp("wtexample.app.ContextualViewExample.setup");
            end

            % Set the name
            app.Name = "Contextual View Example";

            % Configure the main grid
            app.Grid.Padding = 10;
            app.Grid.ColumnSpacing = 10;
            app.Grid.RowHeight = {90,'1x'};
            app.Grid.ColumnWidth = {250,'1x'};

            % Create toolbar file section
            fileSection = wt.toolbar.HorizontalSection();
            fileSection.Title = "FILE";
            fileSection.addButton("new_24.png","New");
            fileSection.addButton("open_24.png","Open");
            fileSection.addButton("saveClean_24.png","Save");
            fileSection.addButton("saveClean_24.png","Save As");
            fileSection.addButton("import_24.png","Import");
            fileSection.ButtonPushedFcn = @(~,evt)onFileButtonPushed(app,evt);

            % Create exhibit section
            exhibitSection = wt.toolbar.HorizontalSection();
            exhibitSection.Title = "EXHIBIT";
            app.ExhibitAddButton = exhibitSection.addButton("addGreen_24.png","New");
            app.ExhibitDeleteButton = exhibitSection.addButton("delete_24.png","Delete");
            exhibitSection.ButtonPushedFcn = @(~,evt)onExhibitButtonPushed(app,evt);

            % Add toolbar
            app.Toolbar = wt.Toolbar(app.Grid);
            app.Toolbar.DividerColor = [.8 .8 .8];
            app.Toolbar.Layout.Row = 1;
            app.Toolbar.Layout.Column = [1 2];
            app.Toolbar.Section = [fileSection, exhibitSection];

            % Create navigation tree
            app.Tree = uitree(app.Grid);
            app.Tree.SelectionChangedFcn = @(~,evt)onTreeSelection(app,evt);
            app.Tree.FontSize = 14;
            app.Tree.Layout.Row = 2;
            app.Tree.Layout.Column = 1;

            % Create contextual view pane
            app.ContextualView = wt.ContextualView(app.Grid);
            app.ContextualView.Layout.Row = 2;
            app.ContextualView.Layout.Column = 2;

        end %function


        function update(app)

            if app.Debug
                disp("wtexample.app.ContextualViewExample.update");
            end

            % Update the tree hierarchy
            app.updateTreeHierarchy()

            % If a new selection is requested, change it now
            % if isscalar(app.NewSelection) && isvalid(app.NewSelection)
            %
            % end

            % Select the new node
            % app.Tree.SelectedNodes = app.Tree.Children(end);
            %RJ - need to add selection states in the session! That
            %way, update can properly select the tree choice.

        end %function


        function session = getSessionFromTreeNode(app,node)
            % Determines the session of the selected tree node

            arguments
                app (1,1) wt.apps.BaseApp
                node (1,1) matlab.ui.container.TreeNode
            end

            nodeData = node.NodeData;
            if ~isscalar(nodeData)

                % Shouldn't happen, but return empty
                session = wtexample.model.Session.empty(1,0);

            elseif isa(nodeData, "wt.model.BaseSession")

                % Found it!
                session = nodeData;

            elseif isa(nodeData, "wt.model.BaseModel") && ~isempty(node.Parent)

                % Look to parent
                session = app.getSessionFromTreeNode(node.Parent);

            else

                % Can't find, return empty
                session = getEmptySession();

            end %if

        end %function


        function onTreeSelection(app,evt)
            % On selected tree node changed

            if app.Debug
                disp("wtexample.app.ContextualViewExample.onTreeSelection");
            end

            % What node(s) are selected?
            selNode = evt.SelectedNodes;

            % Is it a scalar selection?
            if isscalar(selNode)

                % Set the selected session
                session = app.getSessionFromTreeNode(selNode);
                app.selectSession(session);

                % Get the data model, which is attached to this node
                model = selNode.NodeData;
                modelClass = class(model);

                % Which view to launch?
                viewClass = replace(modelClass,".model.",".viewcontroller.");

                % Launch the contextual pane for the selected data type
                app.ContextualView.launchView(viewClass, model);

            else

                % Clear the contextual pane
                app.ContextualView.clearView();

            end %if

        end %function


        function onFileButtonPushed(app,evt)

            if app.Debug
                disp("wtexample.app.ContextualViewExample.onFileButtonPushed");
            end

            % Get the selected session
            session = app.SelectedSession;

            switch evt.Text

                case 'New'

                    % Add a new session
                    session = app.newSession();

                    % Select the new session
                    if ~isempty(session)
                        app.selectSession(session);
                    end

                case 'Open'

                    % Prompt and load a session
                    session = app.loadSession();

                    % Select the new session
                    if ~isempty(session)
                        app.selectSession(session);
                    end

                case 'Save'

                    % Save the session
                    app.saveSession(false, session);

                case 'Save As'

                    % Save the session as different file
                    app.saveSession(true, session);

                case 'Import'

                    filter = ["*.xlsx","Excel Document"];
                    title = "Select spreadsheet to import";
                    filePath = app.promptToLoad(filter,title);

                    if isfile(filePath)
                        try
                            session.importManifest(filePath);
                        catch err
                            message = sprintf("Unable to load " + ...
                                "manifest: %s\n\n%s",filePath,err.message);
                            app.throwError(message)
                        end
                    end

            end %switch

            % Update the app
            app.update()

        end %function


        function onExhibitButtonPushed(app,evt)

            if app.Debug
                disp("wtexample.app.ContextualViewExample.onExhibitButtonPushed");
            end

            % Get the selected session
            session = app.SelectedSession;

            % Which button was pressed?
            switch evt.Text

                case 'New'

                    % Add a new exhibit
                    newItem = wtexample.model.Exhibit;
                    newItem.Name = "New Exhibit";

                    % Add the new exhibit
                    session.Exhibit(end+1) = newItem;

                    % Indicate the new exhibit should be selected at the next update
                    % app.NewSelection = newItem;

                case 'Delete'

                    % Get the selected node
                    selNode = app.Tree.SelectedNodes;

                    % Return if nonscalar node
                    if ~isscalar(selNode) || ~isvalid(selNode)
                        return
                    end

                    % Get the data model, which is attached to this node
                    model = selNode.NodeData;
                    modelClass = class(model);

                    % Is the selected node a valid exhibit?
                    if modelClass == "wtexample.model.Exhibit"

                        % Prompt user before deleting
                        message = "Are you sure you want to delete the exhibit """...
                            + model.Name + """?";
                        response = app.promptYesNoCancel(message);
                        if matches(response,"yes","IgnoreCase",true)

                            % Delete the exhibit
                            isMatch = session.Exhibit == model;
                            session.Exhibit(isMatch) = [];

                        end %if

                    end %if

            end %switch

            app.update()

        end %function

    end %methods

end %classdef