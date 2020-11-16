classdef FilePicker < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
    % Copyright 2020 The MathWorks, Inc.
    
    
    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            fcn = @()wt.FileSelector(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            drawnow
            
        end %function
        
    end %methods
    
    
    %% Unit Tests
    methods (Test)
            
        function testValueProperty(testCase)
            
            % Get the edit field
            editControl = testCase.Widget.EditControl;
            
            % Set the value
            newValue = fullfile("C:","Users");
            testCase.verifySetProperty("Value", newValue);
            drawnow
            testCase.verifyEqual(newValue, string(editControl.Value));
            
            % Set the value
            newValue = fullfile("C","Temp","filename.mat");
            testCase.verifySetProperty("Value", newValue);
            drawnow
            testCase.verifyEqual(newValue, string(editControl.Value));
            
        end %function
        
            
        function testFolderEditField(testCase)
            
            % Get the edit field
            editControl = testCase.Widget.EditControl;
            
            % Set the type
            testCase.verifySetProperty("SelectionType", "folder");
            
            % Type a valid value
            newValue = string(matlabroot);
            testCase.verifyTypeAction(editControl, newValue, "Value");
            
            % Verify the ValueIsValidPath value
            testCase.verifyTrue(testCase.Widget.ValueIsValidPath)
            
            % Type an invalid value
            newValue = "some bad folder path";
            testCase.verifyTypeAction(editControl, newValue, "Value");
            
            % Verify the ValueIsValidPath value
            testCase.verifyFalse(testCase.Widget.ValueIsValidPath)
            
        end %function
        
            
        function testFileEditField(testCase)
            
            % Get the edit field
            editControl = testCase.Widget.EditControl;
            
            % Set the type
            testCase.verifySetProperty("SelectionType", "file");
            
            % Type a valid value
            newValue = fullfile(matlabroot,"VersionInfo.xml");
            testCase.verifyTypeAction(editControl, newValue, "Value");
            
            % Verify the ValueIsValidPath value
            testCase.verifyTrue(testCase.Widget.ValueIsValidPath)
            
            % Type an invalid value
            newValue = "some bad file path";
            testCase.verifyTypeAction(editControl, newValue, "Value");
            
            % Verify the ValueIsValidPath value
            testCase.verifyFalse(testCase.Widget.ValueIsValidPath)
            
        end %function
        
        
        function testRootDirectoryAndHistory(testCase)
            
            % Get the dropdown field
            dropdownControl = testCase.Widget.DropdownControl;
            
            % Configure the widget
            testCase.verifySetProperty("SelectionType", "folder");
            testCase.verifySetProperty("ShowHistory", true);
            testCase.verifySetProperty("History", string.empty(0,1));
            
            
            % Use MATLAB's root
            rootDir = string(matlabroot);
            
            % Set the root
            testCase.verifySetProperty("RootDirectory", rootDir);
            
            % Type a valid value
            newValue1 = fullfile("bin");
            testCase.verifyTypeAction(dropdownControl, newValue1, "Value");
            testCase.verifyEqual(newValue1, testCase.Widget.Value);
            
            % Verify the ValueIsValidPath value
            testCase.verifyTrue(testCase.Widget.ValueIsValidPath)
            
            % Verify the full path
            fullPath = fullfile(rootDir,newValue1);
            testCase.verifyEqual(fullPath, testCase.Widget.FullPath);
            
            
            % Switch to folder mode
            testCase.verifySetProperty("SelectionType", "folder");
            
            % Set a valid value
            newValue2 = fullfile("toolbox","matlab");
            testCase.verifySetProperty("Value", newValue2);
            drawnow
            testCase.verifyEqual(newValue2, string(dropdownControl.Value));
            
            % Verify the ValueIsValidPath value
            testCase.verifyTrue(testCase.Widget.ValueIsValidPath)
            
            % Verify the full path
            fullPath = fullfile(rootDir,newValue2);
            testCase.verifyEqual(fullPath, testCase.Widget.FullPath);
            
            
            % Verify the history
            expValue = [newValue2; newValue1];
            testCase.verifyEqual(expValue, testCase.Widget.History);
            testCase.verifyEqual(expValue, string(dropdownControl.Items(:)));
            
        end %function
        
        
        % function testButton(testCase)
        %
        %     % We can't test the button in this case because it triggers a
        %     % modal dialog with no way to click on the dialog.
        %
        % end %function
        
    end %methods (Test)
    
end %classdef