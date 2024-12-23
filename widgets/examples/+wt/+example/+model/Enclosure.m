classdef Enclosure < wt.model.BaseModel
    % Implements the model class for an enclosure


    %% Public Properties
    properties (AbortSet, SetObservable)

        % Point location of the enclosure on the map
        Location (1,2) double

        % Animals within this enclosure
        Animal (1,:) wt.example.model.Animal

    end %properties


    %% Protected methods
    methods (Access = protected)

        function props = getAggregatedModelProperties(~)
            % Returns a list of aggregated model property names

            % If a listed property is also a wt.model.BaseModel, property
            % changes that trigger the ModelChanged event will be passed up
            % the hierarchy to this object.

            props = "Animal";

        end %function

    end %methods

end %classdef