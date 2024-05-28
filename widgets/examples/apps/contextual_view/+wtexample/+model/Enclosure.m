classdef Enclosure < wt.model.BaseModel
    % Implements the model class for an enclosure


    %% Public Properties
    properties (AbortSet, SetObservable)

        % Name of the enclosure
        Name (1,1) string

        % Point location of the enclosure on the map
        Location (1,2) double

        % Animals within this enclosure
        Animal (1,:) wtexample.model.Animal

    end %properties


    % Accessors
    % methods
    %     function set.Animal(obj,value)
    %         obj.Animal = value;
    %         obj.attachModelListeners("Animal");
    %     end
    % end %methods

end %classdef