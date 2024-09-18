classdef ContextualView < matlab.ui.componentcontainer.ComponentContainer & ...
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
    % Content views that are placed in this ContextualView should
    % inherit the following classes:
    %   matlab.ui.componentcontainer.ComponentContainer
    %   wt.mixin.ContextualView (if auto-populating Model property)

    % Copyright 2024 The MathWorks Inc.


    %% Events
    events (HasCallbackProperty, NotifyAccess = protected)

        % Triggered when the Model has changed
        ModelSet

        % Triggered when a property within the model has changed
        ModelChanged

    end %events


    %% Internal Properties
    properties (AbortSet, Transient, NonCopyable, Hidden, SetAccess = protected)

        % The internal grid to manage contents
        Grid matlab.ui.container.GridLayout

        % Listener for a new model being attached
        ModelSetListener event.listener

        % Listener for property changes within the model
        ModelPropertyChangedListener event.listener

    end %properties


    properties (SetAccess=private)

        % The currently active view, or empty if none
        ActiveView (:,1) matlab.graphics.Graphics ...
            {mustBeScalarOrEmpty, mustBeValidView(ActiveView)} = ...
            wt.abstract.BaseViewController.empty(0,1)

        % The array of views loaded into memory
        LoadedViews (:,1) matlab.graphics.Graphics ...
            {mustBeValidView(LoadedViews)} = ...
            wt.abstract.BaseViewController.empty(0,1)

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
            keepItems = arrayfun(@isvalid, value);
            value(~keepItems) = [];
        end

        function set.LoadedViews(obj,value)
            % Remove any deleted views from the list
            keepItems = arrayfun(@isvalid, value);
            value(~keepItems) = [];
            obj.LoadedViews = value;
        end

    end %methods


    %% Public Methods
    methods

        function varargout = launchView(obj, viewClass, model)
            % This method may be overloaded as needed

            arguments
                obj (1,1) wt.ContextualView
                viewClass (1,1) string
                model wt.model.BaseModel = wt.model.BaseModel.empty(0)
            end

            % Prevent interaction during launch
            % dlg = obj.showIndeterminateProgress("Loading...","",true);
            % cleanupObj = onCleanup(@()delete(dlg));

            % Validate view class
            view = validateViewClass(obj, viewClass);

            % If no existing view found, instantiate the view
            if isempty(view)
                obj.instantiateView_Private(viewClass, model);
            else
                obj.activateView_Private(view, model)
            end

            % Return the active view
            if nargout
                varargout{1} = obj.ActiveView;
            end

        end %function


        function clearView(obj)
            % This method may be overloaded as needed

            arguments
                obj (1,1) wt.ContextualView
            end

            % Remove listeners
            obj.ModelSetListener(:) = [];
            obj.ModelPropertyChangedListener(:) = [];

            % Clear the view
            obj.deactivateView_Private();

        end %function


        function relaunchActiveView(obj)
            % Delete and reload the active view

            % Is there an active view? If no, return early
            activeView = obj.ActiveView;
            if isempty(activeView)
                warning("wt:ContextualView:noActiveView",...
                    "No active view is present.")
                return
            end

            % Get the current view and model
            viewClass = class(activeView);
            model = activeView.Model;

            % Deactivate the active view
            obj.clearView();

            % Delete the previously active view
            delete(activeView);
            obj.LoadedViews(obj.LoadedViews == activeView) = [];

            % Launch the same view again
            obj.launchView(viewClass, model);

        end %function


        function reset(obj)
            % Reset the control by deactivating current view and delete loaded views

            % Remove listeners
            obj.ModelSetListener(:) = [];
            obj.ModelPropertyChangedListener(:) = [];

            % Deactivate any active view
            obj.deactivateView_Private();

            % Delete any loaded views
            delete(obj.LoadedViews);
            obj.LoadedViews(:) = [];

            % Delete any orphaned children
            delete(obj.Grid.Children);

            % Reset the layout state
            obj.Grid.ColumnWidth = {'1x'};
            obj.Grid.RowHeight = {'1x'};

        end %function

    end %methods


    %% Protected Methods
    methods (Access=protected)


        function setup(obj)
            % Configure the widget

            % Grid Layout to place the contents
            obj.Grid = uigridlayout(obj,[1 1]);
            obj.Grid.Padding = [0 0 0 0];
            % obj.Grid.BackgroundColor = [.7 .7 .9];

        end %function


        function update(~)

            % Do nothing - required for ComponentContainer

        end %function

    end %methods


    %% Private methods
    methods (Access=private)

        function view = validateViewClass(obj, viewClass)
            % This validates the view class and check for existing
            % instances. If an existing instance is found, it is returned.
            % Otherwise, an empty view is returned

            arguments (Input)
                obj (1,1) wt.ContextualView
                viewClass (1,1) string
            end

            arguments (Output)
                view (:,1) {mustBeScalarOrEmpty, mustBeValidView(view)}
            end

            % Try to locate a valid view
            if ~exist(viewClass,"class")

                % Throw an error and return
                id = "wt:ContextualView:InvalidPaneType";
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
                obj (1,1) wt.ContextualView
                viewClass (1,1) string
                model wt.model.BaseModel %= wt.model.BaseModel.empty(0)
            end

            arguments (Output)
                view (:,1) {mustBeScalarOrEmpty, mustBeValidView(view)}
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

                % Clean up partially loaded children
                delete(obj.Grid.Children(2:end))

                % Throw an error
                message = sprintf("Error launching view (%s).\n\n%s",...
                    viewClass, err.message);
                obj.throwError(message);

                % Deactivate current pane
                obj.deactivateView_Private();

                return

            end %try

            % Activate the view
            obj.activateView_Private(view, model)

        end %function


        function activateView_Private(obj, view, model)
            % Activate a view, placing it in view and attaching a model

            arguments
                obj (1,1) wt.ContextualView
                view (1,1) {mustBeValidView(view)}
                model wt.model.BaseModel
            end

            % Get the old view
            oldView = obj.ActiveView;

            % Assign parent
            if ~isequal(view.Parent, obj.Grid)
                view.Parent = obj.Grid;
            end
            view.Visible = true;

            % Set view as the active view
            if ~isequal(obj.ActiveView, view)
                obj.ActiveView = view;
                cleanupObj = onCleanup(@()obj.deactivateView_Private(oldView));
            end

            % Attach model
            if ~isempty(model) && all(isvalid(model(:)))

                % Attach the model
                obj.attachModel_Private(view, model)

            end %if

            % Remove listeners
            % obj.ModelSetListener(:) = [];
            % obj.ModelPropertyChangedListener(:) = [];

            % Listen to the active view indicating that its model has been
            % set or changed
            obj.ModelSetListener = listener(view,...
                "ModelSet",@(~,evt)obj.onModelSet(evt));
            obj.ModelPropertyChangedListener = listener(view,...
                "ModelChanged",@(~,evt)obj.onModelChanged(evt));

        end %function


        % function attachModelPropertyChangedListener(obj)
        % 
        %     % Listen to the active view indicating model changes
        %     model = obj.ActiveView.Model;
        %     obj.ModelPropertyChangedListener = listener(model,...
        %         "ModelChanged",@(~,evt)obj.onModelChanged(evt));
        % 
        % end %function


        function deactivateView_Private(obj, view)
            % Deactivate a view, removing from view and removing model
            arguments
                obj (1,1) wt.ContextualView
                view {mustBeValidView(view)} = obj.ActiveView
            end

            % Return now if view provided is empty
            if isempty(view) || ~isvalid(view)
                return
            end

            % Enable any prior view changes to finish, avoiding any
            % "flashing" effects during the change
            % drawnow
            % drawnow('nocallbacks','limitrate')

            % Remove any listeners on the view
            obj.ModelSetListener = obj.deleteListenersForSource(...
                obj.ModelSetListener, view);
            obj.ModelPropertyChangedListener = obj.deleteListenersForSource(...
                obj.ModelPropertyChangedListener, view);

            % Deactivate the view, removing model and parent
            view.Model(:) = [];
            view.Parent(:) = [];

            % Remove view from the active view property
            if isequal(obj.ActiveView, view)
                obj.ActiveView(:) = [];
            end
            
        end %function


        function modelListener = deleteListenersForSource(~, modelListener, source)
            % Deletes listeners with the given source
            
            deleteListener = false(size(modelListener));
            for idx = numel(modelListener) : -1 : 1
                thisListener = modelListener(idx);
                for sIdx = 1:numel(thisListener.Source)
                    thisSrc = thisListener.Source{sIdx};
                    if thisSrc == source
                        deleteListener(idx) = true;
                    end
                end
            end
            delete(modelListener(deleteListener))
            modelListener(deleteListener) = [];

        end %function


        function attachModel_Private(obj, view, model)
            % Attach model to the active view

            arguments
                obj (1,1) wt.ContextualView
                view (1,1) {mustBeValidView(view)}
                model wt.model.BaseModel
            end

            % Trap errors during model assignment
            if ~isempty(model) && all(isvalid(model(:)))

                try
                    % Assign model
                    view.Model = model;

                    % Listen to model changes
                    % obj.attachModelPropertyChangedListener();

                catch err

                    message = sprintf("Unable to assign model (%s) " + ...
                        "to view/controller (%s).\n\n%s",...
                        class(model), class(view), err.message);
                    obj.throwError(message);

                end %try

            end %if

        end %function


        function onModelSet(obj,evt)

            % Prepare eventdata
            evtOut = wt.eventdata.ModelSetData;
            evtOut.Model = evt.Model;
            evtOut.Controller = evt.Controller;

            % Notify listeners
            obj.notify("ModelSet",evtOut);

        end %function


        function onModelChanged(obj,evt)

            % Prepare eventdata
            evtOut = wt.eventdata.ModelChangedData;
            evtOut.Model = evt.Model;
            evtOut.Property = evt.Property;
            evtOut.Value = evt.Value;
            evtOut.Stack = [{obj}, evt.Stack];
            evtOut.ClassStack = [class(obj), evt.ClassStack];

            % Notify listeners
            obj.notify("ModelChanged",evtOut);

        end %function

    end %methods

end %classdef


% Validation function 
function mustBeValidView(view)

mustBeA(view, "wt.mixin.ModelObserver")
mustBeA(view, ["wt.abstract.BaseViewController", "wt.abstract.BaseViewChart"])

end %function