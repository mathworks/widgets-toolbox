classdef DatetimeSelector < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
    % Copyright 2021 The MathWorks, Inc.
    
    
    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            fcn = @()wt.DatetimeSelector(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            drawnow
            
        end %function
        
    end %methods
    
    
    %% Unit Tests
    methods (Test)
            
        function testValueProperty(testCase)
            
            % Toggle seconds and AM/PM
            testCase.verifySetProperty("ShowSeconds", matlab.lang.OnOffSwitchState.on);
            testCase.verifySetProperty("ShowAMPM", matlab.lang.OnOffSwitchState.off);
            
            % Set the value
            dt = datetime("now");
            testCase.verifySetProperty("Value", dt);
            drawnow
            
            % Verify the value
            testCase.verifyEqual(testCase.Widget.DateControl.Value.Month, dt.Month);
            testCase.verifyEqual(testCase.Widget.DateControl.Value.Year, dt.Year);
            testCase.verifyEqual(testCase.Widget.DateControl.Value.Day, dt.Day);
            testCase.verifyEqual(testCase.Widget.HourControl.Value, dt.Hour);
            testCase.verifyEqual(testCase.Widget.MinuteControl.Value, dt.Minute);
            testCase.verifyEqual(testCase.Widget.SecondControl.Value, dt.Second);
            
        end %function
        
            
        function testRollOver(testCase)
            
            % Toggle seconds and AM/PM
            testCase.verifySetProperty("ShowSeconds", matlab.lang.OnOffSwitchState.on);
            testCase.verifySetProperty("ShowAMPM", matlab.lang.OnOffSwitchState.on);
            
            % Get the controls
            dateControl = testCase.Widget.DateControl;
            hourControl = testCase.Widget.HourControl;
            minuteControl = testCase.Widget.MinuteControl;
            secondControl = testCase.Widget.SecondControl;
            amPmControl = testCase.Widget.AmPmControl;
            
            % Use a value of today 12AM
            dt_0 = datetime("today");
            testCase.assumeEqual(dt_0.Hour, 0);
            testCase.assumeEqual(dt_0.Minute, 0);
            testCase.assumeEqual(dt_0.Second, 0);
            
           % Set the value and verify
            testCase.verifySetProperty("Value", dt_0);
            drawnow
            testCase.verifyEqual(dateControl.Value, dt_0);
            testCase.verifyEqual(hourControl.Value, 12);
            testCase.verifyEqual(minuteControl.Value, 0);
            testCase.verifyEqual(secondControl.Value, 0);
            testCase.verifyEqual(amPmControl.Value, 'AM');
            
            % Roll down the hour by one to 11PM yesterday
            testCase.press(hourControl,"down");
            actVal = testCase.Widget.Value;
            testCase.verifyEqual(actVal, dt_0 - hours(1));
            drawnow
            testCase.verifyEqual(dateControl.Value, dt_0 - days(1)); %datepicker strips the time
            testCase.verifyEqual(hourControl.Value, 11);
            testCase.verifyEqual(minuteControl.Value, 0);
            testCase.verifyEqual(secondControl.Value, 0);
            testCase.verifyEqual(amPmControl.Value, 'PM');
            
            % Roll down the hour up two to 1AM today
            testCase.press(hourControl,"up");
            testCase.press(hourControl,"up");
            actVal = testCase.Widget.Value;
            testCase.verifyEqual(actVal, dt_0 + hours(1));
            drawnow
            testCase.verifyEqual(dateControl.Value, dt_0);
            testCase.verifyEqual(hourControl.Value, 1);
            testCase.verifyEqual(minuteControl.Value, 0);
            testCase.verifyEqual(secondControl.Value, 0);
            testCase.verifyEqual(amPmControl.Value, 'AM');
            
            % Roll the seconds back by one
            testCase.press(secondControl,"down");
            actVal = testCase.Widget.Value;
            testCase.verifyEqual(actVal, dt_0 + hours(1) - seconds(1));
            drawnow
            testCase.verifyEqual(dateControl.Value, dt_0);
            testCase.verifyEqual(hourControl.Value, 12);
            testCase.verifyEqual(minuteControl.Value, 59);
            testCase.verifyEqual(secondControl.Value, 59);
            testCase.verifyEqual(amPmControl.Value, 'AM');
            
            % Use a value of today 12PM
            dt_12 = datetime("today") + hours(12);
            testCase.assumeEqual(dt_12.Hour, 12);
            testCase.assumeEqual(dt_12.Minute, 0);
            testCase.assumeEqual(dt_12.Second, 0);
            
           % Set the value and verify
            testCase.verifySetProperty("Value", dt_12);
            drawnow
            testCase.verifyEqual(dateControl.Value, dt_0); %datepicker strips the time
            testCase.verifyEqual(hourControl.Value, 12);
            testCase.verifyEqual(minuteControl.Value, 0);
            testCase.verifyEqual(secondControl.Value, 0);
            testCase.verifyEqual(amPmControl.Value, 'PM');
            
            % Roll the minutes back by one
            testCase.press(minuteControl,"down");
            actVal = testCase.Widget.Value;
            testCase.verifyEqual(actVal, dt_12 - minutes(1));
            drawnow
            testCase.verifyEqual(dateControl.Value, dt_0);
            testCase.verifyEqual(hourControl.Value, 11);
            testCase.verifyEqual(minuteControl.Value, 59);
            testCase.verifyEqual(secondControl.Value, 00);
            testCase.verifyEqual(amPmControl.Value, 'AM');
            
        end %function
        
    end %methods (Test)
    
end %classdef