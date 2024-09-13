classdef TreeModelSelectedData < event.EventData
    % Event data for tree model selection for a single-node selection tree

    % Copyright 2024 The MathWorks, Inc.

    
    %% Properties
    properties
        Model
        Session
        Node (:,1) matlab.ui.container.TreeNode
    end %properties

    properties (SetAccess = protected)
        SelectionPath (:,1) matlab.ui.container.TreeNode
    end %properties


    % Accessors
    methods
        function set.Node(obj, value)
            obj.Node = value;
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

        function pathOut = findSelectionPath(obj, pathIn)
            % Find the full selection path from a given node

            if isempty(pathIn) || ~isa(pathIn, "matlab.ui.container.TreeNode")
                pathOut = matlab.ui.container.TreeNode.empty(1,0);
            elseif isa(pathIn.Parent, "matlab.ui.container.TreeNode")
                pathOut = vertcat(obj.findSelectionPath(pathIn.Parent), pathIn);
            else
                pathOut = pathIn;
            end

            if ~nargout
                obj.SelectionPath = pathOut;
            end

        end

    end %methods

end % classdef