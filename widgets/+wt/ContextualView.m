classdef ContextualView < wt.abstract.BaseWidget
    % Contextual View/Controller pane that can present varied views
    % This pane can switch its contents between multiple different
    % contextual components inside. It is much like a tabpanel, but without
    % the tab headers and it's optimized to only render one view at a time.
    % This is useful in design patterns such as when you have a tree on the
    % left and on the right a contextual view that displays different
    % content determined by the selected tree node.
    %
    % Content views that are placed in this ContextualView should
    % inherit the following classes:
    %   matlab.ui.componentcontainer.ComponentContainer
    %   wt.mixin.ContextualView (if auto-populating Model property)

    % Copyright 2024-2025 The MathWorks Inc.



    %% Read-Only Properties
    properties (Dependent, SetAccess = immutable)

        % The currently active view, or empty if none
        ActiveView

        % Class of the active view
        ActiveViewType

        % The loaded views
        LoadedViews

        % Class of the loaded views
        LoadedViewTypes

    end %properties

    properties (Access = private)

        % The array of views loaded into memory
        LoadedViews_I (:,1) matlab.graphics.Graphics = ...
            wt.abstract.BaseViewController.empty(0,1)

        FirstLoad_I (1,1) logical = true

    end %properties


    % Accessors
    methods

        function value = get.ActiveView(obj)
            value = obj.ContentGrid.Children;
        end

        function value = get.LoadedViews(obj)
            value = obj.LoadedViews_I;
            % Remove any deleted views from the list
            keepItems = arrayfun(@isvalid, value);
            value(~keepItems) = [];
        end

        function value = get.LoadedViewTypes(obj)
            views = obj.LoadedViews_I;
            isDel = ~isvalid(views);
            viewClassCell = arrayfun(@(x)class(x),views,'UniformOutput',false);
            value = string(viewClassCell(:));
            value(isDel) = value(isDel) + " (deleted)";
        end

        function value = get.ActiveViewType(obj)
            activeView = obj.ActiveView;
            if isscalar(activeView) && isvalid(activeView)
                value = string( class(activeView) );
            else
                value = "";
            end
        end

    end %methods


    %% Internal Properties
    properties (AbortSet, Transient, NonCopyable, Hidden, ...
            SetAccess = protected, UsedInUpdate = false)

        % The internal grid to manage contents
        ContentGrid matlab.ui.container.GridLayout

        % The internal panel to show border
        Panel matlab.ui.container.Panel

    end %properties


    %% Public Methods
    methods

        function varargout = launchView(obj, viewClass, model)
            % Launch one or more views

            arguments
                obj (1,:) wt.ContextualView
            end

            arguments (Repeating)
                viewClass (1,1) string
                model wt.model.BaseModel
            end

            % Convert viewClass cell to string array
            viewClass = [viewClass{:}];

            % Determine which views will be changing
            % Loop on each ContextualView provided
            numViews = numel(obj);
            needsDeactivate = false(1,numViews);
            for idx = 1:numViews

                % Get current ContextualView obj and viewClass to launch
                thisObj = obj(idx);
                thisViewClass = viewClass(idx);

                % Determine if the viewClass is empty or if viewClass will change
                needsDeactivate(idx) = isscalar(thisObj.ActiveView) && ...
                    isvalid(thisObj.ActiveView) && ...
                    thisObj.ActiveViewType ~= thisViewClass;

            end %for

            % Will any views need to deactivate?
            if any(needsDeactivate)

                % Deactivate the views that will be changing
                obj(needsDeactivate).deactivateView_Private();

                % Force update for deactivation if multiple views changing
                if sum(needsDeactivate) > 1
                    drawnow("nocallbacks")
                end

            end %if

            % Instantiate or activate any new views
            % Loop on each ContextualView provided
            for idx = 1:numel(obj)

                % Get current ContextualView and content
                thisObj = obj(idx);
                thisViewClass = viewClass(idx);
                thisModel = model{idx};

                % Was a view provided?
                if strlength(thisViewClass)

                    % Remove the initial box on first load
                    if thisObj.FirstLoad_I
                        thisObj.Panel.BorderType = "none";
                        thisObj.FirstLoad_I = false;
                    end

                    % Validate view class (get existing view if present)
                    view = validateViewClass_Private(thisObj, thisViewClass);

                    % If no existing view found, instantiate the view
                    if isempty(view)
                        thisObj.instantiateView_Private(thisViewClass, thisModel);
                    else
                        thisObj.activateView_Private(view, thisModel)
                    end

                end %if

            end

            % Return the active views
            if nargout
                varargout = {obj.ActiveView};
            end

        end %function


        function clearView(obj)
            % This method may be overloaded as needed

            arguments
                obj (1,:) wt.ContextualView
            end

            % Loop on views
            for thisObj = obj

                % Deactivate the view
                thisObj.deactivateView_Private();

                % Delete any orphaned children
                if ~isempty(thisObj.ContentGrid.Children)
                    delete(thisObj.ContentGrid.Children);
                end

            end %for

        end %function


        function relaunchActiveView(obj)
            % Delete and reload the active view

            arguments
                obj (1,:) wt.ContextualView
            end

            % Loop on views
            for thisObj = obj

                % Is there an active view?
                activeView = thisObj.ActiveView;
                if ~isempty(activeView)

                    % Get the current view and model
                    viewClass = class(activeView);
                    model = activeView.Model;

                    % Deactivate the active view
                    thisObj.clearView();

                    % Delete the previously active view
                    delete(activeView);
                    thisObj.LoadedViews_I(thisObj.LoadedViews_I == activeView) = [];

                    % Launch the same view again
                    thisObj.launchView(viewClass, model);

                end %if

            end %for

        end %function


        function reset(obj)
            % Reset the control by deactivating current view and delete loaded views

            arguments
                obj (1,:) wt.ContextualView
            end

                % Deactivate any active view
                obj.deactivateView_Private();

            % Loop on views
            for thisObj = obj

                % Delete any loaded views
                delete(thisObj.LoadedViews_I);
                thisObj.LoadedViews_I(:) = [];

            end %for

        end %function

    end %methods


    %% Protected Methods
    methods (Access=protected)

        function setup(obj)
            % Configure the widget

            % Children order of the widget
            % - widget itself
            %   - Grid
            %     - Panel (for border)
            %       - ContentGrid (views go here)

            % Call superclass method
            obj.setup@wt.abstract.BaseWidget()

            % Set default size and position
            obj.Position = [10 10 400 400];

            % Create panel
            obj.Panel = uipanel(obj.Grid);
            obj.Panel.BorderWidth = 2;

            % Grid Layout to place the contents
            obj.ContentGrid = uigridlayout(obj.Panel,[1 1]);
            obj.ContentGrid.Padding = [0 0 0 0];

            % Components to apply background color
            obj.BackgroundColorableComponents = obj.ContentGrid;

        end %function


        function update(~)

        end %function

    end %methods


    %% Private methods
    methods (Access=private)

        function view = validateViewClass_Private(obj, viewClass)
            % This validates the view class and check for existing
            % instances. If an existing instance is found, it is returned.
            % Otherwise, an empty view is returned

            arguments
                obj (1,1) wt.ContextualView
                viewClass (1,1) string
            end

            loadedViews = obj.LoadedViews_I;
            isDeleted = ~isvalid(loadedViews);
            if any(isDeleted)
                loadedViews(isDeleted) = [];
            end

            % Try to locate a valid view
            if ~exist(viewClass,"class")

                % Throw an error and return
                id = "wt:ContextualView:InvalidPaneType";
                message = "Invalid view type (%s). The viewClass " + ...
                    "must be a valid class path.";
                error(id, message, viewClass);

            elseif viewClass == obj.ActiveViewType

                % Pane is already active
                view = obj.ActiveView;

            else

                % Check if the view already exists
                view = wt.abstract.BaseViewController.empty(0,1);
                for thisView = loadedViews'
                    if viewClass == class(thisView)
                        view = thisView;
                        break
                    end
                end

            end %if

        end %function


        function view = instantiateView_Private(obj, viewClass, model)
            % Launch a view based on the class path

            arguments
                obj (1,1) wt.ContextualView
                viewClass (1,1) string
                model wt.model.BaseModel %= wt.model.BaseModel.empty(0)
            end

            % Deactivate the old view


            % Trap errors
            try

                % Get function handle to the view's constructor
                viewConstructorFcn = str2func(viewClass);

                % Launch the view
                if ~isempty(model)
                    view = viewConstructorFcn(obj.ContentGrid,"Model",model);
                else
                    view = viewConstructorFcn(obj.ContentGrid);
                end

                % Position the view in the single grid cell
                view.Layout.Row = 1;
                view.Layout.Column = 1;
                view.Visible = true;

                % Add the new view to the list
                obj.LoadedViews_I = vertcat(obj.LoadedViews_I, view);

            catch err

                % Clean up partially loaded children
                delete(obj.ContentGrid.Children(2:end))

                % Throw an error
                title = "Error launching view: " + viewClass;
                obj.throwError(err.message, title);

                % Rethrow the error to the command window
                rethrow(err)

            end %try

        end %function


        function activateView_Private(obj, view, model)
            % Activate a view, placing it in view and attaching a model

            arguments
                obj (1,1) wt.ContextualView
                view (1,1) {mustBeValidView(view)}
                model wt.model.BaseModel
            end

            % Does this view need to be made active?
            needToActivate = ~isequal(obj.ActiveView, view);
            if needToActivate

                % Assign parent
                view.Parent = obj.ContentGrid;
                view.Layout.Column = 1;
                view.Layout.Row = 1;
                view.Visible = true;

            end %if

            % Attach model
            if ~isempty(model)

                try
                    % Assign model
                    view.Model = model;

                catch err

                    message = sprintf("Unable to assign model (%s) " + ...
                        "to view/controller (%s).\n\n%s",...
                        class(model), class(view), err.message);
                    obj.throwError(message);

                end %try

            end %if

        end %function


        function deactivateView_Private(obj)
            % Deactivate the active view, hiding and removing model
            arguments
                obj (1,:) wt.ContextualView
            end

            % Loop on each object
            for thisObj = obj

                % Remove the view's model and unparent it
                thisView = thisObj.ActiveView;
                if ~isempty(thisView)
                    thisView.Model(:) = [];
                    thisView.Parent(:) = [];
                end

                % Confirm ContentGrid is empty
                if ~isempty(thisObj.ContentGrid.Children)

                    % Delete the orphan content
                    delete(thisObj.ContentGrid.Children)

                    % Throw a warning
                    id = "wt:ContextualView:OrphanViews";
                    message = "Orphaned views are being removed from the ContextualView.";
                    warning(id, message);

                end %if

                % Ensure the ContentGrid layout state is consistent
                thisObj.ContentGrid.ColumnWidth = {'1x'};
                thisObj.ContentGrid.RowHeight = {'1x'};

            end %for

        end %function

    end %methods

end %classdef


% Validation function
function mustBeValidView(view)

for idx = 1:numel(view)
    mustBeA(view(idx), "wt.mixin.ModelObserver")
    mustBeA(view(idx), ["wt.abstract.BaseViewController", "wt.abstract.BaseViewChart"])
end

end %function