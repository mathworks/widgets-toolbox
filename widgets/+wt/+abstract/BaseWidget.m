classdef BaseWidget < ...
        matlab.ui.componentcontainer.ComponentContainer & ...
        wt.mixin.BackgroundColorable & ...
        wt.mixin.PropertyViewable & ...
        wt.mixin.ErrorHandling
    % Base class for a graphical widget

    % Copyright 2020-2025 The MathWorks Inc.


    %% Events
    events (ListenAccess = public)

        % Triggered after WidgetTheme has changed
        WidgetThemeChanged

    end %event


    %% Internal properties
    properties (AbortSet, Transient, NonCopyable, Hidden, SetAccess = protected)

        % The internal grid to manage contents
        Grid matlab.ui.container.GridLayout

    end %properties


    properties (Transient, NonCopyable, Hidden, SetAccess = private)

        % Internal flag to confirm setup has finished
        SetupFinished (1,1) logical = false

    end %properties


    properties (Transient, NonCopyable, Access = private)

        % Listener for theme changes
        InternalThemeChangedListener event.listener

    end %properties


    properties (Transient, NonCopyable, UsedInUpdate = true, ...
            GetAccess = private, SetAccess = protected)

        % Internal flag to trigger an update call
        Dirty (1,1) logical = false

    end %properties


    %% Debugging Methods
    methods

        function forceUpdate(obj)
            % Forces update to run (For debugging only!)

            disp("DEBUG: Forcing update for " + class(obj));
            obj.update();

        end %function

    end %methods


    %% Constructor
    methods

        function obj = BaseWidget(varargin)

            % Attach internal postSetup callback
            args = horzcat(varargin, {"CreateFcn",  @(src,evt)postSetup_I(src)});

            % Call superclass constructor
            obj = obj@matlab.ui.componentcontainer.ComponentContainer(args{:});

            % Listen to theme changes (R2025a and later only)
            if ~isMATLABReleaseOlderThan("R2025a")
                obj.InternalThemeChangedListener = listener(obj,"ThemeChanged",...
                    @(~,evt)onWidgetThemeChanged_I(obj));
                % obj.WidgetTheme = obj.getTheme();
            end

        end %function

    end %methods


    %% Protected Methods
    methods (Access = protected)

        function setup(obj)
            % Configure the widget

            % Grid Layout to manage building blocks
            obj.Grid = uigridlayout(obj);
            obj.Grid.ColumnWidth = {'1x'};
            obj.Grid.RowHeight = {'1x'};
            obj.Grid.RowSpacing = 2;
            obj.Grid.ColumnSpacing = 2;
            obj.Grid.Padding = [0 0 0 0];

            % Set grid to follow background color
            obj.BackgroundColorableComponents = obj.Grid;

        end %function


        function postSetup(~)
            % Optional post-setup method
            % (after setup and input arguments set, before update)

        end %function


        function requestUpdate(obj)
            % Request update method to run

            % Trigger property to request update during next drawnow
            % (for optimal efficiency)
            obj.Dirty = true;

        end %function
        

        function updateBackgroundColorableComponents(obj)
            % Update components that are affected by BackgroundColor
            % (overrides the superclass method)
            
            % Update grid color
            set(obj.Grid, "BackgroundColor", obj.BackgroundColor);

            % Call superclass method
            obj.updateBackgroundColorableComponents@wt.mixin.BackgroundColorable();
            
        end %function


        function groups = getPropertyGroups(obj)
            % Customize the property display
            % (override to use the mixin implementation, since multiple
            % superclasses have competing implementations)

            groups = getPropertyGroups@wt.mixin.PropertyViewable(obj);

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

        function postSetup_I(obj)
            % Indicate setup is complete

            obj.SetupFinished = true;
            obj.CreateFcn = '';

            % Call any custom postSetup method
            obj.postSetup();

        end %function


        function onWidgetThemeChanged_I(obj)
            % Handle theme changes

            notify(obj,"WidgetThemeChanged")

        end %function

    end %methods


end %classdef