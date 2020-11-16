classdef SliderSpinner < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
    % Copyright 2020 The MathWorks, Inc.
    
    
    %% Class Setup
    methods (TestClassSetup)
        
        function createFigure(testCase)
            
            % Call superclass method
            testCase.createFigure@wt.test.BaseWidgetTest();
            
            % Modify the grid row height
            numRows = 8;
            rowHeight = 40;
            testCase.Grid.RowHeight = repmat({rowHeight},1,numRows);

        end %function
        
    end %methods
    
    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            fcn = @()wt.SliderSpinner(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            drawnow
            
        end %function
        
    end %methods
    
    
    %% Helper methods
    methods (Access = private)
        
        function verifyControlValues(testCase,value)
            % Verifies the control fields have the specified value
            
            drawnow
            testCase.verifyEqual(testCase.Widget.Spinner.Value, value);
            testCase.verifyEqual(testCase.Widget.Slider.Value, value, 'AbsTol', 1e-5);
            
        end %function
        
    end % methods
    
    
    %% Unit Tests
    methods (Test)
            
        function testValueProperty(testCase)
            
            % Set the value
            newValue = 15;
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);
            
            % Set the value
            newValue = 77;
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);
            
        end %function
        
            
        function testFractionalValues(testCase)
            
            % Configure the control
            testCase.verifySetProperty("RoundFractionalValues", "on");
            
            % Set the value
            expValue = 15;
            newValue = 15.3;
            testCase.verifySetProperty("Value", newValue, expValue);
            testCase.verifyControlValues(expValue);
            
            % Configure the control
            testCase.verifySetProperty("RoundFractionalValues", "off");
            
            % Set the value
            newValue = 22.45;
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);
            
        end %function
        
            
        function testValueBoundaries(testCase)
            
            % Configure the control
            testCase.verifySetProperty("Limits", [-3 15]);
            
            % Set the value
            newValue = 3;
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);
            
            % Set an invalid value
            newValue = 22;
            expValue = 3;
            testCase.verifySetPropertyError("Value", newValue, 'MATLAB:ui:Spinner:invalidValue');
            testCase.verifyControlValues(expValue);
            
            % Set an invalid value
            newValue = -100;
            expValue = 3;
            testCase.verifySetPropertyError("Value", newValue, 'MATLAB:ui:Spinner:invalidValue');
            testCase.verifyControlValues(expValue);
            
        end %function
        
        
        function testSpinnerEdit(testCase)
            
            % Get the control
            spinnerControl = testCase.Widget.Spinner;
            
            % Type a valid value
            newValue = 1;
            expValue = 1;
            testCase.verifyTypeAction(spinnerControl, newValue, "Value", expValue);
            
            % Type an invalid value
            newValue = 398;
            expValue = 1;
            testCase.verifyTypeAction(spinnerControl, newValue, "Value", expValue);
            
            % If continuing in this test, need a pause(1) to wait for error
            % flag to disappear!
            
        end %function
        
        
        function testSpinnerButtons(testCase)
            
            % Get the control
            spinnerControl = testCase.Widget.Spinner;
            
            % Click the spinner buttons
            expValue = 1;
            testCase.press(spinnerControl,'up');
            testCase.verifyControlValues(expValue);
            testCase.verifyEqual(testCase.Widget.Value, expValue);
            
            % Click the spinner buttons
            expValue = 0;
            testCase.press(spinnerControl,'down');
            testCase.press(spinnerControl,'down');
            testCase.verifyControlValues(expValue);
            testCase.verifyEqual(testCase.Widget.Value, expValue);
            
            % Test the boundaries
            expValue = 0;
            testCase.press(spinnerControl,'down');
            testCase.verifyControlValues(expValue);
            testCase.verifyEqual(testCase.Widget.Value, expValue);
            
            % Test the boundaries
            expValue = 50;
            testCase.verifySetProperty("Limits", [0 50]);
            testCase.verifySetProperty("Value", 49);
            testCase.press(spinnerControl,'up');
            testCase.press(spinnerControl,'up');
            testCase.verifyControlValues(expValue);
            testCase.verifyEqual(testCase.Widget.Value, expValue);
            
        end %function
        
        
        function testSlider(testCase)
            
            % Get the control
            sliderControl = testCase.Widget.Slider;
            
            % Configure the control
            testCase.verifySetProperty("RoundFractionalValues", "on");
            
            % Click the slider
            newValue = 74;
            expValue = 74;
            testCase.choose(sliderControl,newValue);
            testCase.verifyControlValues(expValue);
            testCase.verifyEqual(testCase.Widget.Value, expValue);
            
            % Drag the slider
            newValue = 32;
            expValue = 32;
            testCase.drag(sliderControl,0,newValue);
            testCase.verifyControlValues(expValue);
            testCase.verifyEqual(testCase.Widget.Value, expValue);
            
            % Drag the slider to a fraction (with rounding on)
            newValue = 13.65;
            expValue = 14;
            testCase.drag(sliderControl,32,newValue);
            testCase.verifyControlValues(expValue);
            testCase.verifyEqual(testCase.Widget.Value, expValue);
            
            
            %RAJ - debugging:
            testCase.choose(sliderControl, rand*100);
            obj.Slider.Value
            
            % Configure the control
            testCase.verifySetProperty("RoundFractionalValues", "off");
            
            % Drag the slider to a fraction (with rounding off)
            newValue = 91.24;
            expValue = 91.24;
            testCase.drag(sliderControl,14,newValue);
            testCase.verifyControlValues(expValue);
            testCase.verifyEqual(testCase.Widget.Value, expValue);
            
        end %function
        
    end %methods (Test)
    
end %classdef