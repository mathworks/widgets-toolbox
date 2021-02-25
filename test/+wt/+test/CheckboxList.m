classdef CheckboxList < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
    % Copyright 2020-2021 The MathWorks, Inc.
    
    
    
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
            
            fcn = @()wt.CheckboxList(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            
            % Set callback
            testCase.Widget.ValueChangedFcn = @(s,e)onCallbackTriggered(testCase,e);
            
            % Ensure it renders
            drawnow
            
        end %function
        
    end %methods
    
    
    %% Unit Tests
    methods (Test)
            
        function testItems(testCase)
            
            % Set the items
            items = [
                "California"
                "Massachusetts"
                "New Mexico"
                ];
            testCase.verifySetProperty("Items", items);
            
            % Verify value adapts
            numItems = numel(items);
            actVal = testCase.Widget.Value;
            expVal = true(numItems, 1);
            testCase.verifyEqual(actVal, expVal);
            
            % Add more items
            items = "Item " + string(1:10)';
            testCase.verifySetProperty("Items", items);
           
            % Verify the value adapts
            numItems = numel(items);
            actVal = testCase.Widget.Value;
            expVal = true(numItems, 1);
            testCase.verifyEqual(actVal, expVal);
            
        end %function
        
            
        function testValue(testCase)
            
            % Verify value is matching size
            numItems = numel(testCase.Widget.Items);
            actVal = testCase.Widget.Value;
            expVal = true(numItems, 1);
            testCase.verifyEqual(actVal, expVal);
            
            % Get the checkbox controls
            cbox = testCase.Widget.ItemCheck;
            
            % Change all values to false
            newValue = false(numItems, 1);
            testCase.verifySetProperty("Value", newValue)
            testCase.verifyEqual([cbox.Value]', newValue);
            
            % Toggle checkboxes
            idxOn = 3;
            testCase.choose(cbox(idxOn));
            newValue(idxOn) = true;
            testCase.verifyEqual(testCase.Widget.Value, newValue)
            testCase.verifyEqual([cbox.Value]', newValue);
            
            % Verify callback fired
            testCase.verifyEqual(testCase.CallbackCount, 1);
            
        end %function
        
            
        function testSelectAll(testCase)
            
            numItems = numel(testCase.Widget.Items);
            allFalse = false(numItems, 1);
            allTrue = true(numItems, 1);
            
            % Turn off all checkbox values
            testCase.verifySetProperty("Value", allFalse);
            
            % Toggle on select all
            testCase.verifySetProperty("ShowSelectAll", true);
            
            % Re-verify value
            testCase.verifyEqual(testCase.Widget.Value, allFalse);
            
            % Get the checkbox controls
            cbox = testCase.Widget.ItemCheck;
            AllCheck = testCase.Widget.AllCheck;
            
            % Choose select all
            testCase.choose(AllCheck);
            
            % Verify new value
            testCase.verifyEqual([cbox.Value]', allTrue);
            testCase.verifyEqual(testCase.Widget.Value, allTrue);
            
            % Verify callback fired
            testCase.verifyEqual(testCase.CallbackCount, 1);
            
        end %function
        
    end %methods (Test)
    
end %classdef