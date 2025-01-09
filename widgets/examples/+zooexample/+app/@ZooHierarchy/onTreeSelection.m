function onTreeSelection(app,evt)
% Triggered on selection of a new tree node

% Copyright 2025 The MathWorks Inc.

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