classdef BaseSingleAxesChart < ...
        matlab.graphics.chartcontainer.ChartContainer & ...
        wt.mixin.BoundSingleTimeAxes
    % Base class for a time chart with single axes

    %   Copyright 2022-2025 The MathWorks Inc.
    

    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = protected)

        % TiledLayout for axes
        TiledLayout matlab.graphics.layout.TiledChartLayout {mustBeScalarOrEmpty}

        % Axes to display the signal
        Axes matlab.graphics.axis.Axes {mustBeScalarOrEmpty}

        % Legend of each axes
        Legend matlab.graphics.illustration.Legend {mustBeScalarOrEmpty}

    end %properties


    properties (Transient, NonCopyable, UsedInUpdate=true, Access = private)

        % Internal flag to trigger an update call
        Dirty_ (1,1) logical = false

    end %properties


    %% Debugging Methods
    methods

        function forceUpdateChart(obj)
            % Forces update to run (For debugging only!)

            obj.update();

        end %function

    end %methods


    %% Protected methods
    methods (Access = protected)

        function setup(obj)
            % Create the underlying components

            % Configure Layout
            obj.TiledLayout = getLayout(obj);
            obj.TiledLayout.Padding = "compact";
            obj.TiledLayout.TileSpacing = "compact";
            obj.TiledLayout.GridSize = [1 1];

            % Create the axes
            ax = nexttile(obj.TiledLayout);
            ax.XAxis = matlab.graphics.axis.decorator.DurationRuler();
            ax.XAxis.TickLabelInterpreter = "none";
            ax.YAxis.TickLabelInterpreter = "none";
            ax.Title.Interpreter = "none";
            ax.XLabel.Interpreter = "none";
            ax.YLabel.Interpreter = "none";
            ax.ZLimMode = "manual";

            % Create the legend
            lgnd = legend(ax,'Location',"northwest");
            lgnd.Interpreter = "none";
            lgnd.Visible = "off";

            % Store new objects
            obj.Axes = ax;
            obj.Legend = lgnd;

            % Bind components to their style mixins
            obj.BoundAxes = ax;

        end %function


        function update(~)
            % Update the underlying components


        end %function


        function requestUpdate(obj)
            % Request update method to run

            % Trigger set of a UsedInUpdate property to request update
            % during next drawnow. (for optimal efficiency)
            obj.Dirty_ = ~obj.Dirty_;

        end %function



        function groups = getPropertyGroups(obj)
            % Customize how the properties are displayed

            % Ignore most superclass properties for default display
            persistent superProps
            if isempty(superProps)
                superProps = properties('matlab.graphics.chartcontainer.ChartContainer');
            end

            % Get the relevant properties (ignore Superclass properties)
            allProps = properties(obj);
            propNames = setdiff(allProps, superProps, 'stable');

            % Define the property gorups
            groups = [
                matlab.mixin.util.PropertyGroup(propNames)
                matlab.mixin.util.PropertyGroup(["Position","Units"])
                ];

        end %function

    end %methods

end %classdef