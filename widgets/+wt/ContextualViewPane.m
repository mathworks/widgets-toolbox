classdef ContextualViewPane < matlab.ui.componentcontainer.ComponentContainer & ...
        wt.mixin.ErrorHandling
    % wt.mixin.BackgroundColorable & ...
    % wt.mixin.Enableable & wt.mixin.FontStyled & wt.mixin.Tooltipable & ...
    % wt.mixin.FieldColorable & wt.mixin.PropertyViewable

    % Contextual View/Controller pane that can present varied views
    % This pane can switch its contents between multiple different
    % contextual components inside. It is much like a tabpanel, but without
    % the tab headers and it's optimized to only render one view at a time.
    % This is useful in design patterns such as when you have a tree on the
    % left and on the right a contextual view that displays different
    % content determined by the selected tree node.
    %
    % Content views that are placed in this ContextualViewPane should
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

        % The currently active view, or empty if none
        ActiveView (:,1) wt.abstract.BaseViewController {mustBeScalarOrEmpty}

        % The array of views loaded into memory
        LoadedViews (:,1) wt.abstract.BaseViewController

    end %properties


    % Accessors
    methods

        function value = get.ActiveView(obj)
            value = obj.ActiveView;
            % Remove view if deleted
            value(~isvalid(value)) = [];
        end

        function set.ActiveView(obj,value)
            % Remove view if deleted
            value(~isvalid(value)) = [];
            obj.ActiveView = value;
        end

        function value = get.LoadedViews(obj)
            value = obj.LoadedViews;
            % Remove any deleted views from the list
            value(~isvalid(value)) = [];
        end

        function set.LoadedViews(obj,value)
            % Remove any deleted views from the list
            value(~isvalid(value)) = [];
            obj.LoadedViews = value;
        end

    end %methods


    %% Public Methods
    methods

        function launchView(obj, viewClass, model)
            % This method may be overloaded as needed

            arguments
                obj (1,1) wt.ContextualViewPane
                viewClass (1,1) string
                model wt.model.BaseModel %= wt.model.BaseModel.empty(0)
            end

            % Check for empty input, indicating to clear the view
            if ismissing(viewClass) || ~strlength(viewClass)
                obj.deactivateView_Private();
                return
            end %if

            % Validate view class
            view = validateViewClass(obj, viewClass);

            % If no existing view found, instantiate the view
            if isempty(view)
                obj.instantiateView_Private(viewClass, model);
            else
                obj.activateView_Private(view, model)
            end

        end %function


        % function launchViewByModelClassRule(obj, model)
        %     % Launch view type automatically based on class of model provided
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


        function update(obj)

            % Do nothing - required for ComponentContainer
            
            disp("Updating ContextualViewPane: " + class(obj));

        end %function

    end %methods


    %% Private methods
    methods (Access=private)

        function view = validateViewClass(obj, viewClass)
            % This validates the view class and check for existing
            % instances. If an existing instance is found, it is returned.
            % Otherwise, an empty view is returned

            arguments (Input)
                obj (1,1) wt.ContextualViewPane
                viewClass (1,1) string
            end

            arguments (Output)
                view (:,1) wt.abstract.BaseViewController {mustBeScalarOrEmpty}
            end

            % Try to locate a valid view
            if ~exist(viewClass,"class")

                % Throw an error and return
                id = "wt:ContextualViewPane:InvalidPaneType";
                message = "Invalid view type (%s). The viewClass " + ...
                    "must be a valid class path.";
                error(id, message, viewClass);

            elseif isequal(viewClass, class(obj.ActiveView))

                % Pane is already active
                view = obj.ActiveView;

            else

                % Check if the view already exists
                view = wt.abstract.BaseViewController.empty(0,1);
                for thisView = obj.LoadedViews'
                    if viewClass == class(thisView)
                        view = thisView;
                        break
                    end
                end

            end %if

        end %function


        function view = instantiateView_Private(obj, viewClass, model)
            % Launch a view based on the class path

            arguments (Input)
                obj (1,1) wt.ContextualViewPane
                viewClass (1,1) string
                model wt.model.BaseModel %= wt.model.BaseModel.empty(0)
            end

            arguments (Output)
                view (:,1) wt.abstract.BaseViewController {mustBeScalarOrEmpty}
            end

            % Trap errors
            try

                % Get function handle to the view's constructor
                viewConstructorFcn = str2func(viewClass);

                % Launch the view
                view = viewConstructorFcn(obj.Grid);

                % Position the view in the single grid cell
                view.Layout.Row = 1;
                view.Layout.Column = 1;

                % Add the new view to the list
                obj.LoadedViews = vertcat(obj.LoadedViews, view);

            catch err
                message = sprintf("Error launching view (%s).\n\n%s",...
                    viewClass, err.message);
                obj.throwError(message);
            end

            % Activate the view
            obj.activateView_Private(view, model)

        end %function


        function activateView_Private(obj, view, model)
            % Activate a view, placing it in view and attaching a model

            arguments
                obj (1,1) wt.ContextualViewPane
                view (1,1) wt.abstract.BaseViewController
                model wt.model.BaseModel
            end

            % Deactivate the old view
            if isscalar(obj.ActiveView) && ~isequal(obj.ActiveView, view)
                obj.deactivateView_Private(obj.ActiveView);
            end

            % Assign parent
            if ~isequal(view.Parent, obj.Grid)
                view.Parent = obj.Grid;
            end
            view.Visible = true;

            % Set view as the active view
            obj.ActiveView = view;

            % Attach model
            if ~isempty(model) && isvalid(model)
                obj.attachModel_Private(view, model)
            end

        end %function


        function deactivateView_Private(obj, view)
            % Deactivate a view, removing from view and removing model
            arguments
                obj (1,1) wt.ContextualViewPane
                view (1,1) wt.abstract.BaseViewController = obj.ActiveView
            end

            % Deactivate the view, removing model and parent
            view.Model(:) = [];
            view.Parent(:) = [];
            view.Visible = false;

            % Remove view from the active view property
            if isequal(obj.ActiveView, view)
                obj.ActiveView(:) = [];
            end

        end %function


        function attachModel_Private(obj, view, model)
            % Attach model to the active view

            arguments
                obj (1,1) wt.ContextualViewPane
                view (1,1) wt.abstract.BaseViewController
                model wt.model.BaseModel
            end

            % Trap errors during model assignment
            if ~isempty(model) && isvalid(model)
                try
                    % Assign model
                    view.Model = model;
                catch err
                    message = sprintf("Unable to assign model (%s) " + ...
                        "to view/controller (%s).\n\n%s",...
                        class(model), class(view), err.message);
                    obj.throwError(message);
                end
            end

        end %function

    end %methods

end %classdef