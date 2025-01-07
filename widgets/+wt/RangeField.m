classdef RangeField < matlab.ui.componentcontainer.ComponentContainer & ...
        wt.mixin.BackgroundColorable & ...
        wt.mixin.Enableable & ...
        wt.mixin.FieldColorable & ...
        wt.mixin.FontStyled & ...
        wt.mixin.Tooltipable
    % Pair of numeric edit fields for range selection

    % Copyright 2024 The MathWorks Inc.

    %RJ - Need unit tests
    %RJ - Improve error if a restriction needs enforcement. Like display a
    % message but still accept their input?


    %% Public properties
    properties (AbortSet)

        % Values of the range (min/max)
        Value (1,2) double = [0 1]

        % Optional limits of the range (min/max)
        Limits (1,2) double = [-inf inf]

        % Is the lower limit inclusive?
        LowerLimitInclusive (1,1) matlab.lang.OnOffSwitchState = true

        % Is the upper limit inclusive?
        UpperLimitInclusive (1,1) matlab.lang.OnOffSwitchState = true

    end %properties


    methods
        function set.Value(obj,value)
            obj.validateValue(value);
            obj.Value = value;
        end
        function set.Limits(obj,value)
            validateattributes(value,{'double'},{'increasing'})
            obj.Limits = value;
        end
    end


    %% Events
    events (HasCallbackProperty, NotifyAccess = protected)

        % Triggered on value changed, has companion callback
        ValueChanged

    end %events


    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = protected)

        % Grid
        Grid (1,1) matlab.ui.container.GridLayout

        % Edit fields
        EditField (1,2) matlab.ui.control.NumericEditField

    end %properties


    %% Protected methods
    methods (Access = protected)

        function setup(obj)

            % Construct Grid Layout to Manage Building Blocks
            obj.Grid = uigridlayout(obj);
            obj.Grid.ColumnWidth = {'1x','1x'};
            obj.Grid.RowHeight = {'1x'};
            obj.Grid.ColumnSpacing = 5;
            obj.Grid.Padding = 0;

            % Set default size
            obj.Position(3:4) = [100 25];

            % Create the edit field
            obj.EditField = [...
                uieditfield(obj.Grid,'numeric'), ...
                uieditfield(obj.Grid,'numeric') ];
            obj.EditField(1).UpperLimitInclusive = false;
            obj.EditField(2).LowerLimitInclusive = false;
            set(obj.EditField,"ValueChangedFcn",@(h,e)obj.onValueChanged(e));

            % Update the internal component lists
            obj.BackgroundColorableComponents = obj.Grid;
            obj.EnableableComponents = obj.EditField;
            obj.FieldColorableComponents = obj.EditField;
            obj.FontStyledComponents = obj.EditField;
            obj.TooltipableComponents = obj.EditField;

        end %function


        function update(obj)

            % Update the edit field limits
            obj.EditField(1).LowerLimitInclusive = obj.LowerLimitInclusive;
            obj.EditField(1).Limits = [obj.Limits(1) obj.Value(2)];

            obj.EditField(2).UpperLimitInclusive = obj.UpperLimitInclusive;
            obj.EditField(2).Limits = [obj.Value(1) obj.Limits(2)];

            % Update the edit field values
            obj.EditField(1).Value = obj.Value(1);
            obj.EditField(2).Value = obj.Value(2);

        end %function


        function onValueChanged(obj,evt)
            % Triggered on edit field interaction

            % Get prior value
            oldValue = obj.Value;

            % Get new value
            newValue = [obj.EditField.Value];
            index = find(evt.Source == obj.EditField, 1);

            % Store new result
            obj.Value = newValue;

            % Trigger event
            evtOut = wt.eventdata.ValueChangedData(obj.Value, oldValue,...
                "Index", index);
            notify(obj,"ValueChanged",evtOut);

        end %function


        function validateValue(obj,value)
            % Validate the value is in range

            arguments
                obj (1,1)
                value (1,2) double
            end

            validateattributes(value,{'double'},{'increasing'})

            if obj.LowerLimitInclusive && obj.UpperLimitInclusive
                boundFlag = "inclusive";
            elseif obj.LowerLimitInclusive
                boundFlag = "exclude-upper";
            elseif obj.UpperLimitInclusive
                boundFlag = "exclude-lower";
            else
                boundFlag = "exclusive";
            end

            mustBeInRange(value, obj.Limits(1), obj.Limits(2), boundFlag)

        end %function

    end %methods


end % classdef