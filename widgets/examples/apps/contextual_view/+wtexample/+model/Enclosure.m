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


    %% Constructor
    methods
        function obj = Enclosure(varargin)
            % Constructor

            

            % Call superclass method
            % obj@wt.model.BaseModel(varargin{:});

            % Debug instead
            obj@wt.model.BaseModel(...
                "Debug",true,...
                varargin{:});

            % obj@wt.model.BaseModel(...
            %     "AggregatedModelProperties","Animal",...
            %     "Debug",true,...
            %     varargin{:});
        end %function
    end %methods

end %classdef