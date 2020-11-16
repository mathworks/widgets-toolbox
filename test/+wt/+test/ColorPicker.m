classdef ColorPicker < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
    % Copyright 2020 The MathWorks, Inc.
    
    
    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            fcn = @()wt.ColorSelector(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            drawnow
            
        end %function
        
    end %methods
    
    
    %% Unit Tests
    methods (Test)
            
        function testValueProperty(testCase)
            
            % Set the color
            newColor = [1 0 0];
            testCase.verifySetProperty("Value", newColor);
            
            % Set the color
            newColor = [0.5 1 0];
            testCase.verifySetProperty("Value", newColor);
            
            % Test an invalid color
            newColor = [-1 0 1];
            errorID = 'wt:validators:mustBeBetween';
            testCase.verifySetPropertyError("Value", newColor, errorID);
            
            % Test an invalid color
            newColor = {1};
            errorID = 'MATLAB:validation:UnableToConvert';
            testCase.verifySetPropertyError("Value", newColor, errorID);
            
            % Test an invalid color
            newColor = rand(1,5);
            errorID = 'MATLAB:validation:IncompatibleSize';
            testCase.verifySetPropertyError("Value", newColor, errorID);
            
            % Test an invalid color
            newColor = rand(2,5);
            errorID = 'MATLAB:validation:IncompatibleSize';
            testCase.verifySetPropertyError("Value", newColor, errorID);
            
        end %function
        
            
        function testEditField(testCase)
            
            % Get the edit field
            editControl = testCase.Widget.EditControl;
            
            % Type a valid color
            newColorStr = "0.5 1 0.2";
            expValue = [0.5 1 0.2];
            testCase.verifyTypeAction(editControl, newColorStr, "Value", expValue);
            
            % Type an invalid color
            % It should silently revert
            newColorStr = "user typing an invalid entry";
            testCase.verifyTypeAction(editControl, newColorStr, "Value", expValue);
            
            % Type an invalid color
            % It should silently revert
            newColorStr = "[-1 0 3]";
            testCase.verifyTypeAction(editControl, newColorStr, "Value", expValue);
            
        end %function
        
        
        function testDisplayedValues(testCase)
            
            % Get the controls
            editControl = testCase.Widget.EditControl;
            buttonControl = testCase.Widget.ButtonControl;
        
            % Define the new value
            newColor = [0.4 0.5 0.6];
            newColorStr = "[0.4 0.5 0.6]";
            
            % Set the color by Value property
            testCase.verifySetProperty("Value", newColor);
            
            % Ensure "update" gets called before we check control values
            drawnow
            
            % Check the edit field
            actValue = editControl.Value;
            testCase.verifyMatches(actValue, newColorStr)
            
            % Check the button
            actValue = buttonControl.BackgroundColor;
            testCase.verifyEqual(actValue, newColor)
        
            
            % Define the new value
            newColor = [0.7 0.5 0.2];
            newColorStr = "[0.7 0.5 0.2]";
            
            % Set the color by edit field
            testCase.verifyTypeAction(editControl, newColorStr, "Value", newColor);
            
            % Ensure "update" gets called before we check control values
            drawnow
            
            % Check the edit field
            actValue = editControl.Value;
            testCase.verifyMatches(actValue, newColorStr)
            
            % Check the button
            actValue = buttonControl.BackgroundColor;
            testCase.verifyEqual(actValue, newColor)
            
        end %function
        
            
        function toggleEditField(testCase)
            
            % Get the controls
            editControl = testCase.Widget.EditControl;
            buttonControl = testCase.Widget.ButtonControl;
            gridControl = testCase.Widget.Grid;
            
            % Turn off the edit field
            testCase.verifySetProperty("ShowEditField", false);
            
            % Verify the edit control was unparented
            testCase.verifyEmpty(editControl.Parent);
            
            % Verify the grid has only the button in it
            testCase.verifySize(gridControl.Children, [1 1])
            testCase.verifyEqual(gridControl.Children, buttonControl);
            
        end %function
        
        
        % function testButton(testCase)
        %
        %     % We can't test the button in this case because it triggers a
        %     % modal dialog with no way to click on the dialog.
        %
        % end %function
        
    end %methods (Test)
    
end %classdef