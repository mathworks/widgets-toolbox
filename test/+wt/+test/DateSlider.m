classdef DateSlider < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component

    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            % Call superclass method
            testCase.setup@wt.test.BaseWidgetTest();

            % Setup widget
            fcn = @()wt.DateSlider(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            
            % Set callback
            testCase.Widget.ValueChangedFcn = @(s,e)onCallbackTriggered(testCase,e);
            
            % Ensure it renders
            drawnow
            
        end %function
        
    end %methods
    
    %% Unit Tests
    methods (Test)
        
        function testValuePropertyAndBoundaries(testCase)
            
            % Set the value
            newValue = datetime("01-Jan-2020");
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValue(newValue);
            
            % Set the value
            newValue = datetime("03-Jan-2020");
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValue(newValue);
            
            % Configure the control
            newLimits = datetime("today") + [-days(20) days(15)];
            testCase.verifySetProperty("Limits", newLimits);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyControlValue(newLimits(1));

            % Set the value within limits
            newValue = datetime("today") + days(15);
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValue(newValue);
            
            % Change the limits out of bounds
            newLimits = datetime("today") + [days(20) days(30)];
            testCase.verifySetProperty("Limits", newLimits);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyControlValue(newLimits(1));
           
            % Set an invalid value
            expValue = datetime("today") + days(20);
            invldValue = datetime("today") + days(31);
            testCase.verifySetPropertyError("Value", invldValue, 'MATLAB:ui:DatePicker:valueNotValid');
            testCase.verifyControlValue(expValue);
            
            % Set an invalid value
            expValue = datetime("today") + days(20);
            invldValue = datetime("today") + days(15);
            testCase.verifySetPropertyError("Value", invldValue, 'MATLAB:ui:DatePicker:valueNotValid');
            testCase.verifyControlValue(expValue);
            
            % Configure a simple range
            newLimits = datetime("today") + [days(0) days(10)];
            testCase.verifySetProperty("Limits", newLimits);
            testCase.verifyControlLimits(newLimits);
    
            % Expect index 1 -> min date, index 11 -> max date
            testCase.verifySetProperty("ValueIndex", 1);
            testCase.verifyControlValue(newLimits(1));
            testCase.verifySetProperty("ValueIndex", 11);
            testCase.verifyControlValue(newLimits(2));
    
            % Out-of-bounds should error
            testCase.verifySetPropertyError("ValueIndex", -1, 'MATLAB:validators:mustBeInRange');
            testCase.verifySetPropertyError("ValueIndex", 12, 'MATLAB:validators:mustBeInRange');

        end %function
        
        function testDatepicker(testCase)
    
            % Configure the control
            newLimits = datetime("today") + [-days(20) days(15)];
            testCase.verifySetProperty("Limits", newLimits);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyControlValue(newLimits(1));

            % Enable the datepicker to be able to type
            testCase.Widget.Datepicker.Editable = true;

            % Pick a date using datepicker
            newValue = datetime("today") + days(15);
            testCase.verifyTypeAction(testCase.Widget.Datepicker, newValue, "Value")
            testCase.verifyEqual(testCase.Widget.Value, newValue)
            testCase.verifyCallbackCount(1);

            newValue = datetime("today") + days(10);
            testCase.verifyTypeAction(testCase.Widget.Datepicker, newValue, "Value")
            testCase.verifyEqual(testCase.Widget.Value, newValue)
            testCase.verifyCallbackCount(2);

            % Pick an out-of-range date using datepicker
            invldValue = datetime("today") + days(20);
            testCase.verifyTypeAction(testCase.Widget.Datepicker, invldValue, "Value", newValue)
            testCase.verifyEqual(testCase.Widget.Value, newValue)
            testCase.verifyCallbackCount(2);

            % Change date using value property
            newValue = datetime("today") - days(20);
            testCase.verifySetProperty("Value", newValue)
            testCase.verifyEqual(testCase.Widget.Datepicker.Value, newValue)
            testCase.verifyCallbackCount(2);

        end

        function testDatepickerButtons(testCase)

            % Configure the control
            newLimits = datetime("today") + [days(0) days(10)];
            testCase.verifySetProperty("Limits", newLimits);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyControlValue(newLimits(1));

            % Verify buttons enabled state
            testCase.verifyButtonsEnabled([true false])

            % Push down is disabled
            testCase.verifyButtonPushAction("down", newLimits(1))
            testCase.verifyCallbackCount(0);

            % Push the button up once
            testCase.verifyButtonPushAction("up", newLimits(1) + days(1))
            testCase.verifyButtonsEnabled([true true])
            testCase.verifyCallbackCount(1);

            % Change step size and push down
            testCase.Widget.Step = caldays(4);
            testCase.verifyButtonPushAction("down", newLimits(1))
            testCase.verifyButtonsEnabled([true false])
            testCase.verifyCallbackCount(2);

            % Push up
            testCase.verifyButtonPushAction("up", newLimits(1) + days(4))
            testCase.verifyButtonPushAction("up", newLimits(1) + days(8))
            testCase.verifyButtonPushAction("up", newLimits(2))
            testCase.verifyCallbackCount(5);

            % Push up disabled at this point
            testCase.verifyButtonsEnabled([false true])
            testCase.verifyButtonPushAction("up", newLimits(2))
            testCase.verifyCallbackCount(5);

        end

        function testValueChangingEventOnDrag(testCase)
            % Attach ValueChanging callback to count intermediate events

            % Add ValueChanging callback function only for this test
            testCase.Widget.ValueChangingFcn = @(s,e)onCallbackTriggered(testCase,e);

            % Configure range
            newLimits = datetime("today") + [days(0) days(50)];
            testCase.verifySetProperty("Limits", newLimits);
    
            % Drag the slider; ValueChanging should fire at least once
            sliderControl = testCase.Widget.Slider;
            startValue = 5; newValue = 25;
            testCase.drag(sliderControl, startValue, newValue);
    
            % We don't assert exact count (depends on platform), just > 1
            testCase.verifyTrue(testCase.CallbackCount > 1);
        end %function

        function testStepWithCalendarMonths(testCase)
            % Configure range across months
            base = datetime(2020,1,1);
            newLimits = base + [days(0) calmonths(2)]; % Jan 1 .. Mar 1 (approx)
            testCase.verifySetProperty("Limits", newLimits);
            testCase.verifyControlLimits(newLimits);
            testCase.verifySetProperty("Value", newLimits(1));
            testCase.verifyControlValue(newLimits(1));
    
            % Set step to one calendar month, start at min
            testCase.verifySetProperty("Step", calmonths(1));
    
            % Push 'up' twice: Jan->Feb->Mar (clamped at max)
            testCase.verifyButtonPushAction("up", base + calmonths(1));
            testCase.verifyButtonPushAction("up", newLimits(2));
    
            % Push 'down' twice: back to Feb->Jan
            testCase.verifyButtonPushAction("down", base + calmonths(1));
            testCase.verifyButtonPushAction("down", newLimits(1));
        end %function

        function testButtonsEnabledMidRange(testCase)
            % In mid-range both buttons must be enabled
            newLimits = datetime("today") + [days(0) days(10)];
            testCase.verifySetProperty("Limits", newLimits);
            mid = newLimits(1) + days(5);
            testCase.verifySetProperty("Value", mid);
            testCase.verifyButtonsEnabled([true true]);
        end %function

        function testLimitsNormalizationToStartOfDay(testCase)
            % Provide limits with non-midnight time components
            d1 = dateshift(datetime("today"), 'start', 'day') + hours(10);
            d2 = d1 + days(3) + hours(12);            
            testCase.verifySetProperty("Limits", [d1 d2], [d1 d2 ] - timeofday([d1 d2]));
        end %function
        
        function testTickLabels(testCase)

            % Change the limits
            expValue = datetime("today") + days(5);
            newLimits = datetime("today") + [days(5) days(10)];
            testCase.verifySetProperty("Limits", newLimits);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyControlValue(newLimits(1));

            % Check tick labels
            expLabels = string(datetime("today") + days(5:10));
            actualLabels = testCase.Widget.Slider.MajorTickLabels;
            actualLabels = convertCharsToStrings(actualLabels(1:min(6, numel(actualLabels))));

            testCase.verifyEqual(actualLabels, expLabels)

            % Change the limits
            newLimits = datetime("today") + [days(0) days(10)];
            testCase.verifySetProperty("Limits", newLimits);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyControlValue(expValue);

            % Change datepicker size so that slider barely fits
            testCase.Widget.DatepickerSize = 240;

            % Check widgets exist
            expLabels = string(datetime("today") + days([0 5 10]));
            actualLabels = testCase.Widget.Slider.MajorTickLabels;
            actualLabels = convertCharsToStrings(actualLabels(1:min(3, numel(actualLabels))));

            testCase.verifyEqual(actualLabels, expLabels)
            
        end %function               
        
        function testSlider(testCase)
            
            % Configure the control
            newLimits = datetime("today") + [days(0) days(100)];
            testCase.verifySetProperty("Limits", newLimits);
            testCase.verifyControlLimits(newLimits);

            % Get the control
            sliderControl = testCase.Widget.Slider;
                        
            % Click the slider
            newValue = 75;
            expValue = datetime("today") + days(newValue - 1);
            testCase.choose(sliderControl,newValue);
            testCase.verifyControlValue(expValue);
            testCase.verifyEqual(testCase.Widget.Value, expValue);
            
            % Verify callback triggered
            testCase.verifyEqual(testCase.CallbackCount, 1)            
            
            % Drag the slider
            startValue = 1;
            newValue = 32;
            expValue = datetime("today") + days(newValue - 1);
            testCase.drag(sliderControl,startValue,newValue);
            testCase.verifyControlValue(expValue);
            testCase.verifyEqual(testCase.Widget.Value, expValue);
            
            % Verify callback triggered
            testCase.verifyEqual(testCase.CallbackCount, 2)

            % Drag the slider to a fraction (with rounding turned on)
            startValue = 32;
            newValue = 13.8;
            expValue = datetime("today") + days(round(newValue - 1));
            testCase.drag(sliderControl,startValue,newValue);
            testCase.verifyControlValue(expValue);
            testCase.verifyEqual(testCase.Widget.Value, expValue);

            % Verify callback triggered
            testCase.verifyEqual(testCase.CallbackCount, 3)
            
        end %function
        
        function testOrientationVerticalLayout(testCase)
            % Switch to vertical orientation
            testCase.verifySetProperty("Orientation", wt.enum.HorizontalVerticalState.vertical);
    
            % Slider orientation must change
            testCase.verifyEquality(testCase.Widget.Slider.Orientation, "vertical");
    
            % Layout positions should match update() vertical branch
            drawnow
            testCase.verifyEqual(testCase.Widget.Datepicker.Layout.Row, 2);
            testCase.verifyEqual(testCase.Widget.Datepicker.Layout.Column, 1);
            testCase.verifyEqual(testCase.Widget.GridButtons.Layout.Row, 2);
            testCase.verifyEqual(testCase.Widget.GridButtons.Layout.Column, 2);
    
            % DatepickerSize affects height in vertical orientation
            testCase.verifySetProperty("DatepickerSize", 180);
            drawnow
            % Grid.RowHeight should include DatepickerSize as second row
            testCase.verifyEqual(testCase.Widget.Grid.RowHeight{2}, 180);
        end %function

        function testDisplayFormatPropagationAndTicks(testCase)
            % Change the display format
            fmt = "uuuu-MM-dd";
            testCase.Widget.DisplayFormat = fmt;
            drawnow
    
            % Verify propagation to datepicker and limits
            testCase.verifyEquality(testCase.Widget.Datepicker.DisplayFormat, fmt);
            testCase.verifyEquality(testCase.Widget.Limits.Format, fmt);
    
            % Ticks/labels should be updated (non-empty categorical labels)
            drawnow
            labels = testCase.Widget.Slider.MajorTickLabels;
            testCase.verifyTrue(~isempty(labels));
        end %function

    end %methods (Test)
    
    %% Helper methods
    methods (Access = private)
        
        function verifyControlValue(testCase, dateValue, absTol)
            % Verifies the control fields have the specified value

            arguments
                testCase
                dateValue (1,1) datetime
                absTol (1,1) double = 0
            end
            
            drawnow

            numValue = days(dateValue - testCase.Widget.Limits(1)) + 1;
            testCase.verifyEqual(testCase.Widget.Slider.Value, numValue, 'AbsTol', absTol);
            testCase.verifyEqual(testCase.Widget.Datepicker.Value, dateValue, 'AbsTol', absTol);
            
        end %function

        function verifyControlLimits(testCase, dateLimits, absTol)
            % Verifies the control fields have the specified limit

            arguments
                testCase
                dateLimits (1,2) datetime
                absTol (1,1) double = 0
            end

            drawnow

            numLimits = [0 days(dateLimits(2) - dateLimits(1))] + 1;
            testCase.verifyEqual(testCase.Widget.Slider.Limits, numLimits, 'AbsTol', absTol);
            testCase.verifyEqual(testCase.Widget.Datepicker.Limits, dateLimits, 'AbsTol', absTol);

        end %function

        function verifyButtonsEnabled(testCase, enabledStatus)
            % Verifies the control buttons have the specified enable status

            arguments
                testCase
                enabledStatus (1,2) matlab.lang.OnOffSwitchState = [true true]
            end

            testCase.verifyEqual([testCase.Widget.Buttons.Enable], enabledStatus);
        end %function

        function verifyButtonPushAction(testCase, direction, expValue)
            
            arguments
                testCase
                direction (1,1) string {mustBeMember(direction, ["up", "down"])}
                expValue (1,1) datetime
            end
           
            if direction == "up"
                buttonIdx = 1;
            else
                buttonIdx = 2;
            end

            % Type the new value into the control
            testCase.press(testCase.Widget.Buttons(buttonIdx));
            
            % Verify new property value
            testCase.verifyControlValue(expValue);
            
        end %function
        
    end %methods

end %classdef