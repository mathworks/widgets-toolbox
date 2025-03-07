classdef DatetimeSelector < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
%   Copyright 2021-2025 The MathWorks Inc.
    
    
    
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

            % Get the widget
            w = testCase.Widget;
            
            % Toggle seconds and AM/PM
            testCase.verifySetProperty("ShowSeconds", matlab.lang.OnOffSwitchState.on);
            testCase.verifySetProperty("ShowAMPM", matlab.lang.OnOffSwitchState.off);
            
            % Set the value
            dt = datetime("now","TimeZone","local");
            testCase.verifySetProperty("Value", dt);
            drawnow
            
            % Verify the value
            testCase.verifyEqual(w.DateControl.Value.Month, dt.Month);
            testCase.verifyEqual(w.DateControl.Value.Year, dt.Year);
            testCase.verifyEqual(w.DateControl.Value.Day, dt.Day);
            testCase.verifyEqual(w.HourControl.Value, dt.Hour);
            testCase.verifyEqual(w.MinuteControl.Value, dt.Minute);
            testCase.verifyEqual(w.SecondControl.Value, dt.Second);
            
        end %function
        
            
        function testRollOver(testCase)

            % Get the widget
            w = testCase.Widget;
            
            % Toggle seconds and AM/PM
            testCase.verifySetProperty("ShowSeconds", matlab.lang.OnOffSwitchState.on);
            testCase.verifySetProperty("ShowAMPM", matlab.lang.OnOffSwitchState.on);
            
            % Get the controls
            dateControl = w.DateControl;
            hourControl = w.HourControl;
            minuteControl = w.MinuteControl;
            secondControl = w.SecondControl;
            amPmControl = w.AmPmControl;
            
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
            actVal = w.Value;
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
            actVal = w.Value;
            testCase.verifyEqual(actVal, dt_0 + hours(1));
            drawnow
            testCase.verifyEqual(dateControl.Value, dt_0);
            testCase.verifyEqual(hourControl.Value, 1);
            testCase.verifyEqual(minuteControl.Value, 0);
            testCase.verifyEqual(secondControl.Value, 0);
            testCase.verifyEqual(amPmControl.Value, 'AM');
            
            % Roll the seconds back by one
            testCase.press(secondControl,"down");
            actVal = w.Value;
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
            actVal = w.Value;
            testCase.verifyEqual(actVal, dt_12 - minutes(1));
            drawnow
            testCase.verifyEqual(dateControl.Value, dt_0);
            testCase.verifyEqual(hourControl.Value, 11);
            testCase.verifyEqual(minuteControl.Value, 59);
            testCase.verifyEqual(secondControl.Value, 00);
            testCase.verifyEqual(amPmControl.Value, 'AM');
            
        end %function

            
        function testTimeZoneName(testCase)

            % Get the widget
            w = testCase.Widget;

            % Set to 24-hour format to easily verify hours displayed
            %testCase.verifySetProperty("ShowAMPM", matlab.lang.OnOffSwitchState.off);
            
            % Toggle timezone field
            testCase.verifySetProperty("ShowTimeZone", matlab.lang.OnOffSwitchState.on);
            
            % Set the value using local time
            dt = datetime("now","TimeZone","local");
            testCase.verifySetProperty("Value", dt);
            testCase.verifyTimeZoneDisplay();


            % Change the time zone programmatically
            w.Value.TimeZone = "Europe/Amsterdam";
            testCase.verifyTimeZoneDisplay();


            % Change the time zone interactively
            expValue = "America/Los_Angeles";
            selIdx = find( contains(w.TimeZoneControl.Items, expValue), 1);
            selValue = w.TimeZoneControl.Items{selIdx};
            testCase.choose(w.TimeZoneControl, selValue)
            testCase.verifyTimeZoneDisplay();

            % Verify the Value field was updated
            actValue = string(w.Value.TimeZone);
            testCase.verifyMatches(actValue, expValue)
            
        end %function

            
        function testTimeZoneOffsetOnly(testCase)

            % Get the widget
            w = testCase.Widget;

            % Set to 24-hour format to easily verify hours displayed
            %testCase.verifySetProperty("ShowAMPM", matlab.lang.OnOffSwitchState.off);
            
            % Toggle timezone field
            testCase.verifySetProperty("ShowTimeZone", matlab.lang.OnOffSwitchState.on);
            
            % Set the value using local time
            dt = datetime("now","TimeZone","-03:00");
            testCase.verifySetProperty("Value", dt);
            testCase.verifyTimeZoneDisplay();

            % Change the time zone programmatically
            w.Value.TimeZone = "+13:00";
            testCase.verifyTimeZoneDisplay();


            % Change the time zone programmatically
            w.Value.TimeZone = "+00:00";
            testCase.verifyTimeZoneDisplay();

            
            % Change the time zone interactively
            expValue = "-05:00";
            testCase.choose(w.TimeZoneControl, expValue)
            testCase.verifyTimeZoneDisplay();

            % Verify the Value field was updated
            actValue = string(w.Value.TimeZone);
            testCase.verifyMatches(actValue, expValue)
            
        end %function

            
        function testTimeZoneSwitchingFormat(testCase)

            % Get the widget
            w = testCase.Widget;

            % Set to 24-hour format to easily verify hours displayed
            %testCase.verifySetProperty("ShowAMPM", matlab.lang.OnOffSwitchState.off);
            
            % Toggle timezone field
            testCase.verifySetProperty("ShowTimeZone", matlab.lang.OnOffSwitchState.on);
            
            % Set the value using local time
            dt = datetime("now","TimeZone","local");
            testCase.verifySetProperty("Value", dt);
            testCase.verifyTimeZoneDisplay();
            
            w.Value.TimeZone = "+12:45";
            testCase.verifyTimeZoneDisplay();
            
            w.Value.TimeZone = "America/Los_Angeles";
            testCase.verifyTimeZoneDisplay();

            w.Value.TimeZone = "-09:30";
            testCase.verifyTimeZoneDisplay();

            w.Value.TimeZone = "";
            testCase.verifyTimeZoneDisplay();

            w.Value.TimeZone = "+00:00";
            testCase.verifyTimeZoneDisplay();
            
            w.Value.TimeZone = "local";
            testCase.verifyTimeZoneDisplay();
            
        end %function
            

        function testNaTValue(testCase)

            % Get the widget
            w = testCase.Widget;
            
            % Toggle settings
            testCase.verifySetProperty("ShowSeconds", matlab.lang.OnOffSwitchState.on);
            testCase.verifySetProperty("ShowAMPM", matlab.lang.OnOffSwitchState.on);
            testCase.verifySetProperty("ShowTimeZone", matlab.lang.OnOffSwitchState.on);
            

            % Set the value to NaT
            dt = NaT;
            testCase.verifySetProperty("Value", dt);
            

            % Verify the expected values for NaT
            testCase.verifyEqual(w.DateControl.Value, NaT);
            testCase.verifyEqual(w.HourControl.Value, 12);
            testCase.verifyEqual(w.MinuteControl.Value, 0);
            testCase.verifyEqual(w.SecondControl.Value, 0);
            testCase.verifyEqual(w.AmPmControl.Value, 'AM');
            testCase.verifyEqual(w.TimeZoneControl.Value, "");


            % Select a date interactively to remove the NaT
            newDate = datetime("11/21/2022");
            testCase.type(w.DateControl, newDate)

            % Verify the expected values
            testCase.verifyTimeZoneDisplay();
            testCase.verifyEqual(w.DateControl.Value.Month, w.Value.Month);
            testCase.verifyEqual(w.DateControl.Value.Year, w.Value.Year);
            testCase.verifyEqual(w.DateControl.Value.Day, w.Value.Day);
            testCase.verifyEqual(w.HourControl.Value, 12);
            testCase.verifyEqual(w.MinuteControl.Value, 0);
            testCase.verifyEqual(w.SecondControl.Value, 0);
            testCase.verifyEqual(w.AmPmControl.Value, 'AM');


            % Set the value to NaT
            dt = NaT;
            testCase.verifySetProperty("Value", dt);

            
            % Set the time interactively to remove the NaT
            testCase.press(w.HourControl, "up")

            % Verify the expected values
            testCase.verifyTimeZoneDisplay();
            testCase.verifyEqual(w.HourControl.Value, 1);
            testCase.verifyEqual(w.MinuteControl.Value, 0);
            testCase.verifyEqual(w.SecondControl.Value, 0);
            testCase.verifyEqual(w.AmPmControl.Value, 'AM');

        end %function
        
    end %methods (Test)
    
%% Helper Methods
methods
    
    function verifyTimeZoneDisplay(testCase, expVal)
        % Verify the time zone display matches correctly the Value field

        arguments
            testCase
            expVal (1,1) string = testCase.Widget.Value.TimeZone
        end

        % Give a moment for any display updates
        pause(0.01);
        drawnow

        % Verify correct timezone is selected
        actVal = string(testCase.Widget.TimeZoneControl.Value);
        testCase.verifyEqual(actVal, expVal);

    end %function

end %methods


end %classdef

