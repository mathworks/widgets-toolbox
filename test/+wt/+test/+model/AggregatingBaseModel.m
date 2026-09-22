classdef AggregatingBaseModel < wt.model.BaseModel
    % Test-only BaseModel subclass with an aggregated child model.

    % Copyright 2026 The MathWorks, Inc.

    properties (AbortSet, SetObservable)
        Child (:,1) wt.test.model.SimpleBaseModel = ...
            wt.test.model.SimpleBaseModel.empty(0,1)
    end

    methods (Access = protected)
        function props = getAggregatedModelProperties(~)
            props = "Child";
        end
    end

end
