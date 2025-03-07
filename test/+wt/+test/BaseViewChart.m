classdef BaseViewChart < wt.test.BaseWidgetTest
    % Implements unit tests for the chart class
%   Copyright 2025 The MathWorks Inc.

    
    
    %% Unit Tests
    methods (Test)

        function testBaseAppBasicCase(testCase)
            % Verifies behavior of the most basic BaseApp class

            % Launch the app
            diag = "Expected BasicBaseViewChart to launch without warnings.";
            fcn = @()wt.test.charts.BasicBaseViewChart(testCase.Grid);
            testCase.Widget = testCase.verifyWarningFree(fcn, diag);

            % Verify app and component creation
            diag = "Expected BasicBaseViewChart axes to be populated.";
            testCase.verifyNotEmpty(testCase.Widget.Axes, diag)

            diag = "Expected BasicBaseViewChart legend to be populated.";
            testCase.verifyNotEmpty(testCase.Widget.Legend, diag)

            % Verify update was run
            diag = "Expected data to be populated on Line(s) in the update method.";
            testCase.verifyNotEmpty(testCase.Widget.Line(1).XData, diag);
            testCase.verifyNotEmpty(testCase.Widget.Line(1).YData, diag);

        end %function
        
    end %methods (Test)
    
end %classdef