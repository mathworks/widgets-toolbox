classdef ProgressBar < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
%   Copyright 2020-2025 The MathWorks Inc.
    
    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            fcn = @()wt.ProgressBar(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            
            % Set callback
            testCase.Widget.CancelPressedFcn = @(s,e)onCallbackTriggered(testCase,e);
            
            % Ensure it renders and resizes fully
            drawnow
            pause(2) %needs time to resize, drawnow doesn't work!
            
        end %function
        
    end %methods
    
    
    %% Unit Tests
    methods (Test)
            
        function testProgress(testCase)
            import matlab.unittest.constraints.Eventually
            import matlab.unittest.constraints.IsEqualTo
            % Test the progress steps
            
            % Get the controls
            statusLabel = testCase.Widget.StatusTextLabel;
            timeLabel = testCase.Widget.RemTimeLabel;
            
            % Verify starting bar is empty
            testCase.assumeEqual(testCase.Widget.ProgressPanel.Units, 'pixels')
            testCase.verifyThat(@()testCase.Widget.ProgressPanel.Position(3),Eventually(IsEqualTo(0)));
            
            % Start
            testCase.verifyMethod("startProgress")
            drawnow
            
            % Start with message
            message = "Now started";
            testCase.verifyMethod("startProgress", message)
            drawnow
            
            % Verify text and time
            testCase.verifyMatches(statusLabel.Text, message)
            testCase.verifyEqual(testCase.Widget.RemainingTime, seconds(inf))
            
            
            % Update 1
            value = 0.3;
            message = "";
            testCase.verifyMethod(@setProgress, value)
            pause(2) %needs time to resize, drawnow doesn't work!
            
            % Verify bar size
            testCase.assumeEqual(testCase.Widget.Units, 'pixels')
            wPos = testCase.Widget.Position;
            pos = testCase.Widget.ProgressPanel.Position;
            testCase.verifyGreaterThan(pos(3), wPos(3)/10)
            testCase.verifyLessThan(pos(3), wPos(3)/2)
            
            % Verify text and time
            actVal = string(strtrim(statusLabel.Text));
            testCase.verifyEqual(actVal, message)
            remTime = testCase.Widget.RemainingTime;
            testCase.verifyGreaterThanOrEqual(remTime, seconds(3))

            
            % Update 2 with message
            value = 0.6;
            message = "60% Complete";
            testCase.verifyMethod(@setProgress, value, message)
            pause(2) %needs time to resize, drawnow doesn't work!
            
            % Verify bar size
            pos = testCase.Widget.ProgressPanel.Position;
            testCase.verifyGreaterThan(pos(3), wPos(3)/2)
            testCase.verifyLessThan(pos(3), wPos(3))
            
            % Verify text and time
            actVal = string(strtrim(statusLabel.Text));
            testCase.verifyEqual(actVal, message)
            remTime = testCase.Widget.RemainingTime;
            testCase.verifyGreaterThanOrEqual(remTime, seconds(1))
            
            % Verify the displayed time text also
            remTime = duration(timeLabel.Text,'InputFormat','mm:ss');
            testCase.verifyGreaterThanOrEqual(remTime, seconds(1))
            
            
            % Finish
            message = "";
            testCase.verifyMethod("finishProgress")
            pause(2) %needs time to resize, drawnow doesn't work!
            
            % Verify bar size
            pos = testCase.Widget.ProgressPanel.Position;
            testCase.verifyEqual(pos(3), 0)
            
            % Verify text and time
            actVal = string(strtrim(statusLabel.Text));
            testCase.verifyEqual(actVal, message)
            remTime = testCase.Widget.RemainingTime;
            testCase.verifyEqual(remTime, duration(missing))
            
            % Verify the displayed time text also
            actVal = string(strtrim(timeLabel.Text));
            testCase.verifyEqual(actVal, "");
            
            
            % Finish with message
            message = "Now complete";
            testCase.verifyMethod("finishProgress", message)
            
            % Verify text and time
            actVal = string(strtrim(statusLabel.Text));
            testCase.verifyEqual(actVal, message)
            remTime = testCase.Widget.RemainingTime;
            testCase.verifyEqual(remTime, duration(missing))
            
        end %function
            
        
        function testIndeterminate(testCase)
            
            % Get the displayed image
            indBar = testCase.Widget.IndeterminateBar;
            
            % Not visibile by default
            testCase.verifyFalse(indBar.Visible);
            
            % Turn it on
            testCase.verifySetProperty("Indeterminate", true);
            
            % Still not visible until started
            testCase.verifyFalse(indBar.Visible);
            
            % Start
            testCase.verifyMethod("startProgress")
            
            % Finally visible
            testCase.verifyTrue(indBar.Visible);
            
        end %function
            
        
        function testShowCancel(testCase)
            
            % Get the cancel button
            cancelButton = testCase.Widget.CancelButton;
            
            % Not visibile by default
            testCase.verifyFalse(cancelButton.Visible);
            
            % Enable cancel button
            testCase.verifySetProperty("ShowCancel", true);
            
            % Still not visible until started
            testCase.verifyFalse(cancelButton.Visible);
            
            % No cancel detected yet
            testCase.verifyFalse(testCase.Widget.CancelRequested)
            
            % Start
            testCase.verifyMethod("startProgress")
            
            % Finally visible
            testCase.verifyTrue(cancelButton.Visible);
            
            % Advance progress
            testCase.verifyMethod(@setProgress, 0.5);
            
            % No cancel detected yet
            testCase.verifyFalse(testCase.Widget.CancelRequested)
            
            % Press the button
            testCase.press(cancelButton);
            
            % Verify the cancel operation
            testCase.verifyTrue(testCase.Widget.CancelRequested)
            testCase.verifyGreaterThan(testCase.CallbackCount, 0)
        
        end %function
            
        
        function testShowTimeRemaining(testCase)
            
            % Get the controls
            timeLabel = testCase.Widget.RemTimeLabel;
            
            % Start
            testCase.verifyMethod("startProgress")
            
            % Wait a few seconds so the progress bar tracks time
            pause(2)
            
            % Update 1 - Tell the status bar it's 30% done after 2 seconds
            value = 0.3;
            testCase.verifyMethod(@setProgress, value)
            
            % Verify the displayed time text is positive
            remTime = duration(timeLabel.Text,'InputFormat','mm:ss');
            testCase.verifyGreaterThanOrEqual(remTime, seconds(1))
            
            % Disable the time display
            testCase.verifySetProperty("ShowTimeRemaining", false);
            
            % Verify the displayed time text
            timeText = strtrim(char(timeLabel.Text));
            testCase.verifyEmpty(timeText)
            
        end %function
        
    end %methods (Test)
    
end %classdef