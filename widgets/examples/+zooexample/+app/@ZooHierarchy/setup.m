function setup(app)
% Initial setup / creation of the app
% This is required and called by the superclass BaseApp

% Copyright 2025 The MathWorks Inc.

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
app.ExhibitAddButton = exhibitSection.addButton("exhibit_add_32.png","New");
app.ExhibitDeleteButton = exhibitSection.addButton("exhibit_remove_32.png","Delete");

% Create enclosure section
enclosureSection = wt.toolbar.HorizontalSection();
enclosureSection.Title = "ENCLOSURE";
app.EnclosureAddButton = enclosureSection.addButton("enclosure_add_32.png","New");
app.EnclosureDeleteButton = enclosureSection.addButton("enclosure_remove_32.png","Delete");

% Create animal section
animalSection = wt.toolbar.HorizontalSection();
animalSection.Title = "ANIMAL";
app.AnimalAddButton = animalSection.addButton("animal_add_32.png","New");
app.AnimalDeleteButton = animalSection.addButton("animal_remove_32.png","Delete");

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