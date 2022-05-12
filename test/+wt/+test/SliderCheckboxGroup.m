classdef SliderCheckboxGroup < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
    % Copyright 2020-2022 The MathWorks, Inc.
    
    
    
    %% Class Setup
    methods (TestClassSetup)
        
        function createFigure(testCase)
            
            % Call superclass method
            testCase.createFigure@wt.test.BaseWidgetTest();
            
            % Make the figure taller
            testCase.Figure.Position(4) = 600;
            
            % Modify the grid row height
            testCase.Grid.RowHeight = {'1x','1x','1x'};
            testCase.Grid.ColumnWidth = {'1x','1x','1x'};
            
        end %function
        
    end %methods
    
    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            fcn = @()wt.SliderCheckboxGroup(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);

            % Set for 4 sliders
            name = ["One", "Two", "Three", "Four"];
            testCase.verifySetProperty("Name", name);
            
            % Set callback
            testCase.Widget.ValueChangedFcn = @(s,e)onCallbackTriggered(testCase,e);
            
            % Ensure it renders
            drawnow
            
        end %function
        
    end %methods
    
    
    %% Unit Tests
    methods (Test)
            
        function testName(testCase)
            
            % Set the name
            name = ["Red", "Green", "Blue"];
            testCase.verifySetProperty("Name", name);
            
            % Verify value adapts
            numItems = numel(name);
            actVal = testCase.Widget.Value;
            expVal = ones(1, numItems);
            testCase.verifyEqual(actVal, expVal);
           
            % Verify the state adapts
            numItems = numel(name);
            actVal = testCase.Widget.State;
            expVal = true(1, numItems);
            testCase.verifyEqual(actVal, expVal);
            
            % Add more name
            name = "Item " + string(1:10);
            testCase.verifySetProperty("Name", name);
           
            % Verify the value adapts
            numItems = numel(name);
            actVal = testCase.Widget.Value;
            expVal = ones(1, numItems);
            testCase.verifyEqual(actVal, expVal);
           
            % Verify the state adapts
            numItems = numel(name);
            actVal = testCase.Widget.State;
            expVal = true(1, numItems);
            testCase.verifyEqual(actVal, expVal);
            
        end %function
        
            
        function testValue(testCase)
            
            % Get the slider and checkbox controls
            slider = testCase.Widget.Slider;
            cbox = testCase.Widget.Checkbox;
            numItems = numel(slider);
            
            % Change all slider values to zeros
            newValue = zeros(1, numItems);
            testCase.verifySetProperty("Value", newValue)
            testCase.verifyEqual([slider.Value], newValue)

            % Checkboxes are still on, despite sliders at zero
            expValue = true(1, numItems);
            testCase.verifyEqual([cbox.Value], expValue)
            
            % Change all values to 0.5
            newValue = 0.5 + zeros(1, numItems);
            testCase.verifySetProperty("Value", newValue)
            testCase.verifyEqual([slider.Value], newValue)
            
        end %function
        
            
        function testSliders(testCase)
            
            % Get the slider controls
            slider = testCase.Widget.Slider;

            % Adjust sliders
            testCase.drag(slider(1), 0, 0.1)
            testCase.drag(slider(2), 0, 0.2)
            testCase.drag(slider(3), 0, 0.3)
            testCase.drag(slider(4), 0, 0.4)
            drawnow

            % Verify state
            testCase.verifyEqual(testCase.Widget.Value, [.1 .2 .3 .4])
            testCase.verifyEqual([slider.Value], [.1 .2 .3 .4])
            
            % Verify callback fired (may be many times during drag)
            testCase.verifyGreaterThanOrEqual(testCase.CallbackCount, 4)

        end %function
        
            
        function testCheckbox(testCase)
            
            % Get the slider and checkbox controls
            slider = testCase.Widget.Slider;
            cbox = testCase.Widget.Checkbox;

            % Adjust sliders

            % Toggle a checkbox
            testCase.press(cbox(2))
            drawnow

            % Verify state
            testCase.verifyEqual([cbox.Value], [true false true true])
            testCase.verifyEqual(testCase.Widget.State, [true false true true])
            testCase.verifyEqual(testCase.Widget.Value, [.1 0 .3 .4])

            testCase.verifyTrue(slider(1).Enable)
            testCase.verifyFalse(slider(2).Enable)
            testCase.verifyTrue(slider(3).Enable)
            testCase.verifyTrue(slider(4).Enable)
            
            
        end %function
        
    end %methods (Test)
    
end %classdef