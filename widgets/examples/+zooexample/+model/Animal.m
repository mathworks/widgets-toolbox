classdef Animal < wt.model.BaseModel
    % Implements the model class for a zoo animal
%   Copyright 2025 The MathWorks Inc.


    %% Public Properties
    properties (AbortSet, SetObservable)

        % Species of the animal
        Species (1,1) string

        % Birth date of the animal
        BirthDate (1,1) datetime = NaT

        % Sex of the animal
        Sex (1,1) zooexample.enum.Sex = zooexample.enum.Sex.unspecified

    end %properties


    %% Read-Only Properties
    properties (Dependent, SetAccess = immutable)

        % Birth date of the animal (years)
        Age (1,1) double

    end %properties


    % Accessors
    methods

        function value = get.Age(obj)
            value = round(years(datetime("now") - obj.BirthDate), 2);
        end

    end %methods

end %classdef