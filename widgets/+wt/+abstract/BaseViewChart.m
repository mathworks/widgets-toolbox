classdef BaseViewChart < matlab.graphics.chartcontainer.ChartContainer & ...
        wt.mixin.ModelObserver
    % Base class for view charts referencing a BaseModel class

    % Copyright 2025 The MathWorks Inc.


    %% Public Properties
    properties (AbortSet)

        % The default title prefix to display
        TitlePrefix (1,1) string

    end %properties


    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = protected)

        % TiledLayout for axes
        TiledLayout matlab.graphics.layout.TiledChartLayout

        % Axes to display the signal
        Axes (1,:) matlab.graphics.axis.Axes

        % Legend of each axes
        Legend (1,:) matlab.graphics.illustration.Legend

    end %properties


    properties (Transient, NonCopyable, UsedInUpdate = true, ...
            GetAccess = private, SetAccess = protected)

        % Internal flag to trigger an update call
        TriggerUpdate_BVC (1,1) logical = false

    end %properties


    %% Constructor
    methods
        function obj = BaseViewChart(parent, varargin)
            % Constructor

            if nargin < 1
                fig = uifigure();
                parent = uigridlayout(fig,[1,1]);
            end

            % Call superclass constructors
            obj = obj@matlab.graphics.chartcontainer.ChartContainer(parent, varargin{:});
            obj@wt.mixin.ModelObserver();

        end %function
    end %methods

    
    %% Debugging Methods
    methods
        
        function forceUpdateChart(obj)
            % Forces update to run (For debugging only!)

            obj.update();

        end %function
        
    end %methods


    %% Protected Methods
    methods (Access = protected)

        function setup(obj)
            % Create the underlying components

            % Configure Layout
            obj.TiledLayout = getLayout(obj);
            obj.TiledLayout.Padding = "compact";
            obj.TiledLayout.TileSpacing = "compact";

            % Name the panel with the view's class name by default
            obj.TitlePrefix = extract(string(class(obj)), ...
                alphanumericsPattern + textBoundary);
            obj.TiledLayout.Title.String = obj.TitlePrefix;

        end %function


        function update(obj)

            % Get the model to display
            [model, validToDisplay] = obj.getScalarModelToDisplay();

            % Prepare default name of the panel
            if validToDisplay && strlength(model.Name)
                groupTitle = obj.TitlePrefix + ": " + model.Name;
            else
                groupTitle = obj.TitlePrefix;
            end

            % Update the panel name
            obj.TiledLayout.Title.String = groupTitle;

        end %function


        function requestUpdate(obj)
            % Request update to occur at next drawnow cycle

            obj.TriggerUpdate_BVC = ~obj.TriggerUpdate_BVC;

        end %function
        

        function onModelSet(obj)
            % Triggered when Model has been set to a new value

            % Request an update
            obj.requestUpdate();

            % Call superclass method
            obj.onModelSet@wt.mixin.ModelObserver()

        end %function
        

        function onModelChanged(obj,evt)
            % Triggered when a property within the model has changed

            % Request an update
            obj.requestUpdate();

            % Call superclass method
            obj.onModelChanged@wt.mixin.ModelObserver(evt)

        end %function

    end %methods

end %classdef