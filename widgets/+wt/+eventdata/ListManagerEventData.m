classdef ListManagerEventData < wt.abstract.BaseEventData & matlab.mixin.Copyable
    % Event data for list manager change events

    % Copyright 2024 The MathWorks, Inc.

    %% Properties
    properties
        Action (1,1) string
        Item (1,1) string
        ItemData
        Index double {mustBeInteger, mustBeNonnegative, mustBeScalarOrEmpty}
    end %properties
    
end % classdef