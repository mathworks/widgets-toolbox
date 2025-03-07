classdef ListSelector < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
%   Copyright 2020-2025 The MathWorks Inc.
    
    %% Properties
    properties
        ItemNames = "TestItem" + string(1:5);
        ItemData = "TestData" + string(1:5);
    end
    
    
    %% Class Setup
    methods (TestClassSetup)
        
        function createFigure(testCase)
            
            % Start with superclass
            testCase.createFigure@wt.test.BaseWidgetTest();
            
            % Adjust grid size
            testCase.Figure.Position(3:4) = [500 700];
            testCase.Grid.RowHeight = repmat({175},1,3);
            testCase.Grid.ColumnWidth = {'1x','1x','1x'};

        end %function
        
    end %methods
    
    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            fcn = @()wt.ListSelector(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            drawnow
            
            % Set the initial items
            testCase.verifySetProperty("Items", testCase.ItemNames);
            
        end %function
        
    end %methods
    
    
    %% Unit Test
    methods (Test)
            
        function testProgrammaticItemsValueSelection(testCase)
            
            % Get the listbox
            listControl = testCase.Widget.ListBox;
            
            % List should still be empty
            testCase.verifyEmpty( listControl.Items );
            
            % Set the value
            newSelIdx = [2 5];
            newValue = testCase.ItemNames(newSelIdx);
            testCase.verifySetProperty("Value", newValue);
            
            % List and selection should now match value
            testCase.verifyEqual(string(listControl.Items), newValue);
            testCase.verifyEqual(listControl.ItemsData, newSelIdx);
            testCase.verifyEqual(testCase.Widget.SelectedIndex, newSelIdx);
            
        end %function
            
        
        function testProgrammaticItemsDataValueSelection(testCase)
            
            % Get the listbox
            listControl = testCase.Widget.ListBox;
            
            % Set the items data
            testCase.verifySetProperty("ItemsData", testCase.ItemData );
            
            % List should still be empty
            testCase.verifyEmpty( listControl.Items );
            
            % Set the value
            newSelIdx = [2 5];
            newValue = testCase.ItemData(newSelIdx);
            testCase.verifySetProperty("Value", newValue);
            
            % List and selection should now match value
            testCase.verifyEqual(string(listControl.Items), testCase.ItemNames(newSelIdx));
            testCase.verifyEqual(listControl.ItemsData, newSelIdx);
            testCase.verifyEqual(testCase.Widget.SelectedIndex, newSelIdx);
            
        end %function
        
            
        
        function testHighlightedValue(testCase)
            
            % Get the listbox
            listControl = testCase.Widget.ListBox;
            
            % Add items to the list
            newSelIdx = [1 2 4];
            newValue = testCase.ItemNames(newSelIdx);
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyEqual(testCase.Widget.SelectedIndex, newSelIdx);
            
            % Highlight a value in the list
            newHiliteIdx = [1 4];
            newHilite = testCase.ItemNames(newHiliteIdx);
            testCase.verifySetProperty("HighlightedValue", newHilite);
            
            % List selection highlight should match
            testCase.verifyEqual(listControl.Value, newHiliteIdx);
            
        end %function
        
        
            
        function testInteractiveSelection(testCase)
            
            % Get the listbox
            listControl = testCase.Widget.ListBox;
            
            % Add items to the list
            newSelIdx = [1 2 4];
            newValue = testCase.ItemNames(newSelIdx);
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyEqual(testCase.Widget.SelectedIndex, newSelIdx);
            
            % Select first item with mouse
            testCase.choose(listControl, 1)
            
            % List selection highlight should match
            testCase.verifyEqual(testCase.Widget.HighlightedValue, newValue(1));
            testCase.verifyEqual(listControl.Value, newSelIdx(1));
            
            % Select first item with mouse
            testCase.choose(listControl, [1 3])
            
            % List selection highlight should match
            testCase.verifyEqual(testCase.Widget.HighlightedValue, newValue([1 3]));
            testCase.verifyEqual(listControl.Value, newSelIdx([1 3]));
            
            
        end %function
        
        
            
        function testButtonEnables(testCase)
            
            % Get the listbox and button grid
            listControl = testCase.Widget.ListBox;
            buttonGrid = testCase.Widget.ListButtons;
            
            % Check button enables
            actValue = logical(buttonGrid.ButtonEnable);
            expValue = [true false false false];
            testCase.verifyEqual(actValue, expValue);
            
            % Now, add all items to the selected list
            testCase.verifySetProperty("Value", testCase.ItemNames);
            
            % Check button enables
            testCase.verifyEquality(buttonGrid.ButtonEnable, [0 0 0 0]);
            
            % Select first item with mouse
            testCase.choose(listControl, 1)
            
            % List selection highlight should match
            testCase.verifyEqual(testCase.Widget.HighlightedValue, testCase.ItemNames(1));
            testCase.verifyEqual(listControl.Value, 1);
            
            % Check button enables
            testCase.verifyEquality(buttonGrid.ButtonEnable, [0 1 0 1]);
            
            % Select last item with mouse
            lastIdx = numel(testCase.ItemNames);
            testCase.choose(listControl, lastIdx)
            
            % List selection highlight should match
            testCase.verifyEqual(testCase.Widget.HighlightedValue, testCase.ItemNames(lastIdx));
            testCase.verifyEqual(listControl.Value, lastIdx);
            
            % Check button enables
            testCase.verifyEquality(buttonGrid.ButtonEnable, [0 1 1 0]);
            
            % Select multiple items with mouse
            selIdx = [2 3];
            testCase.choose(listControl, selIdx)
            
            % List selection highlight should match
            testCase.verifyEqual(testCase.Widget.HighlightedValue, testCase.ItemNames(selIdx));
            testCase.verifyEqual(listControl.Value, selIdx);
            
            % Check button enables
            testCase.verifyEquality(buttonGrid.ButtonEnable, [0 1 1 1]);
            
            % Now, enable adding duplicates to the list
            testCase.verifySetProperty("AllowDuplicates", true);
            
            % Check button enables
            testCase.verifyEquality(buttonGrid.ButtonEnable(2:4), [1 1 1]);
            
        end %function
        
        
            
        function testButtonFunctions(testCase)
            
            % Get the listbox and button grid
            w = testCase.Widget;
            listControl = testCase.Widget.ListBox;
            buttonGrid = testCase.Widget.ListButtons;
            button = buttonGrid.Button;
            
            % Add a list of items and put all on list
            testCase.verifySetProperty("Value", testCase.ItemNames);
            
            % Select multiple items with mouse
            selIdx = [2 3];
            testCase.choose(listControl, selIdx)
            
            % Check button enables
            testCase.verifyEquality(buttonGrid.ButtonEnable, [0 1 1 1]);
            
            % Move items up
            testCase.press(button(3))
            
            % Give a moment for update to run
            drawnow
            
            % Verify new order
            newIdx = [2 3 1 4 5];
            testCase.verifyEqual(w.Value, testCase.ItemNames(newIdx));
            testCase.verifyEqual(w.SelectedIndex, newIdx);
            
            % Verify button enables
            testCase.verifyEquality(buttonGrid.ButtonEnable, [0 1 0 1]);
            
            % Move items down
            testCase.press(button(4))
            
            % Give a moment for update to run
            drawnow
            
            % Verify new order
            newIdx = 1:5;
            testCase.verifyEqual(w.Value, testCase.ItemNames(newIdx));
            testCase.verifyEqual(w.SelectedIndex, newIdx);
            
            % Verify button enables
            testCase.verifyEquality(buttonGrid.ButtonEnable, [0 1 1 1]);
            
            % Delete items
            testCase.press(button(2))
            
            % Give a moment for update to run
            drawnow
            
            % Verify new order
            newIdx = [1 4 5];
            testCase.verifyEqual(w.Value, testCase.ItemNames(newIdx));
            testCase.verifyEqual(w.SelectedIndex, newIdx);
            
            % Verify new highlight
            testCase.verifyEqual(w.HighlightedValue, testCase.ItemNames(1));
           
            % Verify button enables
            testCase.verifyEquality(buttonGrid.ButtonEnable(2:4), [1 0 1]);
            
        end %function
        
        
            
        function testUserButtons(testCase)
            
            % Get the widget
            w = testCase.Widget;
            
            % Add User buttons
            w.UserButtons.Icon = ["plot_24.png","play_24.png"];
            drawnow            
            
            % Press the buttons
            b = w.UserButtons.Button;
            testCase.verifyNumElements(b, 2);
            testCase.press(b(1))
            testCase.press(b(2))
            
        end %function
        
        
            
        function testStyleProperties(testCase)
            
            % Set ButtonWidth
            testCase.verifySetProperty("ButtonWidth", 40);
            
            % Set ButtonWidth
            testCase.verifySetProperty("FontSize", 20);
            
            % Set Enable
            testCase.verifySetProperty("Enable", "off");
            
        end %function
        
    end %methods (Test)
    
end %classdef