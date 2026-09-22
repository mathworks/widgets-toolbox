classdef SimpleBaseModel < wt.model.BaseModel
    % Test-only BaseModel subclass with an observable property.

    % Copyright 2026 The MathWorks, Inc.

    properties (AbortSet, SetObservable)
        Count (1,1) double = 0
    end

    methods (Access = protected)
        function name = getDefaultName(~)
            name = "Default Test Model";
        end
    end

end
