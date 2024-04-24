classdef Enclosure < wt.model.BaseModel
    % Implements the model class for an enclosure

    % %% Events
    % events
    %
    %     % Triggered on Animal being modified
    %     AnimalChanged
    %
    % end %events


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
    methods
        function set.Animal(obj,value)
            obj.Animal = value;
            % obj.attachAnimalListeners();
            obj.attachModelListeners("Animal");
        end
    end %methods


    %% Private Properties
    % properties (Access = private)
    % 
    %     % Listen to changes in nested handle classes
    %     AnimalChangedListeners event.listener
    % 
    % end %properties


    %% Protected Methods
    % methods (Access=protected)
    % 
    %     function attachModelListeners(obj)
    %         % Override this method to attach listeners to aggregated /
    %         % nested models that are handle class
    % 
    %         obj.AggregatedModelListeners = event.listener(obj.Animal,...
    %             'ModelChanged',@(src,evt)notify(obj,"ModelChanged",evt));
    % 
    %     end %function
    % 
    % end %methods


    %% Private Methods
    % methods (Access = private)

        % function onAnimalChanged_private(obj,evt)
        %
        %     % Notify event to fire
        %     obj.notify("AnimalChanged", evt)
        %
        % end %function


        % function attachAnimalListeners(obj)
        % 
        %     obj.AnimalChangedListeners = event.listener(obj.Animal,...
        %         'PropertyChanged',@(src,evt)onAnimalChanged_private(obj,evt));
        % 
        % end %function
    % end %methods


end %classdef