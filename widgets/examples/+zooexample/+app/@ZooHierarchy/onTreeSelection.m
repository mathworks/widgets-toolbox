function onTreeSelection(app,evt)
% Triggered on selection of a new tree node

% Copyright 2025 The MathWorks Inc.

% Show output if Debug is on
app.displayDebugText();

% Prepare selection data
selEvt = wt.eventdata.TreeModelSingleSelectionData;

% Is there a scalar node selection?
if isscalar(evt.SelectedNodes)

    % Populate the selection data
    selEvt.Node = evt.SelectedNodes;
    selEvt.Model = selEvt.Node.NodeData;
    selEvt.Session = getSessionFromTreeNode(selEvt.Node);

    % Set the selected session
    app.selectSession(selEvt.Session);

end %if

% Store information about the selection
app.TreeSelectionData = selEvt;

% Update the app display
app.update();

end %function


function session = getSessionFromTreeNode(node)
% Determines the session of the selected tree node

nodeData = node.NodeData;
if ~isscalar(nodeData)

    % Shouldn't happen, but return empty
    session = zooexample.model.Session.empty(1,0);

elseif isa(nodeData, "wt.model.BaseSession")

    % Found it!
    session = nodeData;

elseif isa(nodeData, "wt.model.BaseModel") && ~isempty(node.Parent)

    % Look to parent
    session = getSessionFromTreeNode(node.Parent);

else

    % Can't find, return empty
    session = getEmptySession();

end %if

end %function