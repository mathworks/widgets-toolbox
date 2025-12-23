classdef DateRangeSlider < wt.abstract.BaseWidget & ...
        wt.mixin.TickableDateSlider & ...
        wt.mixin.Enableable & ...
        wt.mixin.FieldColorable & ...
        wt.mixin.FontStyled & ...
        wt.mixin.ButtonColorable
    % A slider and date-picker combination

    %% Events
    events (HasCallbackProperty, NotifyAccess = protected)

        % Triggered on value changed, has companion callback
        ValueChanged

        % Triggered on value changing during slider motion, has companion callback
        ValueChanging

        % Triggered on limits changed, has companion callback
        LimitsChanged

    end %events

    %% Public properties
    properties (AbortSet, Dependent, UsedInUpdate = false)
        % These properties do not trigger the update method

        % Value of the slider and date-time selector
        Value (1,2) datetime

    end

    properties (AbortSet)

        % Limits of the slider and spinner
        Limits (1,2) datetime = datetime("01-Jan-2020") + days([0 3]);

        % Date format
        DisplayFormat (1,1) string = 'dd-MMM-uuuu'

        % Orientation of the spinner and slider
        Orientation (1,1) wt.enum.HorizontalVerticalState = wt.enum.HorizontalVerticalState.horizontal

        % Size of date-picker (width for horizontal, height for vertical
        DatepickerSize = 120

    end %properties

    properties (AbortSet, Dependent, UsedInUpdate = false)

        % Minimum gap in value range (days)
        MinGap (1,1) double {mustBeNonnegative, mustBeInteger} = 1

    end

    properties (AbortSet, Dependent)

        % Index of selected item
        ValueIndex (1,2) double {mustBeInteger}

    end

    properties (AbortSet, UsedInUpdate = false)
    % These properties do not trigger the update method
    
        % Define step size for buttons
        Step (1,1) calendarDuration = calendarDuration(0,0,1)
    
    end   

    %% Internal Properties
    properties (Access = private)

        % Minimum gap
        MinGap_I = 1;

    end

    properties (Transient, NonCopyable, Hidden, SetAccess = protected)

        % Slider
        Slider = matlab.ui.control.RangeSlider.empty

        % Date picker on the left
        DatepickerLeft matlab.ui.control.DatePicker

        % Date picker on the right
        DatepickerRight matlab.ui.control.DatePicker

        % Button grid on the left
        GridButtonLeft matlab.ui.container.GridLayout
        ButtonsLeft (1,:) matlab.ui.control.Button

        % Button grid on the right
        GridButtonRight matlab.ui.container.GridLayout
        ButtonsRight (1,:) matlab.ui.control.Button

    end

    %% Accessors
    methods

        % ValueIndex
        function set.ValueIndex(obj, val)

            % Validate input
            maxRange = days(obj.Limits(2) - obj.Limits(1));
            try
                mustBeInRange(val, 0, maxRange)
                mustBeIncreasing(val)
            catch ME
                throwAsCaller(ME)
            end

            % Set value
            obj.Value = obj.Limits(1) + days(val);

        end %function
        function val = get.ValueIndex(obj)
            val = days([obj.DatepickerLeft.Value obj.DatepickerRight.Value] - obj.Limits(1));
        end %function

        % Value
        function set.Value(obj, val)

            % Validate input
            valueIndex = days(val - obj.Limits(1));
            valueGap = days(diff(val));
            maxRange = days(obj.Limits(2) - obj.Limits(1));
            try
                mustBeInRange(valueIndex, 0, maxRange)
                mustBeGreaterThanOrEqual(valueGap, days(obj.MinGap))
                mustBeIncreasing(valueIndex)                
            catch ME
                if strcmp(ME.identifier, 'MATLAB:validators:mustBeInRange')
                    msg = 'Value must be greater than or equal to %s, and less than or equal to %s.';
                    Merr = MException(ME.identifier, ...
                        msg, ...
                        char(obj.Limits(1)), ...
                        char(obj.Limits(2)));
                    throwAsCaller(Merr);
                elseif strcmp(ME.identifier, 'MATLAB:validators:mustBeGreaterThanOrEqual')
                    msg = 'Value gap must be greater than or equal to %d days.';
                    Merr = MException(ME.identifier, ...
                        msg, ...
                        days(obj.MinGap));
                    throwAsCaller(Merr);
                else
                    throwAsCaller(ME)
                end
            end

            % Update datepicker components
            updateControlLimitsAndValue(obj, val);

            % Update buttons
            updateButtonEnable(obj);

        end %function
        function val = get.Value(obj)
            val = [obj.DatepickerLeft.Value obj.DatepickerRight.Value];
        end %function

        % Display format
        function set.DisplayFormat(obj, val)
            try
                d = uidatepicker('Parent', []);
                d.DisplayFormat = val;
                obj.DisplayFormat = d.DisplayFormat;
            catch ME
                throwAsCaller(ME)
            end
        end %function

        % Limits
        function set.Limits(obj, val)
            startOfDay = dateshift(val, 'start', 'days');
            limitIndex = days(val - val(1));
            try
                mustBeIncreasing(limitIndex)
            catch ME
                throwAsCaller(ME)
            end
            obj.Limits = startOfDay;
        end %function

        % Gap
        function set.MinGap(obj, val)

            % Parse input
            if isduration(val)
                val = days(val);
            end

            % Validate input
            maxGap = days(diff(obj.Limits));
            try
                mustBeGreaterThanOrEqual(maxGap, val) 
            catch ME
                if strcmp(ME.identifier, 'MATLAB:validators:mustBeGreaterThanOrEqual')
                    msg = 'Value must be smaller than or equal to %d days.';
                    Merr = MException(ME.identifier, ...
                        msg, ...
                        maxGap);
                    throwAsCaller(Merr);
                else
                    throwAsCaller(ME)
                end
            end

            % Set value
            obj.MinGap_I = val;
        end

        function val = get.MinGap(obj)
            val = days(obj.MinGap_I);
        end

        % Datepicker size
        function set.DatepickerSize(obj, val)
            try
                g = uigridlayout("Parent", []);
                cleanup = onCleanup(@() delete(g));
                g.ColumnWidth{1} = val;
            catch ME
                throwAsCaller(ME)
            end
            obj.DatepickerSize = val;
        end %function

    end

    %% Protected methods
    methods (Access = protected)

        function setup(obj)

            % Call superclass method
            obj.setup@wt.abstract.BaseWidget()

            % Set default size
            obj.Position = [20 100 530 40];

            % Configure grid
            obj.Grid.ColumnWidth = {'fit', obj.DatepickerSize, '1x', obj.DatepickerSize, 'fit'};
            obj.Grid.RowHeight = {'1x'};
            obj.Grid.ColumnSpacing = 5;

            % Buttons left
            obj.GridButtonLeft = uigridlayout(obj.Grid);
            obj.GridButtonLeft.RowHeight = {"1x", "1x"};
            obj.GridButtonLeft.ColumnWidth = "fit";
            obj.GridButtonLeft.ColumnSpacing = 0;
            obj.GridButtonLeft.RowSpacing = 2;
            obj.GridButtonLeft.Padding(:) = 0;

            obj.ButtonsLeft = [uibutton(obj.GridButtonLeft), uibutton(obj.GridButtonLeft)];
            obj.ButtonsLeft(1).ButtonPushedFcn = @(h,e)obj.onButtonPushed(e);
            obj.ButtonsLeft(1).Tag = "leftUp";
            obj.ButtonsLeft(1).Icon = "up_grey_12.png";
            obj.ButtonsLeft(1).Text = "";
            obj.ButtonsLeft(2).ButtonPushedFcn = @(h,e)obj.onButtonPushed(e);
            obj.ButtonsLeft(2).Tag = "leftDown";
            obj.ButtonsLeft(2).Icon = "down_grey_12.png";
            obj.ButtonsLeft(2).Text = "";

            % Date picker left
            obj.DatepickerLeft = uidatepicker(obj.Grid);
            obj.DatepickerLeft.ValueChangedFcn = @(h,e)obj.onDatepickerChanged(e);
            obj.DatepickerLeft.Value = datetime("02-Jan-2020");
            obj.DatepickerLeft.Limits = [obj.Limits(1) datetime("02-Jan-2020")];
            obj.DatepickerLeft.Editable = false;
            obj.DatepickerLeft.Tag = "left";
            
            % Slider
            obj.Slider = uislider(obj.Grid, 'range');
            obj.Slider.ValueChangedFcn = @(h,e)obj.onSliderChanged(e);
            obj.Slider.ValueChangingFcn = @(h,e)obj.onSliderChanging(e);
            obj.Slider.Limits = [0 3];
            obj.Slider.Value = [1 2];            

            % Date picker right
            obj.DatepickerRight = uidatepicker(obj.Grid);
            obj.DatepickerRight.ValueChangedFcn = @(h,e)obj.onDatepickerChanged(e);
            obj.DatepickerRight.Value = datetime("03-Jan-2020");
            obj.DatepickerRight.Limits = [datetime("03-Jan-2020") obj.Limits(2)];
            obj.DatepickerRight.Editable = false;
            obj.DatepickerRight.Tag = "right";

            % Buttons right
            obj.GridButtonRight = uigridlayout(obj.Grid);
            obj.GridButtonRight.RowHeight = {"1x", "1x"};
            obj.GridButtonRight.ColumnWidth = "fit";
            obj.GridButtonRight.ColumnSpacing = 0;
            obj.GridButtonRight.RowSpacing = 2;
            obj.GridButtonRight.Padding(:) = 0;

            obj.ButtonsRight = [uibutton(obj.GridButtonRight), uibutton(obj.GridButtonRight)];
            obj.ButtonsRight(1).ButtonPushedFcn = @(h,e)obj.onButtonPushed(e);
            obj.ButtonsRight(1).Tag = "rightUp";
            obj.ButtonsRight(1).Icon = "Up_Grey_12.png";
            obj.ButtonsRight(1).Text = "";
            obj.ButtonsRight(2).ButtonPushedFcn = @(h,e)obj.onButtonPushed(e);
            obj.ButtonsRight(2).Tag = "rightDown";
            obj.ButtonsRight(2).Icon = "Down_Grey_12.png";
            obj.ButtonsRight(2).Text = "";

            % Update the internal component lists
            obj.BackgroundColorableComponents = [obj.Grid, obj.GridButtonLeft, obj.GridButtonRight];
            obj.FontStyledComponents = [obj.DatepickerLeft, obj.Slider, obj.DatepickerRight];
            obj.EnableableComponents = [obj.DatepickerLeft, obj.Slider, obj.DatepickerRight, obj.ButtonsLeft, obj.ButtonsRight];
            obj.FieldColorableComponents = [obj.DatepickerLeft, obj.DatepickerRight];
            obj.ButtonColorableComponents = [obj.ButtonsLeft, obj.ButtonsRight];

            % Update the slider ticks
            tickLoc = 0:days(obj.Limits(2) - obj.Limits(1));
            dtArray = datetime("01-Jan-2020") + days(tickLoc);            
            obj.Slider.MajorTicks = tickLoc;
            obj.Slider.MinorTicks = tickLoc;
            obj.Slider.MajorTickLabels = categorical(dtArray(tickLoc + 1));

        end %function


        function update(obj)
            % Set the value ranges

            % Set orientation in grid
            if obj.Orientation == "vertical"

                % Grid
                obj.Grid.ColumnWidth = {'fit', 'fit', '1x', 'fit', 'fit'};
                obj.Grid.RowHeight = {obj.DatepickerSize, '1x'};

                % Left
                obj.GridButtonLeft.Layout.Row = 1;
                obj.GridButtonLeft.Layout.Column = 1;
                obj.DatepickerLeft.Layout.Row = 1;
                obj.DatepickerLeft.Layout.Column = 2;

                % Right
                obj.GridButtonRight.Layout.Row = 1;
                obj.GridButtonRight.Layout.Column = 5;
                obj.DatepickerRight.Layout.Row = 1;
                obj.DatepickerRight.Layout.Column = 4;

                % Slider
                obj.Slider.Layout.Row = 2;
                obj.Slider.Layout.Column = [1 5];

            else

                % Grid
                obj.Grid.ColumnWidth = {'fit', obj.DatepickerSize, '1x', obj.DatepickerSize, 'fit'};
                obj.Grid.RowHeight = {'1x'};

                % Left
                obj.GridButtonLeft.Layout.Row = 1;
                obj.GridButtonLeft.Layout.Column = 1;
                obj.DatepickerLeft.Layout.Row = 1;
                obj.DatepickerLeft.Layout.Column = 2;

                % Right
                obj.GridButtonRight.Layout.Row = 1;
                obj.GridButtonRight.Layout.Column = 5;
                obj.DatepickerRight.Layout.Row = 1;
                obj.DatepickerRight.Layout.Column = 4;

                % Slider
                obj.Slider.Layout.Row = 1;
                obj.Slider.Layout.Column = 3;
            end

            % Make sure values are a datetime number            
            if isnat(obj.DatepickerLeft.Value)
                obj.DatepickerLeft.Value = obj.DatepickerLeft.Limits(1);
            end          
            if isnat(obj.DatepickerRight.Value)
                obj.DatepickerRight.Value = obj.DatepickerRight.Limits(2);
            end

            % Gap is bounded by limits
            obj.MinGap = boundValue(obj, days(obj.MinGap), 0, days(diff(obj.Limits)));

            % Update datepicker limits
            updateControlLimitsAndValue(obj);          
            
            % Update datepicker display formats
            obj.DatepickerLeft.DisplayFormat = obj.DisplayFormat;
            obj.DatepickerRight.DisplayFormat = obj.DisplayFormat;

            % Update ticks
            updateSliderTicks(obj);

            % Update buttons
            updateButtonEnable(obj);

        end %function


        function onButtonPushed(obj, evt)
            % Triggered on button pushed

            % What button was pushed?
            oldDate = obj.Value;
            newDate = obj.Value;

            switch evt.Source.Tag
                case "leftUp"
                    newDate(1) = min(newDate(1) + obj.Step, newDate(2) - days(1));
                case "leftDown"
                    newDate(1) = max(newDate(1) - obj.Step, obj.Limits(1));
                case "rightUp"
                    newDate(2) = min(newDate(2) + obj.Step, obj.Limits(2));
                case "rightDown"
                    newDate(2) = max(newDate(2) - obj.Step, newDate(1) + days(1));
            end

            % Update the value
            obj.Value = newDate;

            % Trigger event
            evtOut = wt.eventdata.PropertyChangedData('Value', newDate, oldDate);
            notify(obj, "ValueChanged", evtOut);

        end %function

        function onSliderChanged(obj,evt)
            % Triggered on slider moved
            
            % What changed the date?
            prevDate = obj.Limits(1) + round(evt.PreviousValue);
            newDate = obj.Limits(1) + round(evt.Value);

            % Update datepicker limits
            updateControlLimitsAndValue(obj, newDate);

            % Update button enable status
            updateButtonEnable(obj)

            % Event data
            evtOut = wt.eventdata.PropertyChangedData('Value', newDate, prevDate);

            % Trigger event "ValueChanged"
            notify(obj, "ValueChanged", evtOut);

        end %function

        function onSliderChanging(obj,evt)
            % Triggered on slider moving
            
            % What changed the date?
            changedDate = obj.Limits(1) + round(evt.Value);

            % Update datepicker values
            obj.DatepickerLeft.Value = changedDate(1);
            obj.DatepickerRight.Value = changedDate(2);

            % Event data
            evtOut = wt.eventdata.PropertyChangedData('Value', changedDate);

            % Trigger event "ValueChanging"
            notify(obj, "ValueChanging", evtOut);

        end %function


        function onDatepickerChanged(obj,evt)
            % Triggered on button pushed

            % What changed?
            prevValue = obj.Value;
            newValue = obj.Value;

            switch evt.Source.Tag
                case "left"
                    prevValue(1) = evt.PreviousValue;
                case "right"
                    prevValue(2) = evt.PreviousValue;
            end

            % Prepare event data
            evtOut = wt.eventdata.PropertyChangedData('Value', newValue, prevValue);

            % Update the components with the new value
            updateControlLimitsAndValue(obj, newValue)

            % Update the buttons
            updateButtonEnable(obj)

            % Trigger event
            notify(obj, "ValueChanged", evtOut);

        end %function


        function updateButtonEnable(obj)

            % What are the buttons?
            buttonsLeft = obj.ButtonsLeft;
            buttonsRight = obj.ButtonsRight;

            if ~(numel(buttonsLeft) == 2 && numel(buttonsRight) == 2)
                return
            end

            % Can interval increase to lower bound?
            if obj.Value(1) > obj.Limits(1)
                buttonsLeft(2).Enable = true;
            else
                buttonsLeft(2).Enable = false;
            end

            % Can interval further increase to upper bound?
            if obj.Value(2) < obj.Limits(2)
                buttonsRight(1).Enable = true;
            else
                buttonsRight(1).Enable = false;
            end

            % Can interval further decrease to center?
            if obj.Value(1) == obj.Value(2) - obj.MinGap
                buttonsLeft(1).Enable = false;
                buttonsRight(2).Enable = false;
            else
                buttonsLeft(1).Enable = true;
                buttonsRight(2).Enable = true;
            end

        end %function


        function updateSliderTicks(obj)
            % Update the limits in date-picker and slider

            % Get ticks
            [majorTicks, minorTicks] = getSliderTicks( ...
                obj, ...
                obj.Orientation, ...
                "TickLength", strlength(obj.DisplayFormat));

            % Set slider limits and ticks            
            obj.Slider.MajorTicks = majorTicks;
            obj.Slider.MinorTicks = minorTicks;

            minLimit = obj.Limits(1);
            minLimit.Format = obj.DisplayFormat;
            obj.Slider.MajorTickLabels = categorical(minLimit + days(majorTicks));
        end %function
    

        function updateControlLimitsAndValue(obj, val)
            % Update values in datepicker components

            % Current control value
            currentVal = [obj.DatepickerLeft.Value obj.DatepickerRight.Value];
            
            % Value provided?
            if nargin < 2
                val = currentVal;
            end

            % Bound current value by lower limit and upper limit.
            if eq(currentVal(1), val(1))
                val(1) = boundValue(obj, val(1), obj.Limits(1), obj.Limits(2) - obj.MinGap);
                val(2) = boundValue(obj, val(2), val(1) + obj.MinGap, obj.Limits(2));
            else
                val(2) = boundValue(obj, val(2), obj.Limits(1) + obj.MinGap, obj.Limits(2));
                val(1) = boundValue(obj, val(1), obj.Limits(1), val(2) - obj.MinGap);
            end

            % Update the limits and value
            obj.DatepickerLeft.Limits = [obj.Limits(1) val(2) - obj.MinGap];
            obj.DatepickerLeft.Value = val(1);

            obj.DatepickerRight.Limits = [val(1) + obj.MinGap obj.Limits(2)];
            obj.DatepickerRight.Value = val(2);    

            % Update the limits and value in the slider
            obj.Slider.Limits = days([0, diff(obj.Limits)]);
            obj.Slider.Value = days(val - obj.Limits(1));

        end %function

    end %methods

    %% Private helper functions
    methods (Access = private)

        function boundedVal = boundValue(~, val, lowerBound, upperBound)
            boundedVal = min( ...
                max(val, lowerBound), ...
                upperBound);
        end

    end

end % classdef

function mustBeIncreasing(A)
%MUSTBEINCREASING Validate that value array is increasing
%   MUSTBEINCREASING(A) throws an error if array A is not increating.
%   MATLAB calls sort to determine if A is increasing.
%
%   Class support:
%   All numeric classes
%   MATLAB classes that define these methods:
%       sort, isnumeric
%
%   See also: MUSTBENUMERIC, MUSTBEREAL, MUSTBEVECTOR.

try
    mustBeNumeric(A)
    mustBeReal(A)
    mustBeVector(A)
catch ME
    throwAsCaller(ME)
end

[~, idx] = sort(A, 'ascend');
if ~all(eq(idx, 1:numel(idx)))
    ME = MException( ...
        'DateRageSlider:mustBeIncreasing', ...
        'Value must be increasing.');
    throwAsCaller(ME);
end
    
end