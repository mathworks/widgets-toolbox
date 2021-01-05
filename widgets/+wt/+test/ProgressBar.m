classdef ProgressBar < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
    % Copyright 2020 The MathWorks, Inc.
    
    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            fcn = @()wt.ProgressBar(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            
            % Set callback
            testCase.Widget.CancelPressedFcn = @(s,e)onCallbackTriggered(testCase,e);
            
            % Ensure it renders
            drawnow
            
        end %function
        
    end %methods
    
    
    %% Unit Tests
    methods (Test)
            
        function testProgress(testCase)
            % Test the progress steps
            
            % Get the controls
            statusLabel = testCase.Widget.StatusTextLabel;
            timeLabel = testCase.Widget.RemTimeLabel;
            
            % Get widget size
            wPos = getpixelposition(testCase.Widget);
            
            % Verify starting bar is empty
            pos = getpixelposition(testCase.Widget.ProgressPanel);
            testCase.verifyEqual(pos(3), 0)
            
            
            % Start
            testCase.verifyMethod("startProgress")
            
            % Start with message
            message = "Now started";
            testCase.verifyMethod("startProgress", message)
            
            % Verify text and time
            testCase.verifyMatches(statusLabel.Text, message)
            testCase.verifyEqual(testCase.Widget.RemainingTime, seconds(inf))
            
            
            % Update 1
            pause(2)
            value = 0.3;
            message = "";
            testCase.verifyMethod(@setProgress, value)
            
            % Verify bar size
            % drawnow
            % pos = getpixelposition(testCase.Widget.ProgressPanel);
            % testCase.verifyGreaterThan(pos(3), wPos(3)/10)
            % testCase.verifyLessThan(pos(3), wPos(3)/2)
            
            % Verify text and time
            actVal = string(strtrim(statusLabel.Text));
            testCase.verifyEqual(actVal, message)
            remTime = testCase.Widget.RemainingTime;
            testCase.verifyGreaterThanOrEqual(remTime, seconds(3))

            
            % Update 2 with message
            pause(2)
            value = 0.6;
            message = "60% Complete";
            testCase.verifyMethod(@setProgress, value, message)
            
            % Verify bar size
            % drawnow
            % pos = getpixelposition(testCase.Widget.ProgressPanel);
            % testCase.verifyGreaterThan(pos(3), wPos(3)/2)
            % testCase.verifyLessThan(pos(3), wPos(3))
            
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
            
            % Verify bar size
            % drawnow
            % pos = getpixelposition(testCase.Widget.ProgressPanel);
            % testCase.verifyEqual(pos(3), 0)
            
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
        
        end %function
            
        
        function testShowCancel(testCase)
        
        end %function
            
        
        function testShowTimeRemaining(testCase)
        
        end %function
        
    end %methods (Test)
    
end %classdef