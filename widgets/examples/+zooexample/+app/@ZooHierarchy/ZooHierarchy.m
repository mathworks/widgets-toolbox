classdef ZooHierarchy < wt.apps.BaseMultiSessionApp
    % Example app showing a tree with contextual views

    % Copyright 2025 The MathWorks Inc.


    %% Internal properties
    properties (SetAccess = private)

        % Toolbar at top of the app window
        Toolbar wt.Toolbar

        % Navigation tree on the left of the app
        Tree matlab.ui.container.Tree

        % Contextual pane to show view/controller for selected tree node
        ContextualView wt.ContextualView

        % Toolbar buttons
        SessionNewButton matlab.ui.control.Button
        SessionOpenButton matlab.ui.control.Button
        SessionImportButton matlab.ui.control.Button
        SessionSaveButton matlab.ui.control.Button
        SessionSaveAsButton matlab.ui.control.Button
        SessionCloseButton matlab.ui.control.Button
        ExhibitAddButton matlab.ui.control.Button
        ExhibitDeleteButton matlab.ui.control.Button
        EnclosureAddButton matlab.ui.control.Button
        EnclosureDeleteButton matlab.ui.control.Button
        AnimalAddButton matlab.ui.control.Button
        AnimalDeleteButton matlab.ui.control.Button

    end %properties


    %% Protected Methods
    methods  (Access = protected)

        % Declarations for methods in separate files
        updateTreeHierarchy(app)


        function session = createNewSession(app)

            % Show output if Debug is on
            app.displayDebugText();

            session = zooexample.model.Session;

        end %function


        function setup(app)
            % Initial setup / creation of the app

            % Show output if Debug is on
            app.displayDebugText();

            % Set the name
            app.Name = "Zoo Hierarchy Example App";

            % Configure the main grid
            app.Grid.Padding = 10;
            app.Grid.ColumnSpacing = 10;
            app.Grid.RowHeight = {90,'1x'};
            app.Grid.ColumnWidth = {250,'1x'};

            % Create toolbar file/session section
            sessionSection = wt.toolbar.HorizontalSection();
            sessionSection.Title = "SESSION";
            app.SessionNewButton = sessionSection.addButton("new_24.png","New");
            app.SessionOpenButton = sessionSection.addButton("open_24.png","Open");
            app.SessionImportButton = sessionSection.addButton("import_24.png","Import Data");
            app.SessionSaveButton = sessionSection.addButton("saveClean_24.png","Save");
            app.SessionSaveAsButton = sessionSection.addButton("saveClean_24.png","Save As");
            app.SessionCloseButton = sessionSection.addButton("close_24.png","Close");

            % Create exhibit section
            exhibitSection = wt.toolbar.HorizontalSection();
            exhibitSection.Title = "EXHIBIT";
            app.ExhibitAddButton = exhibitSection.addButton("addGreen_24.png","New");
            app.ExhibitDeleteButton = exhibitSection.addButton("delete_24.png","Delete");

            % Create enclosure section
            enclosureSection = wt.toolbar.HorizontalSection();
            enclosureSection.Title = "ENCLOSURE";
            app.EnclosureAddButton = enclosureSection.addButton("addGreen_24.png","New");
            app.EnclosureDeleteButton = enclosureSection.addButton("delete_24.png","Delete");

            % Create animal section
            animalSection = wt.toolbar.HorizontalSection();
            animalSection.Title = "ANIMAL";
            app.AnimalAddButton = animalSection.addButton("addGreen_24.png","New");
            app.AnimalDeleteButton = animalSection.addButton("delete_24.png","Delete");

            % Add toolbar
            app.Toolbar = wt.Toolbar(app.Grid);
            app.Toolbar.DividerColor = [.8 .8 .8];
            app.Toolbar.Layout.Row = 1;
            app.Toolbar.Layout.Column = [1 2];
            app.Toolbar.ButtonPushedFcn = @(~,evt)onToolbarButtonPushed(app,evt);
            app.Toolbar.Section = [
                sessionSection
                exhibitSection
                enclosureSection
                animalSection
                ];

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


        function resetView(app)
            % Called when a major change happens like closing a session, so
            % we can clear the panes and selections

            % Show output if Debug is on
            app.displayDebugText();

            % Deselect tree nodes
            app.Tree.SelectedNodes = [];

            % Clear the contextual pane
            app.ContextualView.clearView();

            % Update view
            app.update();

        end %function


        function update(app)

            % Show output if Debug is on
            app.displayDebugText();

            % Update the tree hierarchy
            app.updateTreeHierarchy()

            % Update toolbar enables
            app.updateToolbarEnables();

            % If a new selection is requested, change it now
            % if isscalar(app.NewSelection) && isvalid(app.NewSelection)
            %
            % end

            % Select the new node
            % app.Tree.SelectedNodes = app.Tree.Children(end);
            %RJ - need to add selection states in the session! That
            %way, update can properly select the tree choice.

        end %function


        function updateToolbarEnables(app)

            % Is a session selected?
            hasSelectedSession = ~isempty(app.SelectedSession);

            % Update session enables
            app.SessionNewButton.Enable = true;
            app.SessionOpenButton.Enable = true;
            app.SessionImportButton.Enable = hasSelectedSession;
            app.SessionSaveButton.Enable = hasSelectedSession && app.SelectedSession.Dirty;
            app.SessionSaveAsButton.Enable = hasSelectedSession;
            app.SessionCloseButton.Enable = hasSelectedSession;

            % Get the selected model type (if single selection)
            selNodes = app.Tree.SelectedNodes;
            if isscalar(selNodes)
                model = selNodes.NodeData;
                modelType = extractAfter(class(model),"zooexample.model.");
            else
                modelType = '';
            end

            % Update exhibit/enclosure/animal enables with model selected
            switch modelType

                case 'Session'
                    app.ExhibitAddButton.Enable = true;
                    app.ExhibitDeleteButton.Enable = false;
                    app.EnclosureAddButton.Enable = false;
                    app.EnclosureDeleteButton.Enable = false;
                    app.AnimalAddButton.Enable = false;
                    app.AnimalDeleteButton.Enable = false;

                case 'Exhibit'
                    app.ExhibitAddButton.Enable = true;
                    app.ExhibitDeleteButton.Enable = true;
                    app.EnclosureAddButton.Enable = true;
                    app.EnclosureDeleteButton.Enable = false;
                    app.AnimalAddButton.Enable = false;
                    app.AnimalDeleteButton.Enable = false;

                case 'Enclosure'
                    app.ExhibitAddButton.Enable = true;
                    app.ExhibitDeleteButton.Enable = true;
                    app.EnclosureAddButton.Enable = true;
                    app.EnclosureDeleteButton.Enable = true;
                    app.AnimalAddButton.Enable = true;
                    app.AnimalDeleteButton.Enable = false;

                case 'Animal'
                    app.ExhibitAddButton.Enable = true;
                    app.ExhibitDeleteButton.Enable = true;
                    app.EnclosureAddButton.Enable = true;
                    app.EnclosureDeleteButton.Enable = true;
                    app.AnimalAddButton.Enable = true;
                    app.AnimalDeleteButton.Enable = true;

                otherwise
                    app.ExhibitAddButton.Enable = false;
                    app.ExhibitDeleteButton.Enable = false;
                    app.EnclosureAddButton.Enable = false;
                    app.EnclosureDeleteButton.Enable = false;
                    app.AnimalAddButton.Enable = false;
                    app.AnimalDeleteButton.Enable = false;

            end

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
                session = zooexample.model.Session.empty(1,0);

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

            % Show output if Debug is on
            app.displayDebugText();

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
                viewClass = replace(modelClass,".model.",".view.");

                % Launch the contextual pane for the selected data type
                app.ContextualView.launchView(viewClass, model);

            else

                % Clear the contextual pane
                app.ContextualView.clearView();

            end %if

            % Update toolbar enables
            app.updateToolbarEnables();

        end %function


        function onToolbarButtonPushed(app,evt)

            % Show output if Debug is on
            app.displayDebugText();

            % Get the selected session

            % Get the selected model type (if single selection)
            selNode = app.Tree.SelectedNodes;
            if isscalar(selNode)
                model = selNode.NodeData;
                modelType = extractAfter(class(model),"zooexample.model.");
            else
                modelType = '';
            end

            % What is the selection hierarchy?
            switch modelType
                case 'Session'
                    session = model;
                    exhibit = [];
                    enclosure = [];
                    animal = [];
                case 'Exhibit'
                    session = selNode.Parent.NodeData;
                    exhibit = model;
                    enclosure = [];
                    animal = [];
                case 'Enclosure'
                    session = selNode.Parent.Parent.NodeData;
                    exhibit = selNode.Parent.NodeData;
                    enclosure = model;
                    animal = [];
                case 'Animal'
                    session = selNode.Parent.Parent.Parent.NodeData;
                    exhibit = selNode.Parent.Parent.NodeData;
                    enclosure = selNode.Parent.NodeData;
                    animal = model;
                otherwise
                    session = app.SelectedSession;
                    exhibit = [];
                    enclosure = [];
                    animal = [];
            end %switch

            % Which button was pressed?
            switch evt.Button

                case app.SessionNewButton

                    % Add a new session
                    session = app.newSession();

                    % Select the new session
                    if ~isempty(session)
                        app.selectSession(session);
                    end

                    % Reset the view
                    app.resetView();

                case app.SessionOpenButton

                    % Prompt and load a session
                    session = app.loadSession();

                    % Select the new session
                    if ~isempty(session)
                        app.selectSession(session);
                    end

                    % Reset the view
                    app.resetView();

                case app.SessionImportButton

                    startPath = fullfile(wt.utility.widgetsRoot, ...
                        "examples", "data");

                    filter = ["*.xlsx","Excel Document"];
                    title = "Select spreadsheet to import";
                    filePath = app.promptToLoad(filter,title,startPath);

                    if isfile(filePath)
                        try
                            session.importManifest(filePath);
                        catch err
                            message = sprintf("Unable to load " + ...
                                "manifest: %s\n\n%s",filePath,err.message);
                            app.throwError(message)
                        end
                    end

                    % Reset the view
                    app.resetView();

                case app.SessionSaveButton

                    % Save the session
                    app.saveSession(false, session);

                case app.SessionSaveAsButton

                    % Save the session as different file
                    app.saveSession(true, session);

                case app.SessionCloseButton

                    % Close the currently selected session
                    app.closeSession();

                    % Reset the view
                    app.resetView();

                case app.ExhibitAddButton

                    % Add a new exhibit
                    newItem = zooexample.model.Exhibit;
                    newItem.Name = "New Exhibit";
                    session.Exhibit(end+1) = newItem;

                case app.ExhibitDeleteButton

                    % Prompt user before deleting
                    message = "Are you sure you want to delete the exhibit """...
                        + exhibit.Name + """?";
                    response = app.promptYesNoCancel(message);
                    if matches(response,"yes","IgnoreCase",true)

                        % Delete the exhibit
                        isMatch = session.Exhibit == exhibit;
                        session.Exhibit(isMatch) = [];

                        % Clear the contextual pane
                        app.ContextualView.clearView();

                    end %if

                case app.EnclosureAddButton

                    % Add a new enclosure
                    newItem = zooexample.model.Enclosure;
                    newItem.Name = "New Enclosure";
                    exhibit.Enclosure(end+1) = newItem;

                case app.EnclosureDeleteButton

                    % Prompt user before deleting
                    message = "Are you sure you want to delete the enclosure """...
                        + enclosure.Name + """?";
                    response = app.promptYesNoCancel(message);
                    if matches(response,"yes","IgnoreCase",true)

                        % Delete the enclosure
                        isMatch = exhibit.Enclosure == enclosure;
                        exhibit.Enclosure(isMatch) = [];

                        % Clear the contextual pane
                        app.ContextualView.clearView();

                    end %if

                case app.AnimalAddButton

                    % Add a new animal
                    newItem = zooexample.model.Animal;
                    newItem.Name = "New Animal";
                    enclosure.Animal(end+1) = newItem;

                case app.AnimalDeleteButton

                    % Prompt user before deleting
                    message = "Are you sure you want to delete the animal """...
                        + animal.Name + """?";
                    response = app.promptYesNoCancel(message);
                    if matches(response,"yes","IgnoreCase",true)

                        % Delete the animal
                        isMatch = enclosure.Animal == animal;
                        enclosure.Animal(isMatch) = [];

                        % Clear the contextual pane
                        app.ContextualView.clearView();

                    end %if

            end %switch

            % Update the app
            app.update()

        end %function

    end %methods

end %classdef