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
            
        end %function

        
        function testLimits(testCase)
            
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

            % Verify error when outside limits
            newValue = [-8 0];
            errId = "MATLAB:validators:mustBeInRange";
            testCase.verifySetPropertyError("Value", newValue, errId);
            
        end %function
        
    end %methods (Test)
    
end %classdef

