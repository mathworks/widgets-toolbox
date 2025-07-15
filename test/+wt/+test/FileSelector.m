classdef FileSelector < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
%   Copyright 2020-2025 The MathWorks Inc.
    
    
    
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
            testCase.verifyEqual(string(editControl.Value), newValue);
            
            % Set the value
            newValue = fullfile("C","Temp","filename.mat");
            testCase.verifySetProperty("Value", newValue);
            drawnow
            testCase.verifyEqual(string(editControl.Value), newValue);
            
        end %function
        
            
        function testFolderEditField(testCase)
            
            % Get the edit field
            editControl = testCase.Widget.EditControl;
            
            % Set the type
            testCase.verifySetProperty("SelectionType", "folder");
            
            % Type a valid value
            newValue = string(matlabroot);
            testCase.verifyTypeAction(editControl, newValue, "Value");

            % Verify the warn image does not show
            testCase.verifyFalse(logical(testCase.Widget.WarnImage.Visible));
            
            % Verify the ValueIsValidPath value
            testCase.verifyTrue(testCase.Widget.ValueIsValidPath)
            
            % Type an invalid value
            newValue = "some bad folder path";
            testCase.verifyTypeAction(editControl, newValue, "Value");
            
            % Verify the ValueIsValidPath value
            testCase.verifyFalse(testCase.Widget.ValueIsValidPath)

            % Verify the warn image shows
            testCase.verifyVisible(testCase.Widget.WarnImage)
            %testCase.verifyTrue(logical(testCase.Widget.WarnImage.Visible));
            
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

            % Verify the warn image does not show
            testCase.verifyFalse(logical(testCase.Widget.WarnImage.Visible));
            
            % Type an invalid value
            newValue = "some bad file path";
            testCase.verifyTypeAction(editControl, newValue, "Value");
            
            % Verify the ValueIsValidPath value
            testCase.verifyFalse(testCase.Widget.ValueIsValidPath)

            % Verify the warn image shows
            testCase.verifyVisible(testCase.Widget.WarnImage)
            %testCase.verifyTrue(logical(testCase.Widget.WarnImage.Visible));
            
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
            testCase.verifyEqual(testCase.Widget.Value, newValue1);
            
            % Verify the ValueIsValidPath value
            testCase.verifyTrue(testCase.Widget.ValueIsValidPath)

            % Verify the warn image does not show
            testCase.verifyFalse(logical(testCase.Widget.WarnImage.Visible));
            
            % Verify the full path
            fullPath = fullfile(rootDir,newValue1);
            testCase.verifyEqual(testCase.Widget.FullPath, fullPath);
            
            
            % Switch to folder mode
            testCase.verifySetProperty("SelectionType", "folder");
            
            % Set a valid value
            newValue2 = fullfile("toolbox","matlab");
            testCase.verifySetProperty("Value", newValue2);
            drawnow
            testCase.verifyEqual(string(dropdownControl.Value), newValue2);
            
            % Verify the ValueIsValidPath value
            testCase.verifyTrue(testCase.Widget.ValueIsValidPath)

            % Verify the warn image does not show
            testCase.verifyFalse(logical(testCase.Widget.WarnImage.Visible));
            
            % Verify the full path
            fullPath = fullfile(rootDir,newValue2);
            testCase.verifyEqual(testCase.Widget.FullPath, fullPath);
            
            
            % Verify the history
            expValue = [newValue2; newValue1];
            testCase.verifyEqual(testCase.Widget.History, expValue);
            testCase.verifyEqual(string(dropdownControl.Items(:)), expValue);
            
        end %function
        
        function testButtonLabel(testCase)
            
            % Get the button control
            buttonControl = testCase.Widget.ButtonControl;
            
            % Set the value
            newValue = "Select File";
            testCase.verifySetProperty("ButtonLabel", newValue);
            drawnow
            testCase.verifyEqual(string(buttonControl.Text), newValue);
            
            % Set the value
            newValue = "Browse";
            testCase.verifySetProperty("ButtonLabel", newValue);
            drawnow
            testCase.verifyEqual(string(buttonControl.Text), newValue);
            
        end %function
        
        % Since this test-case unlocks the test figure it should be last in 
        % line.
        function testButton(testCase)
        
            % Running in desktop mode?
            testCase.assumeEqual(exist('desktop', 'file'), 6, 'Cannot find function ''desktop.m''.')
            testCase.assumeTrue(desktop('-inuse'), 'MATLAB must run in desktop mode in order to complete current test.')

            % Get the button control
            buttonControl = testCase.Widget.ButtonControl;

            % Ancestor figure
            fig = ancestor(buttonControl, "Figure");

            % Make sure file dialog window is in-app by setting the
            % 'ShowInWebApps' value to true.
            
            % Get active value to restore
            s = settings;
            curTempVal = s.matlab.ui.dialog.fileIO.ShowInWebApps.ActiveValue;

            % Set temporary value of ShowInWebApps setting to true, so that file
            % selector dialog window is a component in the figure.
            s.matlab.ui.dialog.fileIO.ShowInWebApps.TemporaryValue = true;
            cleanup = onCleanup(@() localRevertShowInWebAppsSetting(s, curTempVal));

            % While dialog window is open and blocked by waitfor, there is still
            % a possibility to execute code through the timer function.

            % Set timer callback
            delay = 2; % seconds
            t = timer;
            t.StartDelay = delay; % starts after 2 seconds
            t.TimerFcn = @(s,e) localPressEscape(fig);
            start(t); % start the timer

            % Now press the button
            tStart = tic;
            testCase.press(buttonControl);

            % Wait for escape button to be pressed.
            tStop = toc(tStart);
            
            % Time while MATLAB waits for an action should be larger than the 
            % StartDelay. If not, MATLAB did not reach the waitfor status after 
            % pressing the file-selection button.
            testCase.verifyGreaterThan(tStop, delay)            
        
        end %function
        
    end %methods (Test)
    
end %classdef

function localPressEscape(fig)

% Unlock the figure, otherwise escape will not work.
matlab.uitest.unlock(fig);

% Bring focus to figure
figure(fig)

% Press ESCAPE
r = java.awt.Robot;
r.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
pause(0.1);
r.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);

end

function localRevertShowInWebAppsSetting(s, val)

% Revert setting on cleanup
s.matlab.ui.dialog.fileIO.ShowInWebApps.TemporaryValue = val;

end