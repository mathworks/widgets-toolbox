classdef BaseViewController < wt.mixin.ModelObserver & ...
        matlab.ui.componentcontainer.ComponentContainer & ...
        wt.mixin.BackgroundColorable & ...
        wt.mixin.TitleFontStyled & ...
        wt.mixin.ErrorHandling

    % Base class for views/controllers referencing a BaseModel class

    % Copyright 2025 The MathWorks Inc.


    %% Events
    events (ListenAccess = public)

        % Triggered after WidgetTheme has changed
        WidgetThemeChanged

    end %event


    %% Public Properties
    properties (AbortSet)

        % The default panel name prefix to display
        PanelNamePrefix (1,1) string

    end %properties


    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = protected)

        % Internal grid to place outer panel contents
        OuterGrid matlab.ui.container.GridLayout

        % Outer panel with optional title
        OuterPanel matlab.ui.container.Panel

        % The internal grid to manage contents
        Grid matlab.ui.container.GridLayout

    end %properties


    properties (Transient, NonCopyable, Access = private)

        % Listener for theme changes
        InternalThemeChangedListener event.listener

    end %properties


    properties (Transient, NonCopyable, UsedInUpdate = true, ...
            GetAccess = private, SetAccess = protected)

        % Internal flag to trigger an update call
        Dirty_ (1,1) logical = false

    end %properties


    %% Constructor
    methods
        function obj = BaseViewController(varargin)
            % Constructor

            % Call superclass constructors
            obj = obj@matlab.ui.componentcontainer.ComponentContainer(varargin{:});
            obj@wt.mixin.ModelObserver();

            % Listen to theme changes (R2025a and later only)
            if ~isMATLABReleaseOlderThan("R2025a")
                obj.InternalThemeChangedListener = listener(obj,"ThemeChanged",...
                    @(~,evt)onWidgetThemeChanged_I(obj));
                % obj.WidgetTheme = obj.getTheme();
            end

        end %function
    end %methods

    
    %% Debugging Methods
    methods
        
        function forceUpdate(obj)
            % Forces update to run (For debugging only!)

            disp("DEBUG: Forcing update for " + class(obj));
            obj.update();

        end %function
        
    end %methods


    %% Protected Methods
    methods (Access = protected)

        function setup(obj)
            % Configure the widget

            % Set default positioning
            warnState = warning('off','MATLAB:ui:components:noPositionSetWhenInLayoutContainer');
            obj.Units = "normalized";
            obj.Position = [0 0 1 1];
            warning(warnState);

            % Outer grid to place the outer panel
            obj.OuterGrid = uigridlayout(obj, [1 1]);
            obj.OuterGrid.Padding = [0 0 0 0];

            % Make an outer panel
            obj.OuterPanel = uipanel(obj.OuterGrid);

            % Name the panel with the view's class name by default
            obj.PanelNamePrefix = extract(string(class(obj)), ...
                alphanumericsPattern + textBoundary);
            obj.OuterPanel.Title = obj.PanelNamePrefix;

            % Grid Layout to manage contents
            obj.Grid = uigridlayout(obj.OuterPanel,[5 2]);
            obj.Grid.Padding = 10;
            obj.Grid.ColumnWidth = {'fit','1x'};
            obj.Grid.RowHeight = {'fit','fit','fit','fit','fit'};
            obj.Grid.ColumnSpacing = 5;
            obj.Grid.RowSpacing = 10;
            obj.Grid.Scrollable = true;

            % Update component lists
            obj.BackgroundColorableComponents = [obj.Grid, obj.OuterGrid, obj.OuterPanel];
            obj.TitleFontStyledComponents = [obj.OuterPanel];

        end %function


        function update(obj)

            % Get the model to display
            [model, validToDisplay] = obj.getScalarModelToDisplay();

            % Prepare default name of the panel
            if validToDisplay && strlength(model.Name)
                panelTitle = obj.PanelNamePrefix + ": " + model.Name;
            else
                panelTitle = obj.PanelNamePrefix;
            end

            % Update the panel name
            obj.OuterPanel.Title = panelTitle;

        end %function


        function requestUpdate(obj)
            % Request update to occur at next drawnow cycle

            obj.Dirty_ = ~obj.Dirty_;

        end %function
        

        function onModelSet(obj)
            % Triggered when Model has been changed

            % Request an update
            obj.requestUpdate();

        end %function

        
        function onModelChanged(obj,~)
            % Triggered when a property within the model has changed

            % Request an update
            obj.requestUpdate();

        end %function


        function onFieldEdited(obj,evt,fieldName,index)
            % This is a generic callback that simple controls may use. For
            % example, the ValueChangedFcn for an edit field may call this
            % directly with the Model's property name that should be
            % updated. Use this for callbacks of simple controls that can
            % set a field simply by name.

            arguments
                obj (1,1) wt.abstract.BaseViewController
                evt
                fieldName (1,1) string
                index (1,:) double {mustBeInteger,mustBePositive} = zeros(1,0)
            end

            if ~isscalar(obj.Model)
                warning("wt:BaseViewController:onFieldEdited:NonScalarModel",...
                    "The onFieldEdited method is unable to set new " + ...
                    "value to an empty or nonscalar model.")
                return
            end

            % Get the new value
            newValue = evt.Value;

            % Treat char as string
            if ischar(newValue)
                newValue = string(newValue);
            end

            % Handle array values with the index input indicating what
            % index of the newValue was changed
            if ~isscalar(newValue) && ~isempty(index) && ...
                    isscalar(obj.Model.(fieldName)(index))

                % We have one index of an array being set
                obj.Model.(fieldName)(index) = newValue(index);

            else

                % We are setting the entire array
                obj.Model.(fieldName) = newValue;

            end

        end %function

    end %methods


    %% Hidden Methods
    methods (Hidden, Sealed)

        function color = getThemeColor(obj, semanticColorId)
            % Get color from theme and semantic variable

            msg = "MATLAB R2025a or later is needed to call wt.abstract.BaseWidget.getThemeColor().";
            assert(~isMATLABReleaseOlderThan("R2025a"), msg)

            % Get the theme
            theme = obj.getTheme();

            % Get theme from semantic variable
            % This is undocumented and may change. Better to call the
            % getThemeColor method rather than reusing this directly.
            color = matlab.graphics.internal.themes.getAttributeValue(...
                theme, semanticColorId);

        end %function

    end %methods


    %% Private Methods
    methods (Access = private)

        function onWidgetThemeChanged_I(obj)
            % Handle theme changes

            notify(obj,"WidgetThemeChanged")

        end %function

    end %methods


end %classdef