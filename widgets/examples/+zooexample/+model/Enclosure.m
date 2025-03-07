classdef Enclosure < wt.model.BaseModel
    % Implements the model class for an enclosure
%   Copyright 2025 The MathWorks Inc.


    %% Public Properties
    properties (AbortSet, SetObservable)

        % Point location of the enclosure on the map
        Location (1,2) double

        % Animals within this enclosure
        Animal (:,1) zooexample.model.Animal

    end %properties


    %% Dependent, Read-Only Properties
    properties (Dependent, SetAccess = private)

        % Total number of animals
        NumAnimals (1,1) double

    end %properties

    % Accessors
    methods

        function value = get.NumAnimals(obj)
            value = numel(obj.Animal);
        end

    end %methods


    %% Destructor
    methods
        function delete(obj)

            % Because we are using composition, any Animal objects will
            % be deleted when this object is deleted
            delete(obj.Animal);

        end %function
    end %methods
    

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