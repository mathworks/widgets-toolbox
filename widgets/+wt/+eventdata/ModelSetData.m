classdef ModelSetData < event.EventData & matlab.mixin.Copyable
    % Event data for model set

    % Copyright 2024 The MathWorks, Inc.

    %% Properties
    properties
        Model
        Controller
    end %properties

end % classdef