classdef NumericArray < wt.abstract.BaseWidget & ...
        wt.mixin.Enableable & ...
        wt.mixin.FieldColorable & ...
        wt.mixin.FontStyled & ...
        wt.mixin.Tooltipable
    % Set of N numeric edit fields for small numeric arrays

    % Copyright 2025 The MathWorks Inc.

    %% Events
    events (HasCallbackProperty, NotifyAccess = protected)

        % Triggered on value changed, has companion callback
        ValueChanged

    end %events


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
        Restriction (1,1) wt.enum.ArrayRestriction = "none"

        % Orientation of the fields
        Orientation (1,1) wt.enum.HorizontalVerticalState = "horizontal"

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


    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = protected)

        % Edit fields
        EditField (1,:) matlab.ui.control.NumericEditField

    end %properties


    %% Protected methods
    methods (Access = protected)

        function setup(obj)

            % Call superclass method
            obj.setup@wt.abstract.BaseWidget()

            % Set default size
            obj.Position(3:4) = [100 25];

            % Configure grid
            obj.Grid.ColumnWidth = {'1x','1x','1x'};
            obj.Grid.ColumnSpacing = 5;
            obj.Grid.RowSpacing = 5;

            % Update the internal component lists
            obj.BackgroundColorableComponents = obj.Grid;

        end %function


        function update(obj)

            % How many fields?
            numElements = numel(obj.Value);
            numFields = numel(obj.EditField);
            numRows = numel(obj.Grid.RowHeight);
            numCols = numel(obj.Grid.ColumnWidth);
            if numFields ~= numElements || ...
                    numRows > 1 && numElements > 1 && obj.Orientation == "horizontal" || ...
                    numCols > 1 && numElements > 1 && obj.Orientation == "vertical"
                obj.createEditFields(numElements);
            end

            % Loop on each edit field to update it
            for idx = 1:numElements

                % Calculate limits
                lowerLimit = obj.Limits(1);
                upperLimit = obj.Limits(2);
                lowerLimitInclusive = obj.LowerLimitInclusive;
                upperLimitInclusive = obj.UpperLimitInclusive;

                switch (obj.Restriction)

                    case wt.enum.ArrayRestriction.increasing

                        if idx > 1
                            lowerLimit = obj.Value(idx-1);
                            lowerLimitInclusive = false;
                        end

                        if idx < numElements
                            upperLimit = obj.Value(idx+1);
                            upperLimitInclusive = false;
                        end

                    case wt.enum.ArrayRestriction.decreasing

                        if idx > 1
                            upperLimit = obj.Value(idx-1);
                            upperLimitInclusive = false;
                        end

                        if idx < numElements
                            lowerLimit = obj.Value(idx+1);
                            lowerLimitInclusive = false;
                        end

                end %switch

                % Apply restrictions
                obj.EditField(idx).Limits = [lowerLimit upperLimit];
                obj.EditField(idx).LowerLimitInclusive = lowerLimitInclusive;
                obj.EditField(idx).UpperLimitInclusive = upperLimitInclusive;

                % Update the edit fields values
                obj.EditField(idx).Value = obj.Value(idx);

            end %for

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


        function validateValue(obj,value)
            % Validate the value is in range and meets restrictions

            arguments
                obj (1,1)
                value (1,:) double
            end

            switch obj.Restriction
                case wt.enum.ArrayRestriction.increasing
                    restriction = {'increasing'};
                case wt.enum.ArrayRestriction.decreasing
                    restriction = {'decreasing'};
                otherwise
                    restriction = {};
            end

            validateattributes(value,{'double'},restriction)

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