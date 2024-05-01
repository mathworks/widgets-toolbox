classdef NumericArray < matlab.ui.componentcontainer.ComponentContainer & ...
        wt.mixin.Enableable & wt.mixin.FontStyled &...
        wt.mixin.FieldColorable & wt.mixin.BackgroundColorable & ...
        wt.mixin.PropertyViewable & wt.mixin.Tooltipable

    % Set of N numeric edit fields for small numeric arrays

    % Copyright 2024 The MathWorks Inc.


    %RJ - Need unit tests
    %RJ - How to throw an error if entries have a restriction applied?


    %% Public properties
    properties (AbortSet)

        % Values of the range (min/max)
        Value (1,:) double = [1 2 3]

        % Optional limits of the entries (min/max)
        Limits (1,2) double = [-inf inf]

        % Is the lower limit inclusive?
        LowerLimitInclusive (1,1) matlab.lang.OnOffSwitchState = true

        % Is the upper limit inclusive?
        UpperLimitInclusive (1,1) matlab.lang.OnOffSwitchState = true

        % Restriction on array order
        Restriction (1,1) wt.enum.ArrayRestriction = ...
            wt.enum.ArrayRestriction.none

        % Orientation of the fields
        Orientation (1,1) wt.enum.HorizontalVerticalState = ...
            wt.enum.HorizontalVerticalState.horizontal

    end %properties


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
        EditField (1,:) matlab.ui.control.NumericEditField

    end %properties


    %% Protected methods
    methods (Access = protected)

        function setup(obj)

            % Construct Grid Layout to Manage Building Blocks
            obj.Grid = uigridlayout(obj);
            obj.Grid.ColumnWidth = {'1x','1x','1x'};
            obj.Grid.RowHeight = {'1x'};
            obj.Grid.ColumnSpacing = 5;
            obj.Grid.Padding = 0;

            % Set default size
            obj.Position(3:4) = [100 25];

            % Update the internal component lists
            obj.BackgroundColorableComponents = obj.Grid;

        end %function


        function update(obj)

            % How many fields?
            numElements = numel(obj.Value);
            numFields = numel(obj.EditField);
            if numFields ~= numElements
                obj.createEditFields(numElements);
            end

            % Update the edit field limits
            set(obj.EditField,"LowerLimitInclusive",obj.LowerLimitInclusive)
            set(obj.EditField,"UpperLimitInclusive",obj.UpperLimitInclusive)
            set(obj.EditField,"Limits",obj.Limits)

            % Update the edit field values
            for idx = 1:numElements
                obj.EditField(idx).Value = obj.Value(idx);
            end

        end %function


        function createEditFields(obj, numFields)

            % Delete existing content
            delete(obj.EditField);
            obj.EditField(:) = [];

            % Configure Grid
            gridRep = repmat({'1x'},1,numFields);
            if obj.Orientation == wt.enum.HorizontalVerticalState.vertical
                obj.Grid.ColumnWidth = {'1x'};
                obj.Grid.RowHeight = gridRep;
            else
                obj.Grid.ColumnWidth = gridRep;
                obj.Grid.RowHeight = {'1x'};
            end

            % Create edit fields
            for idx = 1:numFields
                obj.EditField(idx) = uieditfield(obj.Grid,'numeric');
            end %for
            set(obj.EditField,"ValueChangedFcn",@(h,e)obj.onValueChanged(e));

            % Update the internal component lists
            obj.FontStyledComponents = obj.EditField;
            obj.FieldColorableComponents = obj.EditField;
            obj.EnableableComponents = obj.EditField;
            obj.TooltipableComponents = obj.EditField;

        end %function


        function propGroups = getPropertyGroups(obj)
            % Override the ComponentContainer GetPropertyGroups with newly
            % customiziable mixin. This can probably also be specific to each control.

            propGroups = getPropertyGroups@wt.mixin.PropertyViewable(obj);

        end %function


        function onValueChanged(obj,~)
            % Triggered on edit field interaction

            % Get prior value
            oldValue = obj.Value;

            % Get new value
            newValue = [obj.EditField.Value];

            % Store new result
            obj.Value = newValue;

            % Trigger event
            evtOut = wt.eventdata.ValueChangedData(obj.Value, oldValue);
            notify(obj,"ValueChanged",evtOut);

        end %function

    end %methods


end % classdef