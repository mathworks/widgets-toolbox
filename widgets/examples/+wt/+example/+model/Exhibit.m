classdef Exhibit < wt.model.BaseModel
    % Implements the model class for an exhibit


    %% Public Properties
    properties (AbortSet, SetObservable)

        % Point location of the exhibit on the map
        Location (1,2) double

        % Enclosures within this exhibit
        Enclosure (:,1) wt.example.model.Enclosure

    end %properties


    %% Dependent, Read-Only Properties
    properties (Dependent, SetAccess = private)

        % Flat list of all animals found within the enclosures
        AllAnimal (:,1) wt.example.model.Animal

        % Total number of enclosures
        NumEnclosures (1,1) double

        % Total number of animals within all included enclosures
        NumAnimals (1,1) double

    end %properties

    % Accessors
    methods

        function value = get.AllAnimal(obj)
            if isempty(obj.Enclosure)
                value = wt.example.model.Animal.empty(0,1);
            else
                value = vertcat(obj.Enclosure.Animal);
            end
        end

        function value = get.NumEnclosures(obj)
            value = numel(obj.Enclosure);
        end

        function value = get.NumAnimals(obj)
            value = numel(obj.AllAnimal);
        end

    end %methods


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