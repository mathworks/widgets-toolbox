function session = getSessionFromTreeNode(app,node)
% Determines the session of the selected tree node

% Copyright 2025 The MathWorks Inc.

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