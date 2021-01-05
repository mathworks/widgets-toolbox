classdef TaskStatusTable < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
    % Copyright 2020 The MathWorks, Inc.
    
    
    
    %% Class Setup
    methods (TestClassSetup)
        
        function createFigure(testCase)
            
            % Call superclass method
            testCase.createFigure@wt.test.BaseWidgetTest();
            
            % Modify the grid row height
            testCase.Grid.RowHeight = {'1x','1x'};
            testCase.Grid.ColumnWidth = {'1x','1x','1x'};
            
        end %function
        
    end %methods
    
    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            fcn = @()wt.TaskStatusTable(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            
            % Set callback
            testCase.Widget.ButtonPushedFcn = @(s,e)onCallbackTriggered(testCase,e);
            
            % Ensure it renders
            drawnow
            
        end %function
        
    end %methods
    
    
    %% Unit Tests
    methods (Test)
            
        function testItems(testCase)
            
            % Set the statuses to complete
            numItems = numel(testCase.Widget.Items);
            newStatus = repmat(wt.enum.StatusState.complete, numItems, 1);
            testCase.verifySetProperty("Status", newStatus);
            
            % Set the items
            items = [
                "California"
                "Massachusetts"
                "New Mexico"
                ];
            testCase.verifySetProperty("Items", items);
            
            % Verify status adapts to new items size
            numItems = numel(items);
            actVal = string(testCase.Widget.Status);
            expVal = repmat("complete", numItems, 1);
            testCase.verifyEqual(actVal, expVal);
            
            % Add more items
            items(end+1) = "Arizona";
            testCase.verifySetProperty("Items", items);
           
            % Verify the value adapts
            numItems = numel(items);
            actVal = string(testCase.Widget.Status);
            expVal = repmat("complete", numItems, 1);
            testCase.verifyEqual(actVal, expVal);
            
        end %function
            
        
        function testButtonsAndSelection(testCase)
            
            % Verify selection color
            selColor = [0.3 0.9 1];
            testCase.verifySetProperty("SelectionColor", selColor);
            
            % Get the buttons
            backButton = testCase.Widget.BackButton;
            fwdButton = testCase.Widget.ForwardButton;
            
            % First item selected by default
            testCase.verifyEqual(testCase.Widget.SelectedIndex, 1)
            
            % Can't press back
            testCase.verifyFalse(backButton.Enable)
            testCase.press(backButton)
            testCase.verifyEqual(testCase.Widget.SelectedIndex, 1)
            
            % Push forward
            testCase.verifyTrue(fwdButton.Enable)
            testCase.press(fwdButton)
            testCase.verifyEqual(testCase.Widget.SelectedIndex, 2)
            
            % Push forward to end
            numItems = numel(testCase.Widget.Items);
            testCase.verifyTrue(fwdButton.Enable)
            for idx = 1:numItems-1
                testCase.press(fwdButton)
            end
            testCase.verifyTrue(backButton.Enable)
            testCase.verifyFalse(fwdButton.Enable)
            testCase.verifyEqual(testCase.Widget.SelectedIndex, numItems)
            
            % Now, programmatically change the index
            newIdx = 3;
            testCase.verifySetProperty("SelectedIndex", newIdx);
            testCase.verifyTrue(backButton.Enable)
            testCase.verifyTrue(fwdButton.Enable)
            testCase.verifyEqual(testCase.Widget.SelectedIndex, newIdx)
            
            % Verify selection color of selected label
            actValue = testCase.Widget.Label(newIdx).BackgroundColor;
            testCase.verifyEqual(actValue, selColor)
            
        end %function
            
        
        function testButtonRow(testCase)
            
            % Get the buttons
            backButton = testCase.Widget.BackButton;
            fwdButton = testCase.Widget.ForwardButton;
            
            % Set the selected index
            testCase.verifySetProperty("SelectedIndex", 2);
            testCase.verifyTrue(backButton.Enable)
            testCase.verifyTrue(fwdButton.Enable)
            
            % Test programmatic disable - forward button
            testCase.verifySetProperty("EnableForward", false);
            testCase.verifyTrue(backButton.Enable)
            testCase.verifyFalse(fwdButton.Enable)
            
            % Test programmatic disable - back button
            testCase.verifySetProperty("EnableBack", false);
            testCase.verifyFalse(backButton.Enable)
            testCase.verifyFalse(fwdButton.Enable)
            
            % Test hide button row
            testCase.verifyGreaterThan(testCase.Widget.Grid.RowHeight{2}, 0)
            testCase.verifySetProperty("ShowButtonRow", false);
            testCase.verifyEqual(testCase.Widget.Grid.RowHeight{2}, 0)
            
        end %function
            
        
        function testStatusMessage(testCase)
            
            newValue = "Test Message";
            testCase.verifySetProperty("StatusMessage", newValue);
            testCase.verifyMatches(testCase.Widget.StatusLabel.Text, newValue)
            
        end %function
        
    end %methods (Test)
    
end %classdef