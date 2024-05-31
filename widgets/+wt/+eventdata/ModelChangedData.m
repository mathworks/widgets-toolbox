classdef ModelChangedData < event.EventData & matlab.mixin.Copyable
    % Event data for model changes

    % Copyright 2024 The MathWorks, Inc.

    %% Properties
    properties %(SetAccess = ?wt.model.BaseModel)
        Model
        Property string {mustBeScalarOrEmpty}
        Value
        Stack (1,:) cell
    end %properties

end % classdef