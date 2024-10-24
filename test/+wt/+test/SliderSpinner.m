classdef SliderSpinner < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
    % Copyright 2020-2024 The MathWorks, Inc.

    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            fcn = @()wt.SliderSpinner(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            
            % Set callback
            testCase.Widget.ValueChangedFcn = @(s,e)onCallbackTriggered(testCase,e);
            
            % Ensure it renders
            drawnow
            
        end %function
        
    end %methods
    
    
    %% Helper methods
    methods (Access = private)
        
        function verifyControlValues(testCase,value,absTol)
            % Verifies the control fields have the specified value

            arguments
                testCase
                value (1,1) double
                absTol (1,1) double = 0
            end
            
            drawnow
            testCase.verifyEqual(testCase.Widget.Spinner.Value, value, 'AbsTol', absTol);
            testCase.verifyEqual(testCase.Widget.Slider.Value, value, 'AbsTol', absTol);
            
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
            testCase.verifyControlValues(expValue, 0.1);
            
            % Configure the control
            testCase.verifySetProperty("RoundFractionalValues", "off");
            
            % Set the value
            newValue = 22.45;
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue, 0.1);
            
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
            
            % Verify callback triggered
            testCase.verifyEqual(testCase.CallbackCount, 1)
            
            % Type an invalid value
            newValue = 398;
            expValue = 1;
            testCase.verifyTypeAction(spinnerControl, newValue, "Value", expValue);
            
            % If continuing in this test, need a pause(1) to wait for error
            % flag to disappear!
            
            % Verify callback did not trigger on invalid!
            testCase.verifyEqual(testCase.CallbackCount, 1)
            
        end %function
        
        
        function testSpinnerButtons(testCase)
            
            % Get the control
            spinnerControl = testCase.Widget.Spinner;
            
            % Click the spinner buttons
            expValue = 1;
            testCase.press(spinnerControl,'up');
            testCase.verifyControlValues(expValue);
            testCase.verifyEqual(testCase.Widget.Value, expValue);
            
            % Verify callback triggered
            testCase.verifyEqual(testCase.CallbackCount, 1)
           
            
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
            testCase.verifyControlValues(expValue, 0.1);
            testCase.verifyEqual(testCase.Widget.Value, expValue, 'AbsTol', 0.1);
            
            % Verify callback triggered
            testCase.verifyEqual(testCase.CallbackCount, 1)
            
            
            % Drag the slider
            startValue = 0;
            newValue = 32;
            expValue = 32;
            testCase.drag(sliderControl,startValue,newValue);
            testCase.verifyControlValues(expValue, 0.2);
            testCase.verifyEqual(testCase.Widget.Value, expValue);
            
            % Drag the slider to a fraction (with rounding turned on)
            startValue = 32;
            newValue = 13.8;
            expValue = 14;
            testCase.drag(sliderControl,startValue,newValue);
            testCase.verifyControlValues(expValue);
            testCase.verifyEqual(testCase.Widget.Value, expValue);
            
            % Configure the control
            testCase.verifySetProperty("RoundFractionalValues", "off");
            
            % Drag the slider to a fraction (with rounding turned off)
            % Verify it did not get rounded
            startValue = 14;
            newValue = 91.24;
            notExpValue = 90;
            testCase.drag(sliderControl,startValue,newValue);
            drawnow
            testCase.verifyNotEqual(testCase.Widget.Spinner.Value, notExpValue);
            testCase.verifyNotEqual(testCase.Widget.Slider.Value, notExpValue);
            testCase.verifyNotEqual(testCase.Widget.Value, notExpValue);
            
        end %function
        
    end %methods (Test)
    
end %classdef