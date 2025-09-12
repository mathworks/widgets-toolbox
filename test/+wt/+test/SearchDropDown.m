classdef SearchDropDown < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
    %   Copyright 2025 The MathWorks Inc.

    %% Properties
    properties
        ItemNames = [
            "Voltage A"
            "Voltage B"
            "Current A"
            "Current B"
            "Power A"
            "Power B"
            ];
        ItemData = [
            11
            12
            21
            22
            31
            32
            ];
    end

    
    %% Class Setup
    methods (TestClassSetup)
        
        function createFigure(testCase)
            
            % Start with superclass
            testCase.createFigure@wt.test.BaseWidgetTest();
            
            % Adjust grid size
            testCase.Figure.Position(3:4) = [1200 700];
            testCase.Grid.RowHeight = repmat({'fit'},1,4);
            testCase.Grid.ColumnWidth = repmat({'1x'},1,6);
            
        end %function
        
    end %methods
    
    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            fcn = @()wt.SearchDropDown(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            drawnow
            
            % Set the initial items
            testCase.verifySetProperty("Items", testCase.ItemNames);

            % Verify empty default
            expValue = "";
            testCase.verifyPropertyValue(testCase.Widget, "Value", expValue)
            testCase.verifyPropertyValue(testCase.Widget.EditField, "Value", char(expValue))

            % Set callback
            testCase.Widget.ValueChangedFcn = @(s,e)onCallbackTriggered(testCase,e);
            
        end %function
        
    end %methods
    
    
    %% Unit Test
    methods (Test)

        function testValueProperty(testCase)

            % Get the component
            comp = testCase.Widget;

            % Set a value from the list
            expValue = testCase.ItemNames(3);
            testCase.Widget.Value = expValue;
            testCase.verifyPropertyValue(comp, "Value", expValue)
            testCase.verifyPropertyValue(comp.EditField, "Value", char(expValue))

            % Clear the value
            expValue = "";
            testCase.Widget.Value = expValue;
            testCase.verifyPropertyValue(comp, "Value", expValue)
            testCase.verifyPropertyValue(comp.EditField, "Value", char(expValue))

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(0)

        end %function

        

        function testInteractivePartialSearch(testCase)

            % Get the component
            comp = testCase.Widget;

            % Simulate typing to filter the dropdown items
            testCase.type(comp.EditField, "urren")
            testCase.verifyPropertyValue(comp.ListBox, "Items", cellstr(testCase.ItemNames(3:4)'));

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(1)

            % Ensure the listbox is showing
            % It might not be due to the nature of the type command
            comp.SearchPanel.Visible = true;

            % Simulate selecting the second item from the filtered list
            testCase.choose(comp.ListBox, 2);

            testCase.verifyPropertyValue(comp, "Value", testCase.ItemNames(4));
            testCase.verifyPropertyValue(comp.EditField, "Value", char(testCase.ItemNames(4)));

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(2)

            % Verify the list is no longer visible
            testCase.verifyNotVisible(comp.SearchPanel)

        end %function
        
    end %methods (Test)
    
end %classdef