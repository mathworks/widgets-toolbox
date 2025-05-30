classdef PropertyChangedData < event.EventData & dynamicprops
    % Event data for widget property value changes
    %
    % Syntax:
    %           obj = wt.eventdata.PropertyChangedData(propName,newValue,oldValue)
    %           obj = wt.eventdata.PropertyChangedData(propName,valueChangedEvent)
    %           obj = wt.eventdata.PropertyChangedData(...,'p1',v1,...)
    %
    
    % Copyright 2020-2025 The MathWorks, Inc.

    %% Properties
    properties (SetAccess = protected)
        Value
        PreviousValue
        Property char
    end %properties


    %% Constructor / destructor
    methods
        function obj = PropertyChangedData(propName,newValue,varargin)
            
            % Set the changed property name
            obj.Property = propName;
            
            % Is input a MATLAB or widget eventdata?
            if isa(newValue,'wt.eventdata.ValueChangedData') || ...
                isa(newValue,'wt.eventdata.PropertyChangedData')
                obj.Value = newValue.Value;
                obj.PreviousValue = newValue.PreviousValue;
            elseif isa(newValue,'matlab.ui.eventdata.ValueChangedData')

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