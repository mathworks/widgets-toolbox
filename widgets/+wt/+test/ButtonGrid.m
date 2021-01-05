classdef ButtonGrid < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
    % Copyright 2020 The MathWorks, Inc.
    
    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            % Call superclass method
            testCase.setup@wt.test.BaseWidgetTest();
            
            fcn = @()wt.ButtonGrid(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            
            % Set callback
            testCase.Widget.ButtonPushedFcn = @(s,e)onCallbackTriggered(testCase,e);
            
            % Ensure it renders
            drawnow
            
        end %function
        
    end %methods
    
    
    %% Unit Tests
    methods (Test)
            
        function testCreationByIcon(testCase)
            % Add buttons by Icon only
            
            icon = ["add" "delete" "play" "pause" "stop"] + "_24.png";
            
            testCase.verifySetProperty("Icon", icon);
            
        end %function
        
        
        function testCreationByTextAndIcon(testCase)
            % Add buttons by Icon and Text
            
            text = ["Add" "Delete" "Play" "Pause" "Stop"];
            icon = ["add" "delete" "play" "pause" "stop"] + "_24.png";
            
            testCase.verifySetProperty("Icon", icon);
            testCase.verifySetProperty("Text", text);
            
            expNum = max(numel(text), numel(icon));
            testCase.verifyNumElements(testCase.Widget.Button, expNum)
            
        end %function
        
        
        function testMissingIcons(testCase)
            % Some buttons don't have icon
            
            text = ["Add" "Delete" "Play" "Pause" "Stop"];
            icon = ["add" "delete" "play" "pause"] + "_24.png";
            
            testCase.verifySetProperty("Icon", icon);
            testCase.verifySetProperty("Text", text);
            
            expNum = max(numel(text), numel(icon));
            testCase.verifyNumElements(testCase.Widget.Button, expNum)
            
        end %function
        
        
        function testMissingText(testCase)
            % Some buttons don't have text
            
            text = ["Add" "" "Play" "Pause"];
            icon = ["add" "delete" "play" "pause" "stop"] + "_24.png";
            
            testCase.verifySetProperty("Icon", icon);
            testCase.verifySetProperty("Text", text);
            
            expNum = max(numel(text), numel(icon));
            testCase.verifyNumElements(testCase.Widget.Button, expNum)
            
        end %function
        
        
        function testExtraTooltip(testCase)
            % Extra tooltips provided don't produce more buttons
            
            text = ["Add" "" "Play" "Pause"];
            icon = ["add" "delete" "play" "pause"] + "_24.png";
            tip = "Press to " + ["add" "delete" "play" "pause" "stop"];
            
            testCase.verifySetProperty("Icon", icon);
            testCase.verifySetProperty("Text", text);
            testCase.verifySetProperty("Tooltip", tip);
            
            expNum = max(numel(text), numel(icon));
            testCase.verifyNumElements(testCase.Widget.Button, expNum)
            
        end %function
        
        
        function testPressButton(testCase)
            % Extra tooltips provided don't produce more buttons
            
            text = ["Add" "Delete" "Play"];
            icon = ["add" "delete" "play"] + "_24.png";
            tag = text + "_tag";
            
            testCase.verifySetProperty("Icon", icon);
            testCase.verifySetProperty("Text", text);
            testCase.verifySetProperty("ButtonTag", tag);
            
            buttons = testCase.Widget.Button;
            
            numButtons = numel(text);
            for idx = 1:numButtons
                testCase.press(buttons(idx));
            end
            
            % Each button should have triggered one callback
            testCase.verifyEqual(testCase.CallbackCount, numButtons)
            
            % Button eventdata should match the pushes in order
            evts = testCase.CallbackEvents;
            testCase.verifyEqual([evts.Button], buttons)
            testCase.verifyEqual(string({evts.Text}), text)
            testCase.verifyEqual(string({evts.Tag}), tag)
            
        end %function
        
            
        function testBackgroundColor(testCase)
            
            % Set the backgroundcolor
            newValue = [1 0.5 0.2];
            testCase.verifySetProperty("BackgroundColor", newValue);
            testCase.verifyEqual(testCase.Widget.Grid.BackgroundColor, newValue);
            
        end %function
        
            
        function testOrientation(testCase)
            
            icon = ["up" "down"] + "_24.png";
            testCase.verifySetProperty("Icon", icon);
            
            % Verify the orientation default
            actVal = string(testCase.Widget.Orientation);
            testCase.verifyMatches(actVal, "horizontal");
            testCase.verifyNumElements(testCase.Widget.Grid.RowHeight, 1);
            testCase.verifyNumElements(testCase.Widget.Grid.ColumnWidth, numel(icon));
            
            % Set the orientation
            testCase.verifySetProperty("Orientation", "vertical");
            testCase.verifyNumElements(testCase.Widget.Grid.RowHeight, numel(icon));
            testCase.verifyNumElements(testCase.Widget.Grid.ColumnWidth, 1);
            
        end %function
        
            
        function testIconAlignment(testCase)
            
            icon = "up_24.png";
            text = "Up";
            testCase.verifySetProperty("Icon", icon);
            testCase.verifySetProperty("Text", text);
            
            button = testCase.Widget.Button;
            
            % Set the alignment
            newValue = "top";
            testCase.verifySetProperty("IconAlignment", newValue);
            testCase.verifyMatches(button.IconAlignment, newValue);
            
            % Set the alignment
            newValue = "bottom";
            testCase.verifySetProperty("IconAlignment", newValue);
            testCase.verifyMatches(button.IconAlignment, newValue);
            
            % Set the alignment
            newValue = "right";
            testCase.verifySetProperty("IconAlignment", newValue);
            testCase.verifyMatches(button.IconAlignment, newValue);
            
            % Set the alignment
            newValue = "left";
            testCase.verifySetProperty("IconAlignment", newValue);
            testCase.verifyMatches(button.IconAlignment, newValue);
            
        end %function
        
    end %methods (Test)
    
end %classdef