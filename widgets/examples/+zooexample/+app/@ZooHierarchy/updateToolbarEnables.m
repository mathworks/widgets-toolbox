function updateToolbarEnables(app)
% This updates the enable states of the toolbar buttons and is called by
% update and other methods

% Copyright 2025 The MathWorks Inc.

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