classdef Exhibit < wt.model.BaseModel
    % Implements the model class for an exhibit

    %% Events
    events

        % Triggered on Enclosure being modified
        % EnclosureChanged

    end %events


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
    methods
        function set.Enclosure(obj,value)
            obj.Enclosure = value;
            % obj.attachEnclosureListeners();
            obj.attachModelListeners("Enclosure");
        end
    end %methods


    %% Private Properties
    % properties (Access = private)
    % 
    %     % Listen to changes in nested handle classes
    %     EnclosureChangedListeners
    % 
    % end %properties
    
    
    
    %% Constructor
    % methods
    %     function obj = Exhibit(varargin)
    %         % Constructor
    % 
    %         % Create listeners to enclosure changes
    %         obj.attachEnclosureListeners();
    % 
    %     end %function
    % end %methods


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
    % 
    %     function onEnclosureChanged_private(obj,evt)
    % 
    %         % Notify event to fire
    %         obj.notify("EnclosureChanged", evt)
    % 
    %     end %function
    % 
    % 
    %     function attachEnclosureListeners(obj)
    % 
    %         obj.EnclosureChangedListeners = event.listener(obj.Enclosure,...
    %             'PropertyChanged',@(src,evt)onEnclosureChanged_private(obj,evt));
    % 
    %     end %function
    % 
    % end %methods

end %classdef