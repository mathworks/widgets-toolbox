function update(app)
% Triggered on certain changes to tell the app to update the display This
% is required and called by the superclasses including BaseApp,
% AbstractSessionApp, and BaseMultiSessionApp

% Copyright 2025 The MathWorks Inc.

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