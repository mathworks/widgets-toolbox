function updateTreeHierarchy(app)
% Creates/updates the tree hierarchy by synchronizing each level

% Copyright 2024 The MathWorks Inc.


if app.Debug
    disp("wtexample.apps.ContextualViewExample.updateTreeHierarchy");
end

% Sync session nodes
syncSessionNodes(app.Tree, app.Session)

% % Capture existing session nodes
% oldSessionNodes = app.Tree.Children;
% 
% % Get the inputs
% parentNode = app.Tree;
% model = app.Session;

% % Sync nodes at this level
% sessionNodes = syncNodes(parentNode, model);
% 
% % Loop on each model
% for idx = 1:numel(model)
% 
%     % Get current node/model pair
%     thisNode = sessionNodes(idx);
%     thisModel = model(idx);
% 
%     % Update the node's text and icon
%     nodeText = "Session: " + thisModel.FileName;
%     if thisModel.Dirty
%         nodeText = nodeText +  " *";
%     end
%     thisNode.Text = nodeText;
%     thisNode.Icon = "document2_24.png";
% 
%     % Sync children of node
%     syncExhibitNodes(thisNode, thisModel.Exhibit)
% 
% end %for


end %function


%% Sync Session Nodes
function syncSessionNodes(parentNode,model)
% Synchronizes child nodes to a model array

arguments
    parentNode (1,1) matlab.ui.container.Tree
    model (1,:) wtexample.model.Session
end

% Capture existing session nodes
oldSessionNodes = parentNode.Children;

% Sync nodes at this level
sessionNodes = syncNodes(parentNode, model);

% Loop on each model
for idx = 1:numel(model)

    % Get current node/model pair
    thisNode = sessionNodes(idx);
    thisModel = model(idx);

    % Update the node's text and icon
    nodeText = "Session: " + thisModel.FileName;
    if thisModel.Dirty
        nodeText = nodeText +  " *";
    end
    thisNode.Text = nodeText;
    thisNode.Icon = "document2_24.png";

    % Sync children of node
    syncExhibitNodes(thisNode, thisModel.Exhibit)

end %for

% Expand any new session nodes
isNew = ~ismember(sessionNodes, oldSessionNodes);
if any(isNew)
    expand(sessionNodes(isNew))
end

end %function


%% Sync Exhibit Nodes
function syncExhibitNodes(parentNode,model)
% Synchronizes child nodes to a model array

arguments
    parentNode (1,1) matlab.ui.container.TreeNode
    model (1,:) wtexample.model.Exhibit
end

% Sync nodes at this level
exhibitNodes = syncNodes(parentNode, model);

% Loop on each model
for idx = 1:numel(model)

    % Get current node/model pair
    thisNode = exhibitNodes(idx);
    thisModel = model(idx);

    % Update the node's text and icon
    thisNode.Text = "Exhibit: " + thisModel.Name;
    thisNode.Icon = "exhibit.png";

    % Sync children of node
    syncEnclosureNodes(thisNode, thisModel.Enclosure)

end %for

end %function


%% Sync Enclosure Nodes
function syncEnclosureNodes(parentNode,model)
% Synchronizes child nodes to a model array

arguments
    parentNode (1,1) matlab.ui.container.TreeNode
    model (1,:) wtexample.model.Enclosure
end

% Sync nodes at this level
enclosureNodes = syncNodes(parentNode, model);

% Loop on each model
for idx = 1:numel(model)

    % Get current node/model pair
    thisNode = enclosureNodes(idx);
    thisModel = model(idx);

    % Update the node's text and icon
    thisNode.Text = "Enclosure: " + thisModel.Name;
    thisNode.Icon = "enclosure.png";

    % Sync children of node
    syncAnimalNodes(thisNode, thisModel.Animal)

end %for

end %function


%% Sync Animal Nodes
function syncAnimalNodes(parentNode,model)
% Synchronizes child nodes to a model array

arguments
    parentNode (1,1) matlab.ui.container.TreeNode
    model (1,:) wtexample.model.Animal
end

% Sync nodes at this level
animalNodes = syncNodes(parentNode, model);

% Loop on each model
for idx = 1:numel(model)

    % Get current node/model pair
    thisNode = animalNodes(idx);
    thisModel = model(idx);

    % Update the node's text and icon
    thisNode.Text = "Animal: " + thisModel.Name;
    thisNode.Icon = "animal.png";

    % This is the lowest level - no children to sync

end %for

end %function



%% Synchronize one level of tree nodes with a model class
function newNodeList = syncNodes(parentNode, model)
% Synchronizes nodes for one level of hierarchy

arguments
    parentNode % matlab.ui.container.TreeNode or matlab.ui.container.Tree
    model (1,:) wt.model.BaseModel
end

% Get existing child nodes
childNodes = parentNode.Children;

% Get the models they reference
if isempty(childNodes)
    % Empty of same type as input
    childNodeData = model([]);
else
    childNodeData = horzcat(childNodes.NodeData);
end

% Preallocate new node list
persistent dummyNode emptyNodeList
if isempty(dummyNode)
    dummyNode = matlab.ui.container.TreeNode;
    emptyNodeList = matlab.ui.container.TreeNode.empty(1,0);
end
numModels = numel(model);
if numModels > 0
    newNodeList(1, numModels) = dummyNode;
else
    newNodeList = emptyNodeList;
end

% Track which existing child nodes are updated so we can
% remove old ones later
childNodeUpdated = false(size(childNodes));

% Loop on each model
for idx = 1:numModels

    % Does this model already have a node?
    isMatch = model(idx) == childNodeData;
    idxMatch = find(isMatch, 1);
    if isempty(idxMatch)
        % NO - Create a new node
        newNode = uitreenode(parentNode);
        newNode.NodeData = model(idx);
    else
        % YES - Use existing node
        newNode = childNodes(idxMatch);
        childNodeUpdated(idxMatch) = true;
    end

    % Store tne new node
    newNodeList(idx) = newNode;

end %for

% Remove any unused nodes
unusedNodes = childNodes(~childNodeUpdated);
delete(unusedNodes)

end %function