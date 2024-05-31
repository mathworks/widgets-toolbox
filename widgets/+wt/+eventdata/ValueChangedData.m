classdef ValueChangedData < wt.abstract.BaseEventData & dynamicprops
    % Event data for widget value changes
    %
    % Syntax:
    %           obj = wt.eventdata.ValueChangedData(newValue,oldValue)
    %           obj = wt.eventdata.ValueChangedData(valueChangedEvent)
    %           obj = wt.eventdata.ValueChangedData(...,'p1',v1,...)
    %
    
    % Copyright 2020-2024 The MathWorks, Inc.

    %% Properties
    properties (SetAccess = protected)
        Value
        PreviousValue
    end %properties


    %% Constructor / destructor
    methods
        function obj = ValueChangedData(newValue,varargin)

            % Is input a MATLAB eventdata?
            if isa(newValue,'matlab.ui.eventdata.ValueChangedData')

                obj.Value = newValue.Value;
                obj.PreviousValue = newValue.PreviousValue;

            elseif isa(newValue,'matlab.ui.eventdata.ValueChangingData')

                obj.Value = newValue.Value;

            else

                % No - use the value directly
                obj.Value = newValue;

                % Was a previous value provided?
                if mod(numel(varargin),2)
                    obj.PreviousValue = varargin{1};
                    varargin(1) = [];
                end

            end %if

            % Any remaining varargin are dynamic property-value pairs
            for idx=1:2:numel(varargin)
                thisProp = varargin{idx};
                thisValue = varargin{idx+1};
                obj.addprop(thisProp);
                obj.(thisProp) = thisValue;
            end

        end %constructor

    end %methods

end % classdef