classdef Animal < wt.model.BaseModel
    % Implements the model class for a zoo animal


    %% Public Properties
    properties (AbortSet, SetObservable)

        % Name of the animal
        Name (1,1) string

        % Species of the animal
        Species (1,1) string

        % Birth date of the animal
        BirthDate (1,1) datetime = NaT

        % Sex of the animal
        Sex (1,1) wtexample.enum.Sex = wtexample.enum.Sex.unspecified

    end %properties


    %% Read-Only Properties
    properties (Dependent, SetAccess = immutable)

        % Birth date of the animal (years)
        Age (1,1) double

    end %properties


    % Accessors
    methods

        function value = get.Age(obj)
            value = years(datetime("now") - obj.BirthDate);
        end

    end %methods


    %% Constructor
    methods
        function obj = Animal(varargin)
            % Constructor

            % Call superclass method
            % obj@wt.model.BaseModel(varargin{:});

            % Debug instead
            obj@wt.model.BaseModel(varargin{:},"Debug",true);

        end %function
    end %methods

end %classdef