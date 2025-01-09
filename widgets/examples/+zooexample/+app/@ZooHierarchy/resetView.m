function resetView(app)
% Called when a major change happens like closing a session, so
% we can clear the panes and selections

% Copyright 2025 The MathWorks Inc.

% Show output if Debug is on
app.displayDebugText();

% Deselect tree nodes
app.Tree.SelectedNodes = [];

% Clear the contextual pane
app.ContextualView.clearView();

% Update view
app.update();