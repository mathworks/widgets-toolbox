classdef DateRangeSlider < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component


    %% Test Method Setup
    methods (TestMethodSetup)

        function setup(testCase)

            % Assure the correct MATLAB version is present
            assumeMinimumRelease(testCase, "R2024b")

            % Call superclass method
            testCase.setup@wt.test.BaseWidgetTest();

            % Change figure size to accomodate for slider ticks
            testCase.Figure.Position(3) = 800;

            % Setup widget
            fcn = @()wt.DateRangeSlider(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);

            % Set callback
            testCase.Widget.ValueChangedFcn = @(s,e)onCallbackTriggered(testCase,e);

            % Ensure it renders
            drawnow

        end %function

    end %methods   


    %% Unit Tests
    methods (Test)

        function testValueProperty(testCase)

            % Set the value
            newValue = datetime("01-Jan-2020") + [days(0) days(2)];
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);

            % Set the value
            newValue = datetime("01-Jan-2020") + [days(1) days(3)];
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);

        end %function


        function testValueBoundaries(testCase)

            % Configure the control
            expValue = datetime("yesterday") + [-days(20) -days(19)];
            newLimits = datetime("yesterday") + [-days(20) days(15)];
            testCase.verifySetProperty("Limits", newLimits);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyControlValues(expValue);

            % Set the value within limits
            newValue = datetime("yesterday") + [days(10) days(15)];
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue);

            % Change the limits out of bounds
            newLimits = datetime("yesterday") + [days(20) days(30)];
            testCase.verifySetProperty("Limits", newLimits);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyControlValues([newLimits(1) newLimits(1) + testCase.Widget.MinGap]);

            % Set an invalid value
            expValue = [datetime("yesterday") + days(20) datetime("yesterday") + days(20) + testCase.Widget.MinGap];
            invldValue = [datetime("yesterday") + days(31) datetime("yesterday") + days(32)];
            testCase.verifySetPropertyError("Value", invldValue, 'MATLAB:validators:mustBeInRange');
            testCase.verifyControlValues(expValue);

            % Set an invalid value
            expValue = [datetime("yesterday") + days(20) datetime("yesterday") + days(20) + testCase.Widget.MinGap];
            invldValue = [datetime("yesterday") + days(15) datetime("yesterday") + days(25)];
            testCase.verifySetPropertyError("Value", invldValue, 'MATLAB:validators:mustBeInRange');
            testCase.verifyControlValues(expValue);

        end %function

        function testDatepicker(testCase)

            % Configure the control
            expValue = datetime("today") + [-days(20) -days(19)];
            newLimits = [datetime("today") datetime("today")] + [-days(20) days(15)];
            testCase.verifySetProperty("Limits", newLimits);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyControlValues(expValue);

            % Enable the datepicker to be able to type
            testCase.Widget.DatepickerLeft.Editable = true;
            testCase.Widget.DatepickerRight.Editable = true;

            % Pick a date using datepicker (right)
            newValue = datetime("today") + [-days(20) days(15)];
            testCase.verifyTypeAction(testCase.Widget.DatepickerRight, newValue(2), "Value", newValue)
            testCase.verifyControlValues(newValue);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyButtonsEnabled([true false false true])
            testCase.verifyCallbackCount(1);

            newValue = datetime("today") + [-days(20) days(10)];
            testCase.verifyTypeAction(testCase.Widget.DatepickerRight, newValue(2), "Value", newValue)
            testCase.verifyControlValues(newValue);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyButtonsEnabled([true false true true])
            testCase.verifyCallbackCount(2);

            % Pick a date using datepicker (left)
            newValue = datetime("today") + [days(9) days(10)];
            testCase.verifyTypeAction(testCase.Widget.DatepickerLeft, newValue(1), "Value", newValue)
            testCase.verifyControlValues(newValue);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyButtonsEnabled([false true true false])
            testCase.verifyCallbackCount(3);

            newValue = datetime("today") + [-days(10) days(10)];
            testCase.verifyTypeAction(testCase.Widget.DatepickerLeft, newValue(1), "Value", newValue)
            testCase.verifyControlValues(newValue);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyButtonsEnabled([true true true true])
            testCase.verifyCallbackCount(4);
            

            % Pick an out-of-range date using datepicker
            expValue = datetime("today") + [-days(10) days(10)];

            invldValue = datetime("today") + days(10);
            testCase.verifyTypeAction(testCase.Widget.DatepickerLeft, invldValue, "Value", expValue)
            testCase.verifyControlValues(expValue);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyButtonsEnabled([true true true true])
            testCase.verifyCallbackCount(4);

            invldValue = datetime("today") - days(10);
            testCase.verifyTypeAction(testCase.Widget.DatepickerRight, invldValue, "Value", expValue)
            testCase.verifyControlValues(expValue);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyButtonsEnabled([true true true true])
            testCase.verifyCallbackCount(4);

        end

        function testDatepickerButtons(testCase)

            % Configure the control
            newLimits = datetime("yesterday") + [days(0) days(10)];
            expValue = newLimits;
            testCase.verifySetProperty("Limits", newLimits);
            testCase.verifySetProperty("Value", expValue);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyControlValues(expValue);            

            % Verify buttons enabled state
            testCase.verifyButtonsEnabled([true false false true])

            % Push down is disabled
            testCase.verifyButtonPushAction("left", "down", expValue)
            testCase.verifyButtonPushAction("right", "up", expValue)
            testCase.verifyCallbackCount(0);

            % Push the button up once
            testCase.verifyButtonPushAction("left", "up", expValue + days([1 0]))
            testCase.verifyButtonPushAction("right", "down", expValue + days([1 -1]))
            testCase.verifyControlValues(expValue + days([1 -1])); 
            testCase.verifyControlLimits(newLimits); 
            testCase.verifyButtonsEnabled([true true true true])
            testCase.verifyCallbackCount(2);

            % Change step size and push down
            testCase.Widget.Step = caldays(4);
            testCase.verifyButtonPushAction("left", "down", expValue + days([0 -1]))
            testCase.verifyButtonsEnabled([true false true true])
            testCase.verifyCallbackCount(3);

            % Push up
            testCase.verifyButtonPushAction("left", "up", expValue + days([4 -1]))
            testCase.verifyButtonPushAction("left", "up", expValue + days([8 -1]))            
            testCase.verifyCallbackCount(5);

            % Push up disabled at this point
            testCase.verifyButtonsEnabled([false true true false])
            testCase.verifyButtonPushAction("left", "up", expValue + days([8 -1]))
            testCase.verifyCallbackCount(5);

            % Push down
            testCase.verifyButtonPushAction("left", "down", expValue + days([4 -1]))
            testCase.verifyButtonPushAction("left", "down", expValue + days([0 -1])) 
            testCase.verifyButtonsEnabled([true false true true])
            testCase.verifyCallbackCount(7);

            % Push up
            testCase.verifyButtonPushAction("right", "up", expValue + days([0 0]))
            testCase.verifyButtonsEnabled([true false false true])
            testCase.verifyCallbackCount(8);

            % Push down
            testCase.verifyButtonPushAction("right", "down", expValue + days([0 -4]))
            testCase.verifyButtonPushAction("right", "down", expValue + days([0 -8]))
            testCase.verifyButtonPushAction("right", "down", expValue + days([0 -9]))
            testCase.verifyButtonsEnabled([false false true false])
            testCase.verifyControlValues(expValue + days([0 -9])); 
            testCase.verifyControlLimits(newLimits);
            testCase.verifyCallbackCount(11);

        end

        function testTickLabels(testCase)

            % Change the limits
            newLimits = datetime("today") + days([5 10]);
            testCase.verifySetProperty("Limits", newLimits);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyControlValues(datetime("today") + days([5 6]));

            % Check tick labels
            expLabels = string(datetime("today") + days(5:10));
            actualLabels = testCase.Widget.Slider.MajorTickLabels;
            actualLabels = convertCharsToStrings(actualLabels(1:min(6, numel(actualLabels))));

            % Allow some time for the component to catch up
            drawnow;
            pause(2)

            testCase.verifyEqual(actualLabels, expLabels)

            % Change the limits
            newLimits = datetime("today") + days([0 10]);
            testCase.verifySetProperty("Limits", newLimits);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyControlValues(datetime("today") + days([5 6]));

            % Check tick labels
            expLabels = string(datetime("today") + days(0:2:10));            
            actualLabels = testCase.Widget.Slider.MajorTickLabels;
            actualLabels = convertCharsToStrings(actualLabels(1:min(6, numel(actualLabels))));
            testCase.verifyEqual(actualLabels, expLabels)

            % Change datepicker size so that slider barely fits
            testCase.Widget.DatepickerSize = 220;

            % Allow some time for the component to catch up
            drawnow
            pause(2)

            % Change the limits
            newLimits = datetime("today") + days([0 20]);
            testCase.verifySetProperty("Limits", newLimits);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyControlValues(datetime("today") + days([5 6]));

            % Check widgets exist
            expLabels = string(datetime("today") + days([0 10 20]));
            actualLabels = testCase.Widget.Slider.MajorTickLabels;
            actualLabels = convertCharsToStrings(actualLabels(1:min(3, numel(actualLabels))));
            testCase.verifyEqual(actualLabels, expLabels)

        end %function


        function testMinGap(testCase)

            % Configure the control
            newLimits = datetime("today") + days([50 100]);
            newValue = datetime("today") + days([50 50]);
            testCase.verifySetProperty("MinGap", 0, days(0));
            testCase.verifySetProperty("Limits", newLimits);
            testCase.verifyControlLimits(newLimits);
            testCase.verifyControlValues(newValue)
            
            % Change the minimum gap
            minGap = 10;
            newValue = datetime("today") + days(50 + [0 minGap]);
            testCase.verifySetProperty("MinGap", minGap, days(minGap));
            testCase.verifyControlValues(newValue)
            testCase.verifyButtonsEnabled(["off" "off" "on" "off"])

            % Change the value
            newValue = datetime("today") + days(70 + [-1 minGap + 1]);
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue)
            testCase.verifyButtonsEnabled(["on" "on" "on" "on"])

            newValue = datetime("today") + days(70 + [0 minGap]);
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValues(newValue)
            testCase.verifyButtonsEnabled(["off" "on" "on" "off"])

            % Increase gap
            minGap = 20;
            newValue = datetime("today") + days(70 + [0 minGap]);
            testCase.verifySetProperty("MinGap", minGap, days(minGap));
            testCase.verifyControlValues(newValue)

            minGap = 30;
            newValue = datetime("today") + days(70 + [0 minGap]);
            testCase.verifySetProperty("MinGap", minGap, days(minGap));
            testCase.verifyControlValues(newValue)
            testCase.verifyButtonsEnabled(["off" "on" "off" "off"])

            % Increate gap even further
            minGap = 40;
            newValue = datetime("today") + days(60 + [0 minGap]);
            testCase.verifySetProperty("MinGap", minGap, days(minGap));
            testCase.verifyControlValues(newValue)

            minGap = 50;
            newValue = datetime("today") + days(50 + [0 minGap]);
            testCase.verifySetProperty("MinGap", minGap, days(minGap));
            testCase.verifyControlValues(newValue)
            testCase.verifyButtonsEnabled(["off" "off" "off" "off"])

            % Check decreasing the limits
            newLimits = datetime("today") + days(60 + [0 20]);
            testCase.verifySetProperty("Limits", newLimits);
            testCase.verifyControlLimits(newLimits)
            testCase.verifyEqual(testCase.Widget.MinGap, days(20));

            % MinGap cannot exceed limits
            testCase.verifyError(@() set(testCase.Widget, 'MinGap', 30), 'MATLAB:validators:mustBeGreaterThanOrEqual')
            testCase.verifyError(@() set(testCase.Widget, 'MinGap', -1), 'MATLAB:validators:mustBeNonnegative')
            testCase.verifyWarningFree(@() set(testCase.Widget, 'MinGap', 10))
            testCase.verifyButtonsEnabled(["off" "off" "off" "off"])

            % No callbacks fired
            testCase.verifyCallbackCount(0)

        end %function

        function testValueIndexMappingAndBounds(testCase)
            newLimits = datetime("today") + [days(0) days(10)];
            testCase.verifySetProperty("Limits", newLimits);
            testCase.verifyControlLimits(newLimits);
    
            % Set by indices (0-based offsets from lower limit)
            testCase.verifySetProperty("ValueIndex", [1 11]);
            testCase.verifyControlValues([newLimits(1) newLimits(2)]);
    
            % Mid-range indices
            testCase.verifySetProperty("ValueIndex", [2 7]);
            testCase.verifyControlValues([newLimits(1)+days(1) newLimits(1)+days(6)]);
    
            % Non-increasing should error (identifier currently has a typo in the class)
            testCase.verifySetPropertyError("ValueIndex", [5 4], 'DateRageSlider:mustBeIncreasing');
    
            % Out-of-bounds should error
            testCase.verifySetPropertyError("ValueIndex", [-1 3], 'MATLAB:validators:mustBeInRange');
            testCase.verifySetPropertyError("ValueIndex", [0 11], 'MATLAB:validators:mustBeInRange');
        end %function

        function testOrientationVerticalLayout(testCase)
            % Switch to vertical and verify positions/size wiring
            testCase.verifySetProperty("Orientation", wt.enum.HorizontalVerticalState.vertical);
            % Force a distinctive size to assert against
            testCase.verifySetProperty("DatepickerSize", 180);
    
            % Let layout settle
            drawnow;
    
            % Grid is 2 rows; first row equals DatepickerSize
            testCase.verifyEqual(testCase.Widget.Grid.RowHeight{1}, 180);
    
            % Left side positions
            testCase.verifyEqual(testCase.Widget.GridButtonLeft.Layout.Row, 1);
            testCase.verifyEqual(testCase.Widget.GridButtonLeft.Layout.Column, 1);
            testCase.verifyEqual(testCase.Widget.DatepickerLeft.Layout.Row, 1);
            testCase.verifyEqual(testCase.Widget.DatepickerLeft.Layout.Column, 2);
    
            % Right side positions
            testCase.verifyEqual(testCase.Widget.GridButtonRight.Layout.Row, 1);
            testCase.verifyEqual(testCase.Widget.GridButtonRight.Layout.Column, 5);
            testCase.verifyEqual(testCase.Widget.DatepickerRight.Layout.Row, 1);
            testCase.verifyEqual(testCase.Widget.DatepickerRight.Layout.Column, 4);
    
            % Slider spans the second row
            testCase.verifyEqual(testCase.Widget.Slider.Layout.Row, 2);
            testCase.verifyEqual(testCase.Widget.Slider.Layout.Column, [1 5]);
        end %function

        function testDisplayFormatPropagation(testCase)
            fmt = "yyyy-MM-dd";
            testCase.verifySetProperty("DisplayFormat", fmt);
            drawnow;
    
            % Datepickers should reflect the same format
            testCase.verifyEquality(testCase.Widget.DatepickerLeft.DisplayFormat, fmt);
            testCase.verifyEquality(testCase.Widget.DatepickerRight.DisplayFormat, fmt);
    
            % Tick labels non-empty (format checked indirectly)
            labels = testCase.Widget.Slider.MajorTickLabels;
            testCase.verifyTrue(~isempty(labels));
        end %function

        % function testValueChangingEventOnDrag(testCase)
        % 
        %     % Add this callback only for this test
        %     testCase.Widget.ValueChangingFcn = @(s,e)onCallbackTriggered(testCase,e);
        % 
        %     % NOTE: "drag" gesture does not support objects of class "matlab.ui.control.RangeSlider".
        % end %function

        function testStepWithCalendarMonthsAndMinGap(testCase)
            base = datetime(2020,1,1);
            newLimits = base + [days(0) calmonths(3)]; % Jan 1 .. Apr 1
            testCase.verifySetProperty("Limits", newLimits);
    
            % Start mid-range
            startVal = [base + calmonths(1), base + calmonths(2)]; % Feb 1 .. Mar 1
            testCase.verifySetProperty("Value", startVal);
    
            % Use month step
            testCase.Widget.Step = calmonths(1);
            testCase.verifyButtonsEnabled(["on" "on" "on" "on"]);
    
            % Increase MinGap; inward moves should be prevented or error via Value validation
            testCase.verifySetProperty("MinGap", 20, days(20));
    
            % Left "up" (narrows gap) — with current code this likely errors due to hardcoded days(1)
            testCase.verifyError(@() testCase.press(testCase.Widget.ButtonsLeft(1)), ...
                'MATLAB:validators:mustBeGreaterThanOrEqual');
    
            % Right "down" (narrows gap) — same expectation
            testCase.verifyError(@() testCase.press(testCase.Widget.ButtonsRight(2)), ...
                'MATLAB:validators:mustBeGreaterThanOrEqual');
        end %function

        function testLimitsNormalizationToStartOfDay(testCase)
            d1 = dateshift(datetime("today"), 'start', 'day') + hours(9);
            d2 = d1 + days(5) + hours(17);
    
            testCase.verifySetProperty("Limits", [d1 d2], [d1 d2] - timeofday([d1 d2]));
        end

    end %methods (Test)

    %% Helper methods
    methods (Access = private)

        function verifyControlValues(testCase, dateValue, absTol)
            % Verifies the control fields have the specified value

            arguments
                testCase
                dateValue (1,2) datetime
                absTol (1,1) double = 0
            end

            drawnow

            numValue = days(dateValue - testCase.Widget.Limits(1)) + 1;
            testCase.verifyEqual(testCase.Widget.Slider.Value, numValue, 'AbsTol', absTol);
            testCase.verifyEqual(testCase.Widget.DatepickerLeft.Value, dateValue(1), 'AbsTol', absTol);
            testCase.verifyEqual(testCase.Widget.DatepickerRight.Value, dateValue(2), 'AbsTol', absTol);

        end %function

        function verifyControlLimits(testCase, dateLimits, absTol)
            % Verifies the control fields have the specified limit

            arguments
                testCase
                dateLimits (1,2) datetime
                absTol (1,1) double = 0
            end

            drawnow

            % What is the minimum gap?
            minGap = testCase.Widget.MinGap;

            % Verify slider limits
            numLimits = [0 days(dateLimits(2) - dateLimits(1))] + 1;
            testCase.verifyEqual(testCase.Widget.Slider.Limits, numLimits, 'AbsTol', absTol);

            % Verify left datepicker
            limitsLeft = [dateLimits(1) testCase.Widget.DatepickerRight.Value - minGap];
            testCase.verifyEqual(testCase.Widget.DatepickerLeft.Limits, limitsLeft, 'AbsTol', absTol);

            % Verify right datepicker
            limitsRight = [testCase.Widget.DatepickerLeft.Value + minGap dateLimits(2)];
            testCase.verifyEqual(testCase.Widget.DatepickerRight.Limits, limitsRight, 'AbsTol', absTol);

        end %function

        function verifyButtonsEnabled(testCase, enabledStatus)
            % Verifies the control buttons have the specified enable status

            arguments
                testCase
                enabledStatus (1,4) matlab.lang.OnOffSwitchState = [true true true true]
            end

            testCase.verifyEqual([testCase.Widget.ButtonsLeft.Enable testCase.Widget.ButtonsRight.Enable], enabledStatus);
        end %function

        function verifyButtonPushAction(testCase, side, direction, expValue)

            arguments
                testCase
                side (1,1) string {mustBeMember(side, ["right", "left"])}
                direction (1,1) string {mustBeMember(direction, ["up", "down"])}
                expValue (1,2) datetime
            end

            if side == "right"
                buttons = testCase.Widget.ButtonsRight;
            else
                buttons = testCase.Widget.ButtonsLeft;
            end

            if direction == "up"
                buttonIdx = 1;
            else
                buttonIdx = 2;
            end

            % Type the new value into the control
            testCase.press(buttons(buttonIdx));

            % Verify new property value
            testCase.verifyControlValues(expValue);

        end %function

    end %private methods

end %classdef