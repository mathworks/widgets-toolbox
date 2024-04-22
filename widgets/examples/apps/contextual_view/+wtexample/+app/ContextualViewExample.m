classdef ContextualViewExample < wt.apps.BaseSingleSessionApp
    % Example app showing a tree with contextual views


    %% Internal properties
    properties (Hidden, Transient, SetAccess = private)

        % Toolbar at top of the app window
        Toolbar wt.Toolbar
        
        % Navigation tree on the left of the app
        Tree matlab.ui.container.Tree

        % Contextual pane to show view/controller for selected tree node
        ContextualPane wt.ContextualViewPane

        ExhibitAddButton
        ExhibitDeleteButton

    end %properties


    %% Setup
    methods  (Access = protected)

        function setup(app)

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
            app.Tree = uitree(app.Grid,...
                "SelectionChangedFcn",@(~,evt)onTreeSelection(app,evt));
            app.Tree.Layout.Row = 2;
            app.Tree.Layout.Column = 1;

            % Create contextual view pane
            app.ContextualPane = wt.ContextualViewPane(app.Grid);
            app.ContextualPane.Layout.Row = 2;
            app.ContextualPane.Layout.Column = 2;

        end %function


        function sessionObj = createNewSession(~)

            sessionObj = wtexample.model.Session;

        end %function

    end %methods


    %% Update
    methods  (Access = protected)

        function update(app)

            % Populate tree
            delete(app.Tree.Children);

            % Add exhibit nodes within the zoo
            for exhibit = app.Session.Exhibit'

                exhNode = uitreenode(app.Tree,...
                    "Text","Exhibit: " + exhibit.Name,...
                    "NodeData",exhibit);

                % Add enclosure nodes within this exhibit
                for enclosure = exhibit.Enclosure'

                    encNode = uitreenode(exhNode,...
                        "Text","Enclosure: " + enclosure.Name,...
                        "NodeData",enclosure);

                    % Add animal nodes within this enclosure
                    for animal = enclosure.Animal'

                        uitreenode(encNode,...
                            "Text","Animal: " + animal.Name,...
                            "NodeData",animal);

                    end %for

                end %for

            end %for

            % Expand the top level
            expand(app.Tree)

        end %function

    end %methods


    %% Callbacks
    methods

        function onTreeSelection(app,evt)
            % On selected tree node changed

            selNode = evt.SelectedNodes;
            if isscalar(selNode)

                % Get the data model, which is attached to this node
                model = selNode.NodeData;
                modelClass = class(model);

                % Which view to launch?
                viewClass = replace(modelClass,".model.",".viewcontroller.");

                % Launch the contextual pane for the selected data type
                app.ContextualPane.launchPane(viewClass, model);

            else

                % Clear the contextual pane
                app.ContextualPane.launchPane("");

            end %if

        end %function


        function onFileButtonPushed(app,evt)

            switch evt.Text

                case 'New'

                    app.Session = app.createNewSession();

                case 'Open'

                    app.loadSession()

                case 'Save'

                    app.saveSession(true);

                case 'Import'

                    filter = ["*.xlsx","Excel Document"];
                    title = "Select spreadsheet to import";
                    filePath = app.promptToLoad(filter,title);

                    if isfile(filePath)
                        try
                            app.Session.importManifest(filePath);
                        catch err
                            message = sprintf("Unable to load " + ...
                                "manifest: %s\n\n%s",filePath,err.message);
                            app.throwError(message)
                        end
                    end

            end %switch

            app.update()

        end %function


        function onExhibitButtonPushed(app,evt)

            switch evt.Text

                case 'New'

                    % Add a new exhibit
                    newItem = wtexample.model.Exhibit;
                    newItem.Name = "New Exhibit";
                    app.Session.Exhibit(end+1) = newItem;

                    % Select the new node
                    app.Tree.SelectedNodes = app.Tree.Children(end);
                    %RJ - need to add selection states in the session! That
                    %way, update can properly select the tree choice.

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
                            isMatch = app.Session.Exhibit == model;
                            app.Session.Exhibit(isMatch) = [];

                        end %if

                    end %if

            end %switch

            app.update()

        end %function

    end %methods

end %classdef