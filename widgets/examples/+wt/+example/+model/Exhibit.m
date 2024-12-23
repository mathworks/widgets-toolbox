classdef Exhibit < wt.model.BaseModel
    % Implements the model class for an exhibit


    %% Public Properties
    properties (AbortSet, SetObservable)

        % Point location of the exhibit on the map
        Location (1,2) double

        % Enclosures within this exhibit
        Enclosure (1,:) wt.example.model.Enclosure

    end %properties


    %% Protected methods
    methods (Access = protected)

        function props = getAggregatedModelProperties(~)
            % Returns a list of aggregated model property names

            % If a listed property is also a wt.model.BaseModel, property
            % changes that trigger the ModelChanged event will be passed up
            % the hierarchy to this object.

            props = "Enclosure";

        end %function

    end %methods
end %classdef