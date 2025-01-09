function onToolbarButtonPushed(app,evt)
% Triggered after a toolbar button has been pushed

% Copyright 2025 The MathWorks Inc.

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