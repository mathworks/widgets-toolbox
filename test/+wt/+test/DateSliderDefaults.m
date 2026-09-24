classdef DateSliderDefaults < matlab.unittest.TestCase
    % Verify default date slider configuration.

%   Copyright 2026 The MathWorks, Inc.

    methods (Test)

        function testDateSliderDefaults(testCase)

            widget = testCase.createWidget(@wt.DateSlider);
            expLimits = testCase.getExpectedLimits(widget);
            expSliderLimits = [0 days(diff(expLimits))] + 1;

            testCase.verifyEqual(widget.Position(3:4), [600 40])
            testCase.verifyEqual(widget.Limits, expLimits)
            testCase.verifyEqual(widget.Slider.Limits, expSliderLimits)
            testCase.verifyEqual(widget.Datepicker.Limits, expLimits)

        end %function

        function testDateRangeSliderDefaults(testCase)

            testCase.assumeFalse(isMATLABReleaseOlderThan("R2024b"), ...
                "Release not supported.")

            widget = testCase.createWidget(@wt.DateRangeSlider);
            expLimits = testCase.getExpectedLimits(widget);
            expSliderLimits = days([0 diff(expLimits)]) + 1;

            testCase.verifyEqual(widget.Position(3:4), [600 40])
            testCase.verifyEqual(widget.Limits, expLimits)
            testCase.verifyEqual(widget.Slider.Limits, expSliderLimits)
            testCase.verifyEqual(widget.DatepickerLeft.Limits(1), expLimits(1))
            testCase.verifyEqual(widget.DatepickerRight.Limits(2), expLimits(2))

        end %function

    end %methods

    methods (Access = private)

        function widget = createWidget(testCase, constructorFcn)

            fig = uifigure("Visible", "off");
            testCase.addTeardown(@()delete(fig));

            widget = verifyWarningFree(testCase, @()constructorFcn(fig));
            drawnow

        end %function

    end %methods

    methods (Static, Access = private)

        function expLimits = getExpectedLimits(widget)

            expLimits = datetime("01-Jan-2020") + calyears([0 1]);
            expLimits.Format = widget.Limits.Format;

        end %function

    end %methods

end %classdef
