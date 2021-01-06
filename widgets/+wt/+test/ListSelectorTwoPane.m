classdef ListSelectorTwoPane < wt.test.ListSelector
    % Implements a unit test for a widget or component
    
    % This test for ListSelectorTwoPane reuses those of ListSelector
    % with a few additions and modifications
    
    % Copyright 2020-2021 The MathWorks, Inc.
    
    
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
            
        end %function
        
    end %methods
    
    
    %% Unit Tests
    methods (Test)
            
        function testProgrammaticItemsValueSelection(testCase)
        
            % Run the superclass test
            testCase.testProgrammaticItemsValueSelection@wt.test.ListSelector();
            
            % Validate the left list items
            leftIdx = [1 3 4];
            leftList = testCase.Widget.AllItemsListBox;
            testCase.verifyEqual(string(leftList.Items), testCase.ItemNames(leftIdx));
            testCase.verifyEqual(leftList.ItemsData, leftIdx);
            
        end %function
        
        
        function testProgrammaticItemsDataValueSelection(testCase)
            
            % Run the superclass test
            testCase.testProgrammaticItemsDataValueSelection@wt.test.ListSelector();
            
            % Validate the left list items
            leftIdx = [1 3 4];
            leftList = testCase.Widget.AllItemsListBox;
            testCase.verifyEqual(string(leftList.Items), testCase.ItemNames(leftIdx));
            testCase.verifyEqual(leftList.ItemsData, leftIdx);
            
        end %function
        
        
        function testButtonFunctions(testCase)
            
            % Run the superclass test
            testCase.testButtonFunctions@wt.test.ListSelector();
            
            % Validate the left list items
            leftIdx = [2 3];
            leftList = testCase.Widget.AllItemsListBox;
            testCase.verifyEqual(string(leftList.Items), testCase.ItemNames(leftIdx));
            testCase.verifyEqual(leftList.ItemsData, leftIdx);
            
        end %function
        
    end %methods (Test)
    
end %classdef