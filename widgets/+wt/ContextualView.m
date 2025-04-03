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


    %% Public Properties
    properties (AbortSet, Access = public)

        % Block while loading
        BlockWhileLoading (1,1) logical = true

        % Image to use on loading screen
        LoadingImageSource (1,1) string = "loading_32.gif"

    end %properties


    %% Read-Only Properties
    properties (Dependent, SetAccess = immutable)

        LoadedViewTypes
    
        LoadedViews

        ActiveViewType

    end %properties

    properties (SetAccess = private, UsedInUpdate = false)

        % The currently active view, or empty if none
        ActiveView (:,1) matlab.graphics.Graphics {mustBeScalarOrEmpty} = ...
            wt.abstract.BaseViewController.empty(0,1)

        % The array of views loaded into memory
        LoadedViews_I (:,1) matlab.graphics.Graphics = ...
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
            views = obj.ActiveView;
            if isscalar(views) && isvalid(views)
                value = string( class(views) );
            else
                value = "";
            end
        end

        % function set.LoadedViews(obj,value)
        %     % Remove any deleted views from the list
        %     keepItems = arrayfun(@isvalid, value);
        %     value(~keepItems) = [];
        %     obj.LoadedViews = value;
        % end

    end %methods


    %% Internal Properties
    properties (AbortSet, Transient, NonCopyable, Hidden, ...
            SetAccess = protected, UsedInUpdate = false)

        % Top-level grid to manage content vs. loading
        % Grid matlab.ui.container.GridLayout

        % The internal grid to manage contents
        ContentGrid matlab.ui.container.GridLayout

        % Image to show when loading a pane
        LoadingImage matlab.ui.control.Image

        % First load flag
        FirstLoad (1,1) logical = true

    end %properties


    %% Public Methods
    methods

        function varargout = launchView(obj, viewClass, model)
            % This method may be overloaded as needed

            arguments
                obj (1,1) wt.ContextualView
                viewClass (1,1) string
                model wt.model.BaseModel = wt.model.BaseModel.empty
            end

            fprintf("\nlaunchView: start %s\n", viewClass)

            % Remove the initial box on first load
            if obj.FirstLoad
                obj.Grid.Padding = 0;
                obj.FirstLoad = false;
            end

            % After launch is complete, toggle off loading image
            cleanupObj = onCleanup(@()set(obj.LoadingImage,"Visible","off"));

            % Is the loading image non-visible?
            if ~obj.LoadingImage.Visible

                % If the view will change, show the loading image
                fprintf("launchView: prepare %s\n", viewClass)
                obj.prepareToLaunchView(viewClass)

            end %if

            % Was a view provided?
            if strlength(viewClass)

                % Validate view class
                view = validateViewClass(obj, viewClass);

                % If no existing view found, instantiate the view
                if isempty(view)
                    fprintf("launchView: instantiate %s\n", viewClass)
                    obj.instantiateView_Private(viewClass, model);
                else
                    fprintf("launchView: activate %s\n", viewClass)
                    obj.activateView_Private(view, model)
                end

            else

                % Empty view, clear the contents
                fprintf("launchView: clear %s\n", viewClass)
                obj.clearView();

            end %if

            % Return the active view
            if nargout
                varargout{1} = obj.ActiveView;
            end

            % fprintf("\n  launchView: finish ** DRAWNOW ** %s\n", viewClass)
            % drawnow("nocallbacks")

        end %function


        function varargout = launchViews(obj, viewClass, model)
            % This method may be overloaded as needed

            arguments
                obj (1,:) wt.ContextualView
            end

            arguments (Repeating)                
                viewClass (1,1) string
                model wt.model.BaseModel
            end

            % Convert viewClass cell to string array
            viewClass = [viewClass{:}];

            fprintf("\nlaunchViews: start %s\n", join(viewClass,"; "))

            % After launch is complete, toggle off loading image
            % cleanupObj = onCleanup(@()set([obj.LoadingImage],"Visible","off"));

            % Remove the initial box on first load
            % for thisObj = obj
            %     if thisObj.FirstLoad
            %         thisObj.Grid.Padding = 0;
            %         thisObj.FirstLoad = false;
            %     end
            % end

            % Deactivate any views that will be changing
            % Loop on each ContextualView provided
            numViews = numel(obj);
            for idx = 1:numViews

                % Get current ContextualView obj and viewClass to launch
                thisObj = obj(idx);
                thisViewClass = viewClass(idx);

                % Determine if the viewClass is empty or if viewClass will change
                isEmptyView = ~strlength(thisViewClass);
                willChangeView = thisObj.ActiveViewType ~= thisViewClass;

                % If changing, deactivate the current view now
                if isEmptyView || willChangeView
                    thisObj.deactivateView_Private(thisObj.ActiveView);
                end %if

            end %for
            

            % Instantiate or activate any new views
            % Loop on each ContextualView provided
            for idx = 1:numel(obj)
 
                % Get current ContextualView and content
                thisObj = obj(idx);
                thisViewClass = viewClass(idx);
                thisModel = model{idx};

                % Was a view provided?
                if strlength(viewClass)

                    % Validate view class (get existing view if present)
                    view = validateViewClass(thisObj, thisViewClass);

                    % If no existing view found, instantiate the view
                    if isempty(view)
                        fprintf("launchViews: instantiate %s\n", thisViewClass)
                        thisObj.instantiateView_Private(thisViewClass, thisModel);
                    else
                        fprintf("launchViews: activate %s\n", thisViewClass)
                        thisObj.activateView_Private(view, thisModel)
                    end

                end %if

            end

            % Return the active views
            if nargout
                varargout = {obj.ActiveView};
            end

            fprintf("\n  launchView: finish %s\n", join(viewClass,"; "))
            % drawnow("nocallbacks")

        end %function


        function prepareToLaunchView(viewArray, viewClassArray)
            % Puts the ContextualView in a loading state if a different
            % view is about to be launched. Use this if your app has
            % multiple ContextualView instances and you need to potentially
            % load multiple simultaneously. You can provide an array of
            % views here to turn them to loading state together.

            arguments
                viewArray wt.ContextualView
                viewClassArray string
            end

            fprintf("\nprepareToLaunchView: start %s\n",join(viewClassArray,"; "));

            % Flag if we need to trigger a drawnow to give time to display
            % the loading image
            updateNeeded = false;

            % Check each ContextualView in the input array
            for idx = 1:numel(viewArray)

                % Get one at a time
                thisView = viewArray(idx);
                viewClass = viewClassArray(idx);

                % Is the view class going to change?
                willLaunchView = isempty(thisView.ActiveView) && strlength(viewClass);
                willChangeView = isscalar(thisView.ActiveView) && ...
                    class(thisView.ActiveView) ~= viewClass;
                loadingCurrentState = thisView.LoadingImage.Visible;

                % If the view will change, show the loading image
                if thisView.BlockWhileLoading && ...
                        loadingCurrentState == "off" && ...
                        (willLaunchView || willChangeView)

                    % Yes we will toggle the loading image.
                    % This will prevent interaction during launch
                    thisView.LoadingImage.Visible = "on";
                    updateNeeded = true;

                end %if

            end %for

            % If a change was made, give an opportunity to update the
            % display so the loading image will display. (This is guarded
            % in a conditional to avoid multiple calls
            % causing performance issues.)
            % if updateNeeded
            %     fprintf("\n  prepareToLaunchView: finish with ** DRAWNOW ** %s\n",join(viewClassArray,"; "));
                % drawnow
                % drawnow("nocallbacks")
                % drawnow("limitrate")                
            % else
                fprintf("prepareToLaunchView: finish %s\n",join(viewClassArray,"; "));
            % end


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

            % Loop on views
            for thisObj = obj

                % Deactivate any active view
                thisObj.deactivateView_Private();

                % Delete any loaded views
                delete(thisObj.LoadedViews_I);
                thisObj.LoadedViews_I(:) = [];

                % Delete any orphaned children
                if ~isempty(thisObj.ContentGrid.Children)
                    delete(thisObj.ContentGrid.Children);
                end

                % Reset the layout state
                thisObj.ContentGrid.ColumnWidth = {'1x'};
                thisObj.ContentGrid.RowHeight = {'1x'};

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
            %       - ContentGrid (views go here)
            %       - LoadingImage (visible gets toggled to cover view)


            % Call superclass method
            obj.setup@wt.abstract.BaseWidget()
            
             % Set default size and position
            obj.Position = [10 10 400 400];

            % Configure grid
            % Show an temporary border around the edge. This makes the
            % component more obvious in App Designer
            obj.Grid.Padding = [1 1 1 1];

            % Default to theme color
            if isMATLABReleaseOlderThan("R2025a")
                color = [.5 .5 .5];
            else
                color = obj.getThemeColor("--mw-borderColor-primary");
            end
            obj.Grid.BackgroundColor = color;

            % Grid Layout to place the contents
            obj.ContentGrid = uigridlayout(obj.Grid,[1 1]);
            obj.ContentGrid.Padding = [0 0 0 0];
            obj.ContentGrid.Layout.Row = 1;
            obj.ContentGrid.Layout.Column = 1;

            % Image to display while loading content
            obj.LoadingImage = uiimage(obj.Grid);
            obj.LoadingImage.Layout.Row = 1;
            obj.LoadingImage.Layout.Column = 1;
            obj.LoadingImage.Visible = "off";
            obj.LoadingImage.ScaleMethod = "none";

            % Components to apply background color
            obj.BackgroundColorableComponents = ...
                [obj.ContentGrid, obj.LoadingImage];

        end %function


        function update(obj)

            % Configure the loading image
            obj.LoadingImage.ImageSource = obj.LoadingImageSource;

        end %function

    end %methods


    %% Private methods
    methods (Access=private)

        function view = validateViewClass(obj, viewClass)
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

            elseif isequal(viewClass, class(obj.ActiveView))

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
                view = viewConstructorFcn(obj.ContentGrid);

                % Position the view in the single grid cell
                view.Layout.Row = 1;
                view.Layout.Column = 1;

                % Add the new view to the list
                obj.LoadedViews_I = vertcat(obj.LoadedViews_I, view);

            catch err

                % Clean up partially loaded children
                delete(obj.ContentGrid.Children(2:end))

                % Throw an error
                title = "Error launching view: " + viewClass;
                obj.throwError(err.message, title);

                % Deactivate current pane
                obj.deactivateView_Private();

                % Rethrow the error to the command window
                rethrow(err)

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

            % Does this view need to be made active?
            needToMarkActive = ~isequal(obj.ActiveView, view);
            if needToMarkActive

                % Remove the old view at the end of this function
                oldView = obj.ActiveView;
                cleanupObj = onCleanup(@()obj.deactivateView_Private(oldView));

                % Assign parent
                if ~isequal(view.Parent, obj.ContentGrid)
                    view.Parent = obj.ContentGrid;
                    view.Layout.Column = 1;
                    view.Layout.Row = 1;
                end
                view.Visible = true;

                % Store this view as active view
                obj.ActiveView = view;

            end %if

            % Attach model
            if ~isempty(model) && all(isvalid(model(:)))

                % Attach the model
                obj.attachModel_Private(view, model)

            end %if

        end %function


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

            % Remove the view's model and unparent it
            view.Model(:) = [];
            view.Parent(:) = [];

            % Remove view from the active view property
            if isequal(obj.ActiveView, view)
                obj.ActiveView(:) = [];
            end

            % Clean up partially loaded children
            if numel(obj.ContentGrid.Children) > 1
                delete(obj.ContentGrid.Children(2:end))
            end

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

    end %methods

end %classdef


% Validation function
function mustBeValidView(view)

for idx = 1:numel(view)
    mustBeA(view(idx), "wt.mixin.ModelObserver")
    mustBeA(view(idx), ["wt.abstract.BaseViewController", "wt.abstract.BaseViewChart"])
end

end %function