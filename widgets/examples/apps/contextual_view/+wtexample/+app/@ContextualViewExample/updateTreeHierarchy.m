function updateTreeHierarchy(app)
% Creates/updates the tree hierarchy

if app.Debug
    disp("wtexample.apps.ContextualViewExample.updateTreeHierarchy");
end

% Get the loaded sessions
session = app.Session;

% Get existing session nodes
rootNode = app.Tree;
sessionNodes = rootNode.Children;

% Get the sessions they reference
if isempty(sessionNodes)
    % Empty of same type as input
    sessionNodeData = session([]);
else
    sessionNodeData = horzcat(sessionNodes.NodeData);
end

% Track which existing child nodes are updated so we can
% remove old ones later
childNodeUpdated = false(size(sessionNodes));

% Loop on each session
for sIdx = 1:numel(session)

    % The session to update
    thisSession = session(sIdx);

    % Does it already have a session node?
    idxMatch = find(thisSession == sessionNodeData, 1);
    if isempty(idxMatch)
        % NO - Create a new session hierarchy
        sessionNode = uitreenode(rootNode);
        sessionNode.NodeData = thisSession;

        % Expand the session node after first creation
        expand(sessionNode)
    else
        % YES - Use existing node
        sessionNode = sessionNodes(idxMatch);
        childNodeUpdated(idxMatch) = true;
    end

    % Update the session node's text
    % Add "*" if dirty (indicating unsaved changes)
    if thisSession.Dirty
        sessionNode.Text = append(thisSession.FileName, " *");
    else
        sessionNode.Text = thisSession.FileName;
    end

    % Update the session node's child hierarchy
    syncExhibitNodes(sessionNode, thisSession.Exhibit)

end %for

% Remove any unused session nodes
unusedSessionNodes = sessionNodes(~childNodeUpdated);
delete(unusedSessionNodes)

% expand(app.Tree)

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
    thisNode.Text = "Exhibit: " + model(idx).Name;
    thisNode.Icon = "exhibit.png";
    % nodeText = "Exhibit: " + model(idx).Name;
    % if thisNode.Text ~= nodeText
    %     thisNode.Text = nodeText;
    % end
    % if thisNode.Icon ~= "exhibit.png"
    %     thisNode.Icon = "exhibit.png";
    % end

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
    thisNode.Text = "Enclosure: " + model(idx).Name;
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
    thisNode.Text = "Animal: " + model(idx).Name;
    thisNode.Icon = "animal.png";

    % This is the lowest level - no children to sync

end %for

end %function



%% Synchronize one level of tree nodes with a model class
function newNodeList = syncNodes(parentNode, model)
% Synchronizes nodes for one level of hierarchy

arguments
    parentNode (1,1) matlab.ui.container.TreeNode
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
% newNodeList = repmat(matlab.ui.container.TreeNode, 1, numModels);
% newNodeCell = cell(1, numModels);
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
% for idx = numModels:-1:1

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
    % newNodeCell{idx} = newNode;

end %for

% newNodeList = [newNodeCell{:}];

% Remove any unused nodes
unusedNodes = childNodes(~childNodeUpdated);
delete(unusedNodes)

end %function