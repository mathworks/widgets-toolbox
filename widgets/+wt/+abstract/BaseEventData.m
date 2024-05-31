classdef BaseEventData < event.EventData & matlab.mixin.Copyable
    % Custom event data base class

    % Copyright 2024 The MathWorks, Inc.


    %% Protected methods
    methods (Access = protected)

        function objOut = copyElement(obj)

            % Get the constructor
            classPath = class(obj);
            fcnConstruct = str2func(classPath);

            % Construct a new eventData
            objOut = fcnConstruct();

            % Get list of settable properties
            props = string(properties(obj));
            isRemove = matches(props, ["Source", "EventName"]);
            props(isRemove) = [];

            % Copy each property
            for thisProp = props'
                objOut.(thisProp) = obj.(thisProp);
            end

        end %function

    end %methods


end %classdef