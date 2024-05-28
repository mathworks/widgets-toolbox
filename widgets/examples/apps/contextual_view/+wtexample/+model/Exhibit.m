classdef Exhibit < wt.model.BaseModel
    % Implements the model class for an exhibit


    %% Public Properties
    properties (AbortSet, SetObservable)

        % Name of the exhibit
        Name (1,1) string

        % Point location of the exhibit on the map
        Location (1,2) double

        % Enclosures within this exhibit
        Enclosure (1,:) wtexample.model.Enclosure

    end %properties


    % Accessors
    % methods
    %     function set.Enclosure(obj,value)
    %         obj.Enclosure = value;
    %         obj.attachModelListeners("Enclosure");
    %     end
    % end %methods

end %classdef