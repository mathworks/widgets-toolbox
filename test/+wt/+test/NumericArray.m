classdef NumericArray < wt.test.BaseWidgetTest
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

            fcn = @()wt.NumericArray(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);

            % Set callback
            testCase.Widget.ValueChangedFcn = @(s,e)onCallbackTriggered(testCase,e);

            % Default entries
            newValue = [1 2 3 4];
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);

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

            % Verify number of controls
            diag = "Expected number of edit fields to match number of elements in Value.";
            testCase.verifyNumElements(controls, numel(expValue), diag)

            % Verify values
            for idx = 1:numel(expValue)
                testCase.verifyEqual(controls(idx).Value, expValue(idx), ...
                    'AbsTol', 1e-5);
            end

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
            newValue = [1 2 3 4 5 6 7 8];
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);

            % Verify a value set
            newValue = [10 20 30];
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
            newValue = [1 10 1000];
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);

            % Toggle off inclusive at lower limit
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

            % Verify error when at non-inclusive limits
            newValue = [-10 -2];
            errId = "MATLAB:validators:mustBeInRange";
            testCase.verifySetPropertyError("Value", newValue, errId);

        end %function


        function testValuePropertyWithRestriction(testCase)

            % Configure widget
            restriction = wt.enum.ArrayRestriction.increasing;
            testCase.verifySetProperty("Restriction", restriction);

            % Verify a value set
            newValue = [1 10 1000];
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);

            % Verify error when failing restriction
            newValue = [3 1 5];
            errId = "MATLAB:expectedIncreasing";
            testCase.verifySetPropertyError("Value", newValue, errId);


            % Configure widget
            restriction = wt.enum.ArrayRestriction.none;
            testCase.verifySetProperty("Restriction", restriction);

            % Verify a value set
            newValue = [0 -1 -3];
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);

            % Configure widget
            restriction = wt.enum.ArrayRestriction.decreasing;
            testCase.verifySetProperty("Restriction", restriction);

            % Verify a value set
            newValue = [10 -5 -8];
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);

            % Verify error when failing restriction
            newValue = [10 20 30];
            errId = "MATLAB:expectedDecreasing";
            testCase.verifySetPropertyError("Value", newValue, errId);

        end %function


        function testValueFields(testCase)

            % Get the controls
            controls = testCase.Widget.EditField;

            % Enter a valid value
            testCase.type(controls(4), 6);
            testCase.verifyValueProperty([1 2 3 6])

            % Enter a valid value
            testCase.type(controls(2), 3);
            testCase.verifyValueProperty([1 3 3 6])

            % Enter a valid value
            testCase.type(controls(1), -10);
            testCase.verifyValueProperty([-10 3 3 6])

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(3)

        end %function


        function testValueFieldsWithLimits(testCase)

            % Get the controls
            controls = testCase.Widget.EditField;

            % Configure widget
            testCase.verifySetProperty("Limits", [0, 10]);

            % Enter a valid value
            testCase.type(controls(4), 6);
            testCase.verifyValueProperty([1 2 3 6])

            % Enter an invalid value that will be reverted
            testCase.type(controls(2), 11);
            testCase.verifyValueProperty([1 2 3 6])
            pause(1) % Give a moment for the error to disappear

            % Enter an invalid value that will be reverted
            testCase.type(controls(1), -1);
            testCase.verifyValueProperty([1 2 3 6])
            pause(1) % Give a moment for the error to disappear

            % Enter a valid value
            testCase.type(controls(1), 10);
            testCase.verifyValueProperty([10 2 3 6])

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(2)

        end %function


        function testValueFieldsWithIncreasingRestriction(testCase)

            % Get the controls
            controls = testCase.Widget.EditField;

            % Enter a valid value
            testCase.type(controls(4), 6);
            testCase.verifyValueProperty([1 2 3 6])

            % Enter a valid value
            testCase.type(controls(2), 3);
            testCase.verifyValueProperty([1 3 3 6])

            % Enter a valid value
            testCase.type(controls(2), 2);
            testCase.verifyValueProperty([1 2 3 6])

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(3)


            % Configure widget restriction
            restriction = wt.enum.ArrayRestriction.increasing;
            testCase.verifySetProperty("Restriction", restriction);

            % Enter an invalid value that will be reverted
            testCase.type(controls(2), 3);
            testCase.verifyValueProperty([1 2 3 6])
            pause(1) % Give a moment for the error to disappear

            % Enter an invalid value that will be reverted
            testCase.type(controls(4), -1);
            testCase.verifyValueProperty([1 2 3 6])
            pause(1) % Give a moment for the error to disappear

            % Enter a valid value
            testCase.type(controls(1), -10);
            testCase.verifyValueProperty([-10 2 3 6])

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(4)

        end %function


        function testValueFieldsWithDecreasingRestriction(testCase)

            % Get the controls
            controls = testCase.Widget.EditField;

            % Configure widget restriction
            newValue = [-1 -2 -3 -4];
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);

            restriction = wt.enum.ArrayRestriction.decreasing;
            testCase.verifySetProperty("Restriction", restriction);

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(0)


            % Enter a valid value
            testCase.type(controls(4), -5);
            testCase.verifyValueProperty([-1 -2 -3 -5])

            % Enter an invalid value that will be reverted
            testCase.type(controls(1), -10);
            testCase.verifyValueProperty([-1 -2 -3 -5])
            pause(1) % Give a moment for the error to disappear

            % Enter an invalid value that will be reverted
            testCase.type(controls(4), 22);
            testCase.verifyValueProperty([-1 -2 -3 -5])
            pause(1) % Give a moment for the error to disappear

            % Enter a valid value
            testCase.type(controls(4), -10);
            testCase.verifyValueProperty([-1 -2 -3 -10])

            % Enter a valid value
            testCase.type(controls(3), -8);
            testCase.verifyValueProperty([-1 -2 -8 -10])

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(3)

        end %function

    end %methods (Test)
end %classdef

