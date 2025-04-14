function update(app)
% Triggered on certain changes to tell the app to update the display This
% is required and called by the superclasses including BaseApp,
% AbstractSessionApp, and BaseMultiSessionApp

% Copyright 2025 The MathWorks Inc.

% Show output if Debug is on
app.displayDebugText();


%% Gather selection data

% Get the selected session
selSession = app.SelectedSession;
hasSelectedSession = isscalar(selSession);

% Get tree selection data
selectionData = app.TreeSelectionData;


%% Update the tree hierarchy
app.updateTreeHierarchy()

% Select the new node
% app.Tree.SelectedNodes = app.Tree.Children(end);
%RJ - need to add selection states in the session! That
%way, update can properly select the tree choice.


%% Update the ContextualView contents

% What type of selection?
if isscalar(selectionData.Model) && isvalid(selectionData.Model)
    % Choose view that matches the model type

    % Which view to launch?
    viewClass = "zooexample.view." + selectionData.ModelType;
    model = selectionData.Model;

    % Launch the contextual pane for the selected model and class
    app.ContextualView.launchView(viewClass, model);

else % No middle content

    % Clear the contextual pane
    app.ContextualView.clearView();

end %if


%% Toolstrip button enables

% Update session enables
app.SessionNewButton.Enable = true;
app.SessionOpenButton.Enable = true;
app.SessionImportButton.Enable = hasSelectedSession;
app.SessionSaveButton.Enable = hasSelectedSession && selSession.Dirty;
app.SessionSaveAsButton.Enable = hasSelectedSession;
app.SessionCloseButton.Enable = hasSelectedSession;

% Update exhibit/enclosure/animal enables based on model type selected
switch selectionData.ModelType

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

end %switch
