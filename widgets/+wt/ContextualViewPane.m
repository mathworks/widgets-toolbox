classdef ContextualViewPane < matlab.ui.componentcontainer.ComponentContainer & ...
        wt.mixin.ErrorHandling
    % wt.mixin.BackgroundColorable & ...
    % wt.mixin.Enableable & wt.mixin.FontStyled & wt.mixin.Tooltipable & ...
    % wt.mixin.FieldColorable & wt.mixin.PropertyViewable

    % Contextual View/Controller pane that can present varied content
    % This pane can switch its contents between multiple different
    % contextual components inside. It is much like a tabpanel, but without
    % the tab headers and it's optimized to only render one pane at a time.
    % This is useful in design patterns such as when you have a tree on the
    % left and on the right a contextual pane that displays different
    % content determined by the selected tree node.
    %
    % Content panes that are placed in this ContextualViewPane should
    % inherit the following classes:
    %   matlab.ui.componentcontainer.ComponentContainer
    %   wt.mixin.ContextualView (if auto-populating Model property)

    % Copyright 2016-2024 The MathWorks Inc.



    %% Internal Properties
    properties (AbortSet, Transient, NonCopyable, Hidden, SetAccess = protected)

        % The internal grid to manage contents
        Grid matlab.ui.container.GridLayout

    end %properties

    properties (SetAccess=private)

        % The currently active pane, or empty if none
        ActivePane (:,1) wt.abstract.BaseViewController {mustBeScalarOrEmpty}

        % The array of panes loaded into memory
        LoadedPanes (:,1) wt.abstract.BaseViewController

    end %properties

    properties (Constant, Access=private)

        % Shortcut for setting parent empty
        NO_PARENT = matlab.graphics.GraphicsPlaceholder.empty(0,0)

    end %properties


    % Accessors
    methods

        function value = get.ActivePane(obj)
            value = obj.ActivePane;
            % Remove pane if deleted
            value(~isvalid(value)) = [];
        end

        function set.ActivePane(obj,value)
            % Remove pane if deleted
            value(~isvalid(value)) = [];
            obj.ActivePane = value;
        end

        function value = get.LoadedPanes(obj)
            value = obj.LoadedPanes;
            % Remove any deleted panes from the list
            value(~isvalid(value)) = [];
        end

        function set.LoadedPanes(obj,value)
            % Remove any deleted panes from the list
            value(~isvalid(value)) = [];
            obj.LoadedPanes = value;
        end

    end %methods


    %% Public Methods
    methods

        function launchPane(obj, paneClass, model)
            % This method may be overloaded as needed

            arguments
                obj (1,1) wt.ContextualViewPane
                paneClass (1,1) string
                model wt.model.BaseModel %= wt.model.BaseModel.empty(0)
            end

            % Validate pane class
            if ~strlength(paneClass)

                % Empty string provided for pane class
                % This input clears any active pane and returns
                obj.deactivatePane_Private();
                return

            elseif ~exist(paneClass,"class")

                % Throw an error and return
                id = "wt:ContextualViewPane:InvalidPaneType";
                message = "Invalid pane type (%s). The paneClass " + ...
                    "must be a valid class path.";
                error(id, message, paneClass);

            elseif isequal(paneClass, obj.ActivePane)

                % Pane is already active
                pane = obj.ActivePane;

            else

                % Check if the pane already exists
                pane = wt.ContextualViewPane.empty(0);
                for thisPane = obj.LoadedPanes'
                    if paneClass == class(thisPane)
                        pane = thisPane;
                        break
                    end
                end

                % If no existing pane found, launch the pane
                if isempty(pane) || ~isvalid(pane)
                    pane = obj.launchPane_Private(paneClass);
                end %if

            end %if

            % Activate the pane, if one exists
            if ~isempty(pane)
                obj.activatePane_Private(pane, model)
            end

        end %function


        % function launchPaneByModelClassRule(obj, model)
        %     % Launch pane type automatically based on class of model provided
        %
        %     arguments
        %         obj (1,1) wt.ContextualViewPane
        %         model wt.model.BaseModel %= wt.model.BaseModel.empty(0)
        %     end
        %
        %
        %
        % end %function

    end %methods


    %% Protected Methods
    methods (Access=protected)


        function setup(obj)
            % Configure the widget

            % Grid Layout to place the contents
            obj.Grid = uigridlayout(obj,[1 1]);
            obj.Grid.Padding = [0 0 0 0];
            obj.Grid.BackgroundColor = [.7 .7 .9];

        end %function


        function update(~)

            % Do nothing - required for ComponentContainer

        end %function

    end %methods


    %% Private methods
    methods (Access=private)

        function pane = launchPane_Private(obj, paneClass)
            % Launch a pane based on the class path

            arguments (Input)
                obj (1,1) wt.ContextualViewPane
                paneClass (1,1) string
            end

            arguments (Output)
                pane (:,1) wt.abstract.BaseViewController {mustBeScalarOrEmpty}
            end

            % Trap errors
            try

                % Get function handle to the pane's constructor
                paneConstructorFcn = str2func(paneClass);

                % Launch the pane
                pane = paneConstructorFcn("Parent",obj.NO_PARENT);

                % Add the new pane to the list
                obj.LoadedPanes = vertcat(obj.LoadedPanes, pane);

            catch err
                message = sprintf("Error launching pane (%s).\n\n%s",...
                    paneClass, err.message);
                obj.throwError(message);
            end

        end %function


        function activatePane_Private(obj, pane, model)
            % Activate a pane, placing it in view and attaching a model

            arguments
                obj (1,1) wt.ContextualViewPane
                pane (1,1) wt.abstract.BaseViewController
                model wt.model.BaseModel %= wt.model.BaseModel.empty(0)
            end

            % Deactivate the current pane
            if isscalar(obj.ActivePane) && ~isequal(obj.ActivePane, pane)
                obj.deactivatePane_Private(obj.ActivePane);
            end

            % Assign parent
            if ~isequal(pane.Parent, obj.Grid)
                pane.Parent = obj.Grid;
            end

            % Attach model
            if ~isempty(model) && isvalid(model)
                obj.attachModel_Private(model)
            end

            % Set pane as the active pane
            obj.ActivePane = pane;

        end %function


        function deactivatePane_Private(obj, pane)
            % Deactivate a pane, removing from view and removing model
            arguments
                obj (1,1) wt.ContextualViewPane
                pane (1,1) wt.abstract.BaseViewController = obj.ActivePane
            end

            % Deactivate the pane, removing model and parent
            pane.Model(:) = [];
            pane.Parent(:) = [];

            % Remove pane from the active pane property
            if isequal(obj.ActivePane, pane)
                obj.ActivePane(:) = [];
            end

        end %function


        function attachModel_Private(obj, model)
            % Attach model to the active pane

            arguments
                obj (1,1) wt.ContextualViewPane
                model wt.model.BaseModel %= wt.model.BaseModel.empty(0)
            end

            % Verify an active pane
            pane = obj.ActivePane;
            if ~isscalar(pane)
                return
            end

            % Trap errors during model assignment
            if ~isempty(model) && isvalid(model)
                try
                    % Assign model
                    pane.Model = model;
                catch err
                    message = sprintf("Unable to assign model (%s) " + ...
                        "to pane (%s).\n\n%s",...
                        class(model), class(pane), err.message);
                    obj.throwError(message);
                end
            end

        end %function

    end %methods

end %classdef