classdef DateSlider < wt.abstract.BaseWidget & ...
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

    %% Public dependent properties
    properties (AbortSet, Dependent)
        % These properties do not trigger the update method

        % Value of the slider and date-time selector
        Value (1,1) datetime

        % Index of selected item
        ValueIndex (1,1) double {mustBeInteger}

        % Date format
        DisplayFormat (1,1) string 

    end %properties

     properties (AbortSet, UsedInUpdate = false)
        % These properties do not trigger the update method

        % Define step size for buttons
        Step (1,1) calendarDuration = calendarDuration(0,0,1)
        
     end
     
    %% Public properties
    properties (AbortSet)
        % These properties trigger the update method

        % Limits of the slider and spinner
        Limits (1,2) datetime = datetime("01-Jan-2020") + days([0 2]);

        % Orientation of the spinner and slider
        Orientation (1,1) wt.enum.HorizontalVerticalState = wt.enum.HorizontalVerticalState.horizontal

        % Size of date-picker (width for horizontal, height for vertical
        DatepickerSize = 120

    end %properties

   

    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = protected)

        % Slider
        Slider = matlab.ui.control.Slider.empty

        % Date picker
        Datepicker matlab.ui.control.DatePicker

        % Selection buttons
        GridButtons matlab.ui.container.GridLayout
        Buttons (1,:) matlab.ui.control.Button

    end

    %% Accessors
    methods

        % ValueIndex
        function set.ValueIndex(obj, val)
            maxRange = days(obj.Limits(2) - obj.Limits(1));
            try
                mustBeInRange(val, 0, maxRange)
            catch ME
                throwAsCaller(ME)
            end
            dtArray = (obj.Limits(1):days(1):obj.Limits(2)) - obj.Limits(1);
            obj.Value = dtArray(val);
        end %function
        function val = get.ValueIndex(obj)
            val = obj.Slider.Value;
        end %function

        % Value
        function set.Value(obj, val)
            try
                obj.Datepicker.Value = val;
            catch ME
                throwAsCaller(ME);
            end
            obj.Slider.Value = days(val - obj.Limits(1));
            obj.Datepicker.Value = val;
        end %function
        function val = get.Value(obj)
            val = obj.Datepicker.Value;
        end %function

        % Display format
        function set.DisplayFormat(obj, val)
            try
                obj.Datepicker.DisplayFormat = val;
            catch ME
                throwAsCaller(ME)
            end
            format = obj.Datepicker.DisplayFormat;
            obj.Limits.Format = format;
        end %function
        function val = get.DisplayFormat(obj)
            val = obj.Datepicker.DisplayFormat;
        end %function

        % Limits
        function set.Limits(obj, val)
            startOfDay = dateshift(val, 'start', 'days');
            try
                numVal = days(startOfDay - startOfDay(1));
                mustBeGreaterThan(numVal(2), numVal(1))
            catch ME
                if strcmp(ME.identifier, 'MATLAB:validators:mustBeGreaterThanOrEqual')
                    msg = 'Error setting property ''Limits'' of class ''%s''. Value must be increasing.';
                    Merr = MException(ME.identifier, msg, classname2link(class(obj)));
                    throwAsCaller(Merr);
                else
                    rethrow(ME)
                end
            end
            obj.Limits = startOfDay;
        end %function

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
            obj.Position(3:4) = [400 40];

            % Configure grid
            obj.Grid.ColumnWidth = {'1x', obj.DatepickerSize, 'fit'};
            obj.Grid.ColumnSpacing = 5;

            % Slider
            obj.Slider = uislider(obj.Grid);
            obj.Slider.ValueChangedFcn = @(h,e)obj.onSliderChanged(e);
            obj.Slider.ValueChangingFcn = @(h,e)obj.onSliderChanged(e);
            obj.Slider.Limits = [0 2];
            obj.Slider.Value = 1;

            % Date picker
            obj.Datepicker = uidatepicker(obj.Grid);
            obj.Datepicker.ValueChangedFcn = @(h,e)obj.onDatepickerChanged(e);
            obj.Datepicker.Value = obj.Limits(1) + days(1);
            obj.Datepicker.Limits = obj.Limits;
            obj.Datepicker.Editable = false;

            % Button grid
            obj.GridButtons = uigridlayout(obj.Grid);
            obj.GridButtons.RowHeight = {"1x", "1x"};
            obj.GridButtons.ColumnWidth = "fit";
            obj.GridButtons.ColumnSpacing = 0;
            obj.GridButtons.RowSpacing = 2;
            obj.GridButtons.Padding(:) = 0;

            obj.Buttons = [uibutton(obj.GridButtons) uibutton(obj.GridButtons)];
            obj.Buttons(1).ButtonPushedFcn = @(h,e)obj.onButtonPushed(e);
            obj.Buttons(1).Tag = "up";
            obj.Buttons(1).Icon = "up_grey_12.png";
            obj.Buttons(1).Text = "";
            obj.Buttons(2).ButtonPushedFcn = @(h,e)obj.onButtonPushed(e);
            obj.Buttons(2).Tag = "down";
            obj.Buttons(2).Icon = "down_grey_12.png";
            obj.Buttons(2).Text = "";

            % Update the internal component lists
            obj.BackgroundColorableComponents = obj.Grid;
            obj.FontStyledComponents = [obj.Datepicker, obj.Slider];
            obj.EnableableComponents = [obj.Datepicker, obj.Slider, obj.Buttons];
            obj.FieldColorableComponents = [obj.Datepicker];
            obj.ButtonColorableComponents = [obj.Buttons];

        end %function


        function update(obj)

            % Set the value ranges

            % Set orientation in grid
            if obj.Orientation == "vertical"
                obj.Grid.ColumnWidth = {'1x', 'fit'};
                obj.Grid.RowHeight = {'1x', obj.DatepickerSize};
                obj.Datepicker.Layout.Row = 2;
                obj.Datepicker.Layout.Column = 1;
                obj.GridButtons.Layout.Row = 2;
                obj.GridButtons.Layout.Column = 2;
                obj.Slider.Orientation = "vertical";
            else
                obj.Grid.ColumnWidth = {'1x', obj.DatepickerSize, 'fit'};
                obj.Grid.RowHeight = {'1x'};
                obj.Datepicker.Layout.Row = 1;
                obj.Datepicker.Layout.Column = 2;
                obj.GridButtons.Layout.Row = 1;
                obj.GridButtons.Layout.Column = 3;
                obj.Slider.Orientation = "horizontal";
            end 

            % Set component range
            obj.Slider.Limits = [0 days(obj.Limits(2) - obj.Limits(1))];
            obj.Datepicker.Limits = obj.Limits;

            % Update ticks
            updateSliderTicks(obj)

            % Set value
            if isnat(obj.Datepicker.Value)
                obj.Datepicker.Value = obj.Limits(1);
            end
            obj.Slider.Value = days(obj.Datepicker.Value - obj.Limits(1));

            % Update the buttons
            updateButtonEnable(obj)
            
        end %function


        function onButtonPushed(obj, evt)
            % Triggered on button pushed

            % What button was pushed?
            oldDate = obj.Value;
            newDate = obj.Value;
            switch evt.Source.Tag
                case "up"
                    newDate = min(newDate + obj.Step, obj.Limits(2));
                case "down"
                    newDate = max(newDate - obj.Step, obj.Limits(1));

            end

            % Update the state
            obj.Datepicker.Value = newDate;
            obj.Slider.Value = days(newDate - obj.Limits(1));

            % Update button enable status
            updateButtonEnable(obj)

            % Trigger event
            evtOut = wt.eventdata.PropertyChangedData('Value', newDate, oldDate);
            notify(obj, "ValueChanged", evtOut);

        end %function

        function onSliderChanged(obj,evt)
            % Triggered on slider moved

            % What changed?
            newValue = evt.Value;
            oldValue = obj.Datepicker.Value;

            % Round value to whole days
            newValue = round(newValue);
            newValue = min(max(newValue,0), days(obj.Limits(2) - obj.Limits(1)));

            % Prepare event data
            newDate = obj.Limits(1) + days(newValue);
            evtOut = wt.eventdata.PropertyChangedData('Value', newDate, oldValue);

            % Update the state
            obj.Datepicker.Value = newDate;

            % Skip for event ValueChanging for performance
            if evt.EventName == "ValueChanged"
                obj.Slider.Value = newValue;
                
                % Update button enable status
                updateButtonEnable(obj)
            end

            % Trigger event ("ValueChanged" or "ValueChanging")
            notify(obj, evt.EventName, evtOut);

        end %function


        function onDatepickerChanged(obj,e)
            % Triggered on button pushed

            % What changed?
            newValue = e.Value;

            % Prepare event data
            evtOut = wt.eventdata.PropertyChangedData('Value', newValue, e.PreviousValue);

            % Update the state
            obj.Slider.Value = days(newValue - obj.Limits(1));

            % Update button enable status
            updateButtonEnable(obj)

            % Trigger event
            notify(obj, "ValueChanged", evtOut);

        end %function


        function updateButtonEnable(obj)

            % What are the buttons?

            % Limits of interval reached?
            if obj.Value <= obj.Limits(1)
                obj.Buttons(1).Enable = true;
                obj.Buttons(2).Enable = false;
            elseif obj.Value >= obj.Limits(2)
                obj.Buttons(1).Enable = false;
                obj.Buttons(2).Enable = true;
            else
                obj.Buttons(1).Enable = true;
                obj.Buttons(2).Enable = true;
            end %if

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
            obj.Slider.MajorTickLabels = categorical(obj.Limits(1) + days(majorTicks));
            
        end %function

    end %methods

end % classdef