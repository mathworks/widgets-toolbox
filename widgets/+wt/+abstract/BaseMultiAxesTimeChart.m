classdef BaseMultiAxesTimeChart< ...
        matlab.graphics.chartcontainer.ChartContainer & ...
        wt.mixin.BoundMultiTimeAxes & ...
        wt.mixin.BoundTitleText
    % Base class for a time chart with multi axes

    %   Copyright 2022-2025 The MathWorks Inc.
    


    %% Public Properties
    properties (AbortSet, Access = public)

        % How many axes to display
        NumAxes (1,1) double {mustBePositive,mustBeInteger} = 3

        % Overall group title
%         GroupTitle (1,1) string

    end %properties

    % Accessors
    methods

        function set.NumAxes(obj,value)
            obj.NumAxes = value;
            obj.createAxes();
        end

    end %methods


    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = protected)

        % TiledLayout for axes
        TiledLayout matlab.graphics.layout.TiledChartLayout {mustBeScalarOrEmpty}

        % Axes to display the signal
        Axes (:,1) matlab.graphics.axis.Axes

        % Legend of each axes
        Legend (:,1) matlab.graphics.illustration.Legend

    end %properties


    properties (Transient, NonCopyable, UsedInUpdate=true, Access = private)

        % Internal flag to trigger an update call
        Dirty_ (1,1) logical = false

    end %properties


    properties (Transient, NonCopyable, Access = private)

        % State of axes layout
        AxesLayoutDirty (1,1) logical = true

    end %properties


    %% Protected methods
    methods (Access = protected)

        function setup(obj)
            % Create the underlying components

            % Configure Layout
            obj.TiledLayout = getLayout(obj);
            obj.TiledLayout.Padding = "compact";
            obj.TiledLayout.TileSpacing = "compact";
            obj.TiledLayout.GridSize = [obj.NumAxes 1];

            % Create the initial axes
            obj.createAxes();

%             obj.TitleInterpreter = "none"; % default to off

        end %function


        function createAxes(obj)
            % Triggered on initial setup or NumAxes changed

            % How many axes to make?
            newNumAxes = obj.NumAxes;

            % Get existing valid axes
            oldAxes = obj.Axes;
            isInvalid = ~isvalid(oldAxes);
            oldAxes(isInvalid) = [];
            oldNumAxes = numel(oldAxes);

            % Remove old axes from the tiled layout
            set(oldAxes, "Parent", []);

            % Update the TiledLayout size
            obj.TiledLayout.GridSize = [newNumAxes 1];

            % Get existing legends
            oldLegend = obj.Legend;
            isInvalid = ~isvalid(oldLegend);
            oldLegend(isInvalid) = [];
            oldNumLegend = numel(oldLegend);
            assert(oldNumAxes == oldNumLegend, ...
                "Internal Error. Number of legends did not match number of axes.")

            % Do we need to add or delete?
            if newNumAxes < oldNumAxes
                % Need to delete extra axes

                % Prepare new lists
                newAxes = oldAxes(1:newNumAxes);
                newLegend = oldLegend(1:newNumAxes);

                % Delete old ones
                removeAxes = oldAxes((newNumAxes+1) : end);
                delete(removeAxes)

                % Put new axes back in the tiled layout
                set(newAxes, "Parent", obj.TiledLayout);
                %                 for axIdx = 1:newNumAxes
                %                     newAxes

            else
                % Need to add new axes

                % Put old axes back in the tiled layout
                set(oldAxes, "Parent", obj.TiledLayout);

                % Preallocate
                newAxes = gobjects(1, newNumAxes);
                newAxes(1:oldNumAxes) = oldAxes;

                newLegend = gobjects(1, newNumAxes);
                newLegend(1:oldNumAxes) = oldLegend;

                % Get modes
                if oldNumAxes > 0
                    currentInterpreter = obj.Interpreter;
                    currentShowLegend = obj.ShowLegend;
                else
                    currentInterpreter = "none";
                    currentShowLegend = false;
                end

                % Add more axes
                for axIdx = (oldNumAxes+1) : newNumAxes
                    
                    ax = nexttile(obj.TiledLayout);
                    ax.NextPlot = "add";
                    ax.XAxis = matlab.graphics.axis.decorator.DurationRuler();
                    ax.XAxis.TickLabelInterpreter = currentInterpreter;
                    ax.YAxis.TickLabelInterpreter = currentInterpreter;
                    ax.Title.Interpreter = currentInterpreter;
                    ax.XLabel.Interpreter = currentInterpreter;
                    ax.YLabel.Interpreter = currentInterpreter;
                    ax.ZLimMode = "manual";

                    % Create the legend
                    lgnd = legend(ax,...
                        "Location","northwest",...
                        "Interpreter",currentInterpreter,...
                        "Visible",currentShowLegend);

                    newAxes(axIdx) = ax;
                    newLegend(axIdx) = lgnd;

                end %for

            end %if

            % Were there multiple axes?
            if newNumAxes > 1

                % Remove X tick labels for all but last axes
                set(newAxes(1:end-1), "XTickLabel", {});

                % Link all the axes in X
                try
                    linkaxes(newAxes, 'x');
                catch err
                    warning("wt:abstract:BaseMultiAxesTimeChart:LinkAxesError",...
                        "Unable to link axes: %s", err.message);
                end

            end %if

            % Store new objects
            obj.Axes = newAxes;
            obj.Legend = newLegend;

            % Set bound properties
            obj.BoundAxes = obj.Axes;
            obj.BoundLegend = obj.Legend;

        end %function


        function update(obj)
            % Update the underlying components

            disp('updated');

        end %function


        function requestUpdate(obj)
            % Request update method to run

            % Trigger set of a UsedInUpdate property to request update
            % during next drawnow. (for optimal efficiency)
            obj.Dirty_ = ~obj.Dirty_;

        end %function

    end %methods


    %% Debugging Methods
    methods

        function forceUpdateChart(obj)
            % Forces update to run (For debugging only!)

            obj.update();

        end %function

    end %methods

end %classdef
