classdef RangeField < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component

    % Copyright 2025 The MathWorks, Inc.

    %% Class Setup
    methods (TestClassSetup)

        function createFigure(testCase)

            % Call superclass method
            testCase.createFigure@wt.test.BaseWidgetTest();

            % Set up a grid layout
            numRows = 10;
            rowHeight = 30;
            testCase.Grid.RowHeight = repmat({rowHeight},1,numRows);

        end %function

    end %methods


    %% Test Method Setup
    methods (TestMethodSetup)

        function setup(testCase)

            fcn = @()wt.RangeField(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);

            % Set callback
            testCase.Widget.ValueChangedFcn = @(s,e)onCallbackTriggered(testCase,e);

            % Ensure it renders
            drawnow

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(0)

        end %function

    end %methods


    %% Helper methods
    methods (Access = private)

        function verifyControlValues(testCase, expValue)
            % Verifies the control fields have the specified value

            % Ensure rendering is complete
            drawnow

            % Get the controls
            controls = testCase.Widget.EditField;

            % Verify values
            testCase.verifyEqual(controls(1).Value, expValue(1), 'AbsTol', 1e-5);
            testCase.verifyEqual(controls(2).Value, expValue(2), 'AbsTol', 1e-5);

        end %function


        function verifyValueProperty(testCase, expValue)
            % Verifies the Value property has the specified value

            import matlab.unittest.constraints.Eventually
            import matlab.unittest.constraints.IsEqualTo

            % Set the constraint
            constraint = Eventually(IsEqualTo(expValue), "WithTimeoutOf", 5);

            % Verify values
            testCase.verifyThat(@()testCase.Widget.Value, constraint);

        end %function

    end % methods


    %% Unit Tests
    methods (Test)

        function testValueProperty(testCase)

            % Verify a value set
            newValue = [0 10];
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);

            % Verify a value set
            newValue = [20 30];
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);

            % Verify a value set
            newValue = [-25 17];
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(0)

        end %function


        function testValuePropertyWithLimits(testCase)

            % Configure widget
            testCase.verifySetProperty("Limits", [0, inf]);

            % Verify a value set
            newValue = [0 10];
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);

            % Toggle off inclusive at lower limit
            newValue = [1 10];
            testCase.verifySetProperty("Value", newValue);
            testCase.verifySetProperty("LowerLimitInclusive", false);

            % Verify a value set
            newValue = [0.1 inf];
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);

            % Verify error when outside limits
            newValue = [-10 inf];
            errId = "MATLAB:validators:mustBeInRange";
            testCase.verifySetPropertyError("Value", newValue, errId);

            % Toggle off inclusive at both limits
            testCase.verifySetProperty("Limits", [-inf, inf]);
            newValue = [-9 -1];
            testCase.verifySetProperty("Value", newValue);
            testCase.verifySetProperty("Limits", [-10, 0]);
            testCase.verifySetProperty("LowerLimitInclusive", false);
            testCase.verifySetProperty("UpperLimitInclusive", false);

            % Verify a value set
            newValue = [-8 -3];
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);

            % Verify error when at non-inclusive limits
            newValue = [-8 0];
            errId = "MATLAB:validators:mustBeInRange";
            testCase.verifySetPropertyError("Value", newValue, errId);

        end %function


        function testValueFields(testCase)

            % Get the controls
            controls = testCase.Widget.EditField;

            % Enter a valid value
            testCase.type(controls(2), 6);
            testCase.verifyValueProperty([0 6])

            % Enter a valid value
            testCase.type(controls(1), 3);
            testCase.verifyValueProperty([3 6])

            % Enter a valid value
            testCase.type(controls(1), -10);
            testCase.verifyValueProperty([-10 6])

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(3)

        end %function


        function testValueFieldsWithLimits(testCase)

            % Get the controls
            controls = testCase.Widget.EditField;

            % Configure widget
            testCase.verifySetProperty("Limits", [0, 10]);

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(0)

            % Enter a valid value
            testCase.type(controls(2), 6);
            testCase.verifyValueProperty([0 6])

            % Enter an invalid value that will be reverted
            testCase.type(controls(2), 11);
            testCase.verifyValueProperty([0 6])
            pause(1) % Give a moment for the error to disappear

            % Enter an invalid value that will be reverted
            testCase.type(controls(1), -1);
            testCase.verifyValueProperty([0 6])
            pause(1) % Give a moment for the error to disappear

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(1)


            % Enter a valid value
            testCase.type(controls(1), 1);
            testCase.verifyValueProperty([1 6])

            % Enter a valid value
            testCase.type(controls(1), 0);
            testCase.verifyValueProperty([0 6])


            % Verify number of callbacks so far
            testCase.verifyCallbackCount(3)


            % Toggle off inclusive at both limits
            newValue = [1 9];
            testCase.verifySetProperty("Value", newValue);
            testCase.verifySetProperty("Limits", [0, 10]);
            testCase.verifySetProperty("LowerLimitInclusive", false);
            testCase.verifySetProperty("UpperLimitInclusive", false);

            % Enter an invalid value that will be reverted
            testCase.type(controls(1), 0);
            testCase.verifyValueProperty([1 9])
            pause(1) % Give a moment for the error to disappear

            % Enter a valid value
            testCase.type(controls(1), 0.1);
            testCase.verifyValueProperty([0.1 9])

            % Enter an invalid value that will be reverted
            testCase.type(controls(2), 10);
            testCase.verifyValueProperty([0.1 9])
            % pause(1) % Give a moment for the error to disappear

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(4)

        end %function

    end %methods (Test)

end %classdef

