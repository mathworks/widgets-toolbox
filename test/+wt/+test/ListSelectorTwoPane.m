classdef ListSelectorTwoPane < wt.test.BaseWidgetTest
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
            testCase.Figure.Position(3:4) = [700 800];
            testCase.Grid.RowHeight = repmat({175},1,4);
            testCase.Grid.ColumnWidth = {'1x','1x','1x'};

        end %function
        
    end %methods
    
    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            fcn = @()wt.ListSelectorTwoPane(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            drawnow
            
            % Set the initial items
            testCase.verifySetProperty("Items", testCase.ItemNames);
            
            % Set callback
            testCase.Widget.ButtonPushedFcn = @(s,e)onCallbackTriggered(testCase,e);
            testCase.Widget.ValueChangedFcn = @(s,e)onCallbackTriggered(testCase,e);
            testCase.Widget.HighlightedValueChangedFcn = @(s,e)onCallbackTriggered(testCase,e);
            
            % Ensure it renders
            drawnow
            
        end %function
        
    end %methods
    
    
    %% Unit Tests
    methods (Test)
            
        function testProgrammaticItemsValueSelection(testCase)
            
            % Get the RightList
            listControl = testCase.Widget.RightList;
            
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
            
            % Validate the left list items
            leftIdx = [1 3 4];
            leftList = testCase.Widget.LeftList;
            testCase.verifyEqual(string(leftList.Items), testCase.ItemNames(leftIdx));
            testCase.verifyEqual(leftList.ItemsData, leftIdx);
            
            % Verify callback did not fire
            testCase.verifyEqual(testCase.CallbackCount, 0);
            
        end %function
        
        
        function testProgrammaticItemsDataValueSelection(testCase)
            
            % Get the RightList
            listControl = testCase.Widget.RightList;
            
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
            
            % Validate the left list items
            leftIdx = [1 3 4];
            leftList = testCase.Widget.LeftList;
            testCase.verifyEqual(string(leftList.Items), testCase.ItemNames(leftIdx));
            testCase.verifyEqual(leftList.ItemsData, leftIdx);
            
            % Verify callback did not fire
            testCase.verifyEqual(testCase.CallbackCount, 0);
            
        end %function


        function testProgrammaticItemsAndItemsDataValueSelection(testCase)

            % Get the RightList
            listControl = testCase.Widget.RightList;
            
            % Set fewer items than items data
            testCase.verifySetProperty("Items", testCase.ItemNames(1:3) );
            testCase.verifySetProperty("ItemsData", testCase.ItemData );
            
            % List should still be empty
            testCase.verifyEmpty( listControl.Items );
            
            % Set the value outside of the current acceptable range
            newSelIdx = [2 5];
            newValue = testCase.ItemData(newSelIdx);
            testCase.verifyError(@() testCase.verifySetProperty("Value", newValue), ...
                "widgets:ListSelectorTwoPane:InvalidIndex");
            
            % Set the value inside range
            newSelIdx = [1 2];
            newValue = testCase.ItemData(newSelIdx);
            testCase.verifySetProperty("Value", newValue);

            % List and selection should now match value
            testCase.verifyEqual(string(listControl.Items), testCase.ItemNames(newSelIdx));
            testCase.verifyEqual(listControl.ItemsData, newSelIdx);
            testCase.verifyEqual(testCase.Widget.SelectedIndex, newSelIdx);
            
            % Validate the left list items
            leftIdx = 3;
            leftList = testCase.Widget.LeftList;
            testCase.verifyEqual(string(leftList.Items), testCase.ItemNames(leftIdx));
            testCase.verifyEqual(leftList.ItemsData, leftIdx);
            
            % Verify callback did not fire
            testCase.verifyEqual(testCase.CallbackCount, 0);
        end        
        
        
        function testHighlightedValue(testCase)
            
            % Get the RightList
            listControl = testCase.Widget.RightList;
            
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
            
            % Verify callback did not fire
            testCase.verifyEqual(testCase.CallbackCount, 0);
            
        end %function
        
        
            
        function testInteractiveSelection(testCase)
            
            % Get the RightList
            listControl = testCase.Widget.RightList;
            
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
            
            % Verify callbacks fired
            testCase.verifyEqual(testCase.CallbackCount, 2);
            
        end %function
        
            
        function testButtonEnables(testCase)
            
            % Get the RightList and button grid
            listControl = testCase.Widget.RightList;
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
            
            % Verify callbacks fired
            testCase.verifyEqual(testCase.CallbackCount, 4);
            
        end %function
        
            
        function testButtonFunctions(testCase)
            
            % Get the RightList and button grid
            w = testCase.Widget;
            listControl = testCase.Widget.RightList;
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
            
            % Validate the left list items
            leftIdx = [2 3];
            leftList = testCase.Widget.LeftList;
            testCase.verifyEqual(string(leftList.Items), testCase.ItemNames(leftIdx));
            testCase.verifyEqual(leftList.ItemsData, leftIdx);
            
            % Verify callbacks fired
            testCase.verifyEqual(testCase.CallbackCount, 5);
            
        end %function


        function testHighlightedSelectionChange(testCase)

            % Get the RightList and button grid
            w = testCase.Widget;
            leftlistControl = testCase.Widget.LeftList;
            rightListControl = testCase.Widget.RightList;
            buttonGrid = testCase.Widget.ListButtons;
            button = buttonGrid.Button;
            
            % Add a list of items and put all on list
            testCase.verifySetProperty("Value", testCase.ItemNames(1));
            
            % Select multiple items with mouse
            selIdx = [2 3];
            testCase.choose(leftlistControl, selIdx)
            
            % Check button enables
            testCase.verifyEquality(buttonGrid.ButtonEnable, [1 0 0 0]);
            
            % Move items to the right
            testCase.press(button(1))
            
            % Give a moment for update to run
            drawnow

            % Verify new order
            newIdx = [1 3 4];
            testCase.verifyEqual(w.Value, testCase.ItemNames(newIdx));
            testCase.verifyEqual(w.SelectedIndex, newIdx);

            % Verify highlighted values
            testCase.verifyEqual(w.HighlightedValue, testCase.ItemNames(newIdx(selIdx)));
            testCase.verifyEqual(w.LeftList.Value, 2);

            % Select item to deselect
            selIdx = 1;
            testCase.choose(rightListControl, selIdx)

            % Check button enables
            testCase.verifyEquality(buttonGrid.ButtonEnable, [1 1 0 1]);

            % Move items to the left
            testCase.press(button(2))

            % Verify new order
            newIdx = [3 4];
            testCase.verifyEqual(w.Value, testCase.ItemNames(newIdx));
            testCase.verifyEqual(w.SelectedIndex, newIdx);

            % Verify highlighted values
            testCase.verifyEqual(w.HighlightedValue, testCase.ItemNames(newIdx(1)));
            testCase.verifyEqual(w.LeftList.Value, 1);

            % Verify callbacks fired
            testCase.verifyEqual(testCase.CallbackCount, 3);

        end
        
        
        function testItemsChange(testCase)

            % Get the RightList and button grid
            w = testCase.Widget;
            leftlistControl = testCase.Widget.LeftList;
            buttonGrid = testCase.Widget.ListButtons;
            button = buttonGrid.Button;

            for idx = 1:numel(w.Items)

                % Select last item
                testCase.choose(leftlistControl, numel(w.Items) + 1 - idx)
            
                % Check button enables
                switch idx
                    case 1
                        testCase.verifyEquality(buttonGrid.ButtonEnable, [1 0 0 0]);
                    case 2
                        testCase.verifyEquality(buttonGrid.ButtonEnable, [1 1 0 0]);
                    otherwise
                        testCase.verifyEquality(buttonGrid.ButtonEnable, [1 1 1 0]);
                end
                
                % Move items to the right
                testCase.press(button(1))
                
                % Give a moment for update to run
                drawnow
            end

            % Check button enables
            testCase.verifyEquality(buttonGrid.ButtonEnable, [0 1 1 0]);

            % Verify new order
            newIdx = 5:-1:1;
            testCase.verifyEqual(w.Value, testCase.ItemNames(newIdx));
            testCase.verifyEqual(w.SelectedIndex, newIdx);

            % Change items
            newSel = [1 3 5];
            w.Items = w.Items(newSel);

            % Give a moment for update to run
            drawnow

            % Verify new value and selected index
            testCase.verifyEqual(w.Value, testCase.ItemNames([5 3 1]));
            testCase.verifyEqual(w.SelectedIndex, [3 2 1]);
            testCase.verifyEqual(w.HighlightedValue, testCase.ItemNames(5));

            % Move items to the left
            testCase.press(button(2))
            testCase.press(button(2))

            % Give a moment for update to run
            drawnow

            % Verify new order
            newIdx = 1;
            testCase.verifyEqual(w.Value, testCase.ItemNames(newIdx));
            testCase.verifyEqual(w.SelectedIndex, 1);
            testCase.verifyEqual(w.HighlightedValue, testCase.ItemNames(1));
            testCase.verifyEqual(w.LeftList.Value, 2);
            
        end


        function testSortable(testCase)

            % Get the RightList and button grid
            w = testCase.Widget;
            leftlistControl = testCase.Widget.LeftList;
            buttonGrid = testCase.Widget.ListButtons;
            button = buttonGrid.Button;

            for idx = 1:numel(w.Items)

                % Select last item
                testCase.choose(leftlistControl, numel(w.Items) + 1 - idx)
                
                % Move items to the right
                testCase.press(button(1))
                
                % Give a moment for update to run
                drawnow
            end

            % Verify new order
            newIdx = 5:-1:1;
            testCase.verifyEqual(w.Value, testCase.ItemNames(newIdx));
            testCase.verifyEqual(w.SelectedIndex, newIdx);

            % Set sortable
            w.Sortable = false;

            % Give a moment for update to run
            drawnow

            % Check new order
            newIdx = 1:5;
            testCase.verifyEqual(w.Value, testCase.ItemNames(newIdx));
            testCase.verifyEqual(w.SelectedIndex, newIdx);
        end
        
            
        function testUserButtons(testCase)
            
            % Get the widget
            w = testCase.Widget;
            
            % Add User buttons
            w.UserButtons.Icon = ["plot_24.png","play_24.png"];
            drawnow            
            
            % Add user buttons
            b = w.UserButtons.Button;
            testCase.verifyNumElements(b, 2);
            
            % Press user buttons
            testCase.press(b(1))
            testCase.press(b(2))
            
            % Verify callbacks fired
            testCase.verifyEqual(testCase.CallbackCount, 2);
            
        end %function
        
            
        function testStyleProperties(testCase)
            
            % Set ButtonWidth
            testCase.verifySetProperty("ButtonWidth", 40);
            
            % Set ButtonWidth
            testCase.verifySetProperty("FontSize", 20);
            
            % Set Enable
            testCase.verifySetProperty("Enable", "off");
            
            % Verify callback did not fire
            testCase.verifyEqual(testCase.CallbackCount, 0);
            
        end %function
        
            
        
    end %methods (Test)
    
end %classdef