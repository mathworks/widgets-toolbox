classdef TreeModelSingleSelectionData < event.EventData
    % Event data for tree model selection for a single-node selection tree

%   Copyright 2024-2025 The MathWorks Inc.

    
    %% Properties
    properties
        Node matlab.ui.container.TreeNode {mustBeScalarOrEmpty}
    end %properties

    properties (SetAccess = protected)
        NodeTag (1,1) string = ""
        SelectionPath (1,:) matlab.ui.container.TreeNode
        SelectionPathTag (1,:) string
    end %properties

    properties
        Model wt.model.BaseModel
        Session wt.model.BaseSession {mustBeScalarOrEmpty}
    end %properties


    % Accessors
    methods
        function set.Node(obj, value)
            obj.Node = value;
            obj.findNodeTag(value);
            obj.findSelectionPath(value);
        end
    end


    %% Dependent Properties
    properties (Dependent, SetAccess = protected)
        ModelClass (1,1) string
        ModelType (1,1) string
    end %properties

    % Accessors
    methods
        function value = get.ModelClass(obj)
            value = string(class(obj.Model));
        end
        function value = get.ModelType(obj)
            value = extract(obj.ModelClass, alphanumericsPattern + textBoundary);
        end
    end


    %% Methods
    methods (Access = private)

        function findNodeTag(obj, node)
            % Populates the tag of selected node(s)

            if isempty(node)
                obj.NodeTag = "";
            else
                obj.NodeTag = string(node.Tag);
            end

        end %function


        function pathOut = findSelectionPath(obj, pathIn)
            % Find the full selection path from a given node

            if isempty(pathIn) || ~isa(pathIn, "matlab.ui.container.TreeNode")
                pathOut = matlab.ui.container.TreeNode.empty(1,0);
            elseif isa(pathIn.Parent, "matlab.ui.container.TreeNode")
                pathOut = horzcat(obj.findSelectionPath(pathIn.Parent), pathIn);
            else
                pathOut = pathIn;
            end

            if ~nargout
                obj.SelectionPath = pathOut;
                if isempty(pathOut)
                    obj.SelectionPathTag = string.empty(1,0);
                else
                    obj.SelectionPathTag = string({pathOut.Tag}');
                end
            end

        end %function

    end %methods

end % classdef