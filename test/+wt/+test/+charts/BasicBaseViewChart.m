classdef BasicBaseViewChart < wt.abstract.BaseViewChart
     % Implements a chart
    

    %% Properties
    properties (AbortSet, SetObservable)

        % Model class containing the data for the View/Controller
        Model = wt.model.BaseModel.empty(0)

    end %properties


    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = protected)

        Line

    end %properties


    %% Protected Methods
    methods (Access = protected)

        function setup(obj)

            % Call superclass method
            obj.setup@wt.abstract.BaseViewChart();

            % Configure layout
            obj.TiledLayout.GridSize = [2 1];
            obj.TiledLayout.TileSpacing = 'loose';

            % Load Deflection
            obj.Axes = [
                nexttile(obj.TiledLayout)
                nexttile(obj.TiledLayout)
                ];

            % Lines
            obj.Line = [
                line(obj.Axes(1),nan,nan,"DisplayName","Line 1a")
                line(obj.Axes(2),nan,nan,"DisplayName","Line 2a")
                line(obj.Axes(2),nan,nan,"DisplayName","Line 2b")
                ];

            % Add legend
            obj.Legend = [
                legend(obj.Axes(1))
                legend(obj.Axes(2))
                ];

        end %function


        function update(obj)

            % Call superclass method first
            obj.update@wt.abstract.BaseViewChart();

            % Put some data on the charts
            obj.Line(1).XData = 1:10;
            obj.Line(1).YData = 1:10;
            obj.Line(2).XData = 1:100;
            obj.Line(2).YData = 1:100;
            obj.Line(3).XData = 1:100;
            obj.Line(3).YData = (1:100) / 2;

        end %function

    end %methods

end %classdef