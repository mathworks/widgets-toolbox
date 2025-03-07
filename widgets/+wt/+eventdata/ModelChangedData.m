classdef ModelChangedData < event.EventData
    % Event data for model changes

%   Copyright 2024-2025 The MathWorks Inc.

    %% Properties
    properties %(SetAccess = ?wt.model.BaseModel)
        Model
        Property string {mustBeScalarOrEmpty}
        Value
        Stack (1,:) cell
        ClassStack (1,:) string
    end %properties

end % classdef