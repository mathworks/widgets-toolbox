classdef BaseChart < matlab.graphics.chartcontainer.ChartContainer & ...
        wt.mixin.FontStyled & ...
        wt.mixin.ErrorHandling
    % Base class for a chart with standard Cartesian axes

    % Copyright 2023 The MathWorks Inc.


    %% Public Properties
    properties (AbortSet, Access = public)

        % Show grid on each axes?
        ShowGrid (1,1) logical = false;

        % Show legend on each axes?
        ShowLegend (1,1) logical = false;

        % Background color of axes components
        AxesColor (1,3) double ...
            {mustBeInRange(AxesColor,0,1)} = [1 1 1]

        % Grid color of axes components
        AxesGridColor (1,3) double ...
            {mustBeInRange(AxesGridColor,0,1)} = [.15 .15 .15]

    end %properties


    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = protected)

        % List of graphics controls that BackgroundColor should apply to
        BackgroundColorableComponents (:,1) matlab.graphics.Graphics

        % TiledLayout for axes
        TiledLayout matlab.graphics.layout.TiledChartLayout

        % Axes to display the signal
        Axes (1,:) matlab.graphics.axis.Axes

    end %properties


    properties (Dependent, NonCopyable, Hidden, SetAccess = protected)

        % Legend of each axes
        Legend (1,:) matlab.graphics.illustration.Legend

    end %properties


    % Accessors
    methods

        function value = get.Legend(obj)
            if isempty(obj.Axes)
                value = matlab.graphics.illustration.Legend.empty(1,0);
            else
                value = horzcat(obj.Axes.Legend);
            end
        end %function

    end %methods


    %% Provide ability to request update at next drawing cycle
    % Use obj.requestUpdate() to trigger an update call at the next
    % opportunity (for optimal efficiency)

    % Private properties
    properties (Transient, NonCopyable, UsedInUpdate, Access = private)

        % Private property used to trigger the ChartContainer to call
        % update at next drawing update
        Dirty_P (1,1) logical = false

    end %properties


    % Private Methods
    methods (Access = private)

        function requestUpdate(obj)
            % Request update method to run

            obj.Dirty_P = ~obj.Dirty_P;

        end %function

    end %methods



    %% Debugging Methods
    methods

        function forceUpdateChart(obj)
            % Forces update to run (For debugging only!)

            disp("Debug: called forceUpdateChart");
            obj.update();

        end %function

    end %methods


    %% Protected methods
    methods (Access = protected)

        function setup(obj)
            % Create the underlying components

            % Configure Layout
            obj.addLayout([1 1])

            % Create the single axes
            obj.addAxes(1);

            % Add legends if specified
            if obj.ShowLegend
                obj.addLegends();
            end

            % Update styles
            obj.updateFontStyledComponents();
            obj.updateAxesColors();

        end %function


        function update(obj)
            % Update the underlying components

            % Toggle legends and grids
            set(obj.Axes,"XGrid",obj.ShowGrid,"YGrid",obj.ShowGrid,"ZGrid",obj.ShowGrid)

            % Update grid(s) and legend(s)
            obj.updateGridVisibility()
            obj.updateLegendVisibility()

        end %function


        function addLayout(obj, gridSize)

            % Configure Layout
            obj.TiledLayout = getLayout(obj);
            obj.TiledLayout.Padding = "compact";
            obj.TiledLayout.TileSpacing = "compact";
            obj.TiledLayout.GridSize = gridSize;

        end %function


        function addAxes(obj, numAxes)

            % Create the axes
            ax = gobjects(1,numAxes);

            for idx = 1:numAxes

                % Create the axes
                ax(idx) = nexttile(obj.TiledLayout);

                % Configure axes defaults
                ax(idx).NextPlot = "add";

                % Configure Interpreters
                ax(idx).Title.Interpreter = "none";
                ax(idx).XLabel.Interpreter = "none";
                ax(idx).YLabel.Interpreter = "none";
                ax(idx).ZLabel.Interpreter = "none";
                ax(idx).XAxis.TickLabelInterpreter = "none";
                ax(idx).YAxis.TickLabelInterpreter = "none";
                ax(idx).ZAxis.TickLabelInterpreter = "none";

            end %for

            % Attach axes
            obj.Axes = ax;

        end %function


        function addLegends(obj)

            % Create the legend for each axes
            lgnd = matlab.graphics.illustration.Legend.empty(1,0);
            for idx = 1:numel(obj.Axes)
                lgnd(idx) = legend(obj.Axes(idx));
                lgnd(idx).Interpreter = "none";
            end %if

            % Attach legend(s)
            obj.Legend = lgnd;

        end %function


        function updateGridVisibility(obj)
            % Toggle grids

            set(obj.Axes,"XGrid",obj.ShowGrid)
            set(obj.Axes,"YGrid",obj.ShowGrid)
            set(obj.Axes,"ZGrid",obj.ShowGrid)

        end %function


        function updateLegendVisibility(obj)
            % Updates the legend visibility

           lgnd = obj.Legend;
           if ~isempty(lgnd)
                set(lgnd,"Visible",obj.ShowLegend);
           elseif obj.ShowLegend
               obj.addLegends();
           end

        end %function


        function updateBackgroundColorableComponents(obj)
            % Update components that are affected by BackgroundColor

            obj.Grid.BackgroundColor = obj.BackgroundColor;
            hasProp = isprop(obj.BackgroundColorableComponents,'BackgroundColor');
            set(obj.BackgroundColorableComponents(hasProp),...
                "BackgroundColor",obj.BackgroundColor);

        end %function


        function updateAxesColors(obj)
            % Update axes colors

            % All components together
            allComponents = horzcat(obj.Axes, obj.Legend);

            % Set axes and legend background
            set(allComponents,"Color", obj.AxesColor)

            % Set grid color
            set(obj.Axes, "GridColor", obj.AxesGridColor)

        end %function


        function updateFontStyledComponents(obj,prop,value)

            % All components together
            axesAndLegend = horzcat(obj.Axes, obj.Legend);
            allComponents = horzcat(axesAndLegend, obj.Axes.Title);

            if nargin < 2
                % Update all

                set(allComponents, "FontName", obj.FontName)
                set(allComponents, "FontSize", obj.FontSize)
                set(axesAndLegend, "FontWeight", obj.FontWeight)
                set(allComponents, "FontAngle", obj.FontAngle)

                set(obj.Axes, "XColor", obj.FontColor)
                set(obj.Axes, "YColor", obj.FontColor)
                set(obj.Axes, "ZColor", obj.FontColor)
                set(obj.Legend,"TextColor", obj.FontColor)
                set([obj.Axes.Title],"Color", obj.FontColor)

            elseif prop == "FontColor"

                set(obj.Axes, "XColor", value)
                set(obj.Axes, "YColor", value)
                set(obj.Axes, "ZColor", obj.FontColor)
                set(obj.Legend,"TextColor", value)
                set([obj.Axes.Title],"Color", obj.FontColor)

            elseif prop == "FontWeight"

                set(axesAndLegend, "FontWeight", obj.FontWeight)

            else
                % Update other specific property

                wt.utility.fastSet(allComponents,prop,value);

            end %if

        end %function

    end %methods

end %classdef