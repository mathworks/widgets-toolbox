classdef BaseTimeAlignedChart < wt.test.BaseWidgetTest
    % Tests for wt.abstract.BaseTimeAlignedChart.

    % Copyright 2026 The MathWorks, Inc.

    methods (TestMethodSetup)
        function setup(testCase)

            fcn = @()wt.abstract.BaseTimeAlignedChart(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase, fcn);
            drawnow

        end
    end

    methods (TestMethodTeardown)
        function deleteChart(testCase)

            if ~isempty(testCase.Widget) && isvalid(testCase.Widget)
                delete(testCase.Widget)
            end

        end
    end

    methods (Test)
        function testDefaultAxesCreation(testCase)

            chart = testCase.Widget;

            testCase.verifyNumElements(chart.Axes, 1)
            testCase.verifyEqual(chart.TiledLayout.GridSize, [1 1])
            testCase.verifyEqual(string(chart.Axes.XGrid), "on")
            testCase.verifyEqual(string(chart.Axes.YGrid), "on")

        end

        function testNumAxesRecreatesLayout(testCase)

            chart = testCase.Widget;

            chart.NumAxes = 3;
            drawnow

            testCase.verifyNumElements(chart.Axes, 3)
            testCase.verifyEqual(chart.TiledLayout.GridSize, [3 1])

        end

        function testForceUpdateAfterNumAxesChange(testCase)

            chart = testCase.Widget;

            chart.NumAxes = 2;
            fcn = @()chart.forceUpdateChart();

            testCase.verifyWarningFree(fcn)
            testCase.verifyNumElements(chart.Axes, 2)
            testCase.verifyEqual(chart.TiledLayout.GridSize, [2 1])

        end

        function testLabelsGridAndLegendState(testCase)

            chart = testCase.Widget;

            chart.NumAxes = 2;
            chart.ShowLegend = true;
            chart.XLabel = ["Elapsed"; "Elapsed"];
            chart.YLabel = ["Top"; "Bottom"];
            chart.Title = ["Upper Signal"; "Lower Signal"];
            chart.GroupTitle = "Aligned Signals";
            chart.ShowGrid = false;
            drawnow

            testCase.verifyNumElements(chart.Legend, 2)
            testCase.verifyEqual(string(chart.Axes(1).XLabel.String), "Elapsed")
            testCase.verifyEqual(string(chart.Axes(2).YLabel.String), "Bottom")
            testCase.verifyEqual(string(chart.Axes(1).Title.String), "Upper Signal")
            testCase.verifyEqual(string(chart.TiledLayout.Title.String), ...
                "Aligned Signals")
            testCase.verifyEqual(string({chart.Axes.XGrid}), ["off" "off"])
            testCase.verifyEqual(string({chart.Axes.YGrid}), ["off" "off"])

        end

        function testYLimitDependentProperties(testCase)

            chart = testCase.Widget;

            chart.NumAxes = 2;
            drawnow
            chart.YLim = {[-1 1]; [10 20]};
            chart.YLimMode = ["manual"; "manual"];

            testCase.verifyEqual(chart.YLim, {[-1 1]; [10 20]})
            testCase.verifyEqual(chart.YLimMode, ["manual"; "manual"])

        end

        function testSelectedAxesColor(testCase)

            chart = testCase.Widget;

            chart.NumAxes = 2;
            drawnow
            chart.EnableSelection = true;
            chart.AxesColor = [1 1 1];
            chart.AxesSelectedColor = [0.3 0.4 0.5];
            chart.SelectedAxes = 2;
            chart.forceUpdateChart();

            testCase.verifyEqual(chart.Axes(1).Color, [1 1 1], ...
                "AbsTol", 1e-12)
            testCase.verifyEqual(chart.Axes(2).Color, [0.3 0.4 0.5], ...
                "AbsTol", 1e-12)

            chart.SelectedAxes = 1;
            chart.forceUpdateChart();

            testCase.verifyEqual(chart.Axes(1).Color, [0.3 0.4 0.5], ...
                "AbsTol", 1e-12)
            testCase.verifyEqual(chart.Axes(2).Color, [1 1 1], ...
                "AbsTol", 1e-12)

        end
    end

end
