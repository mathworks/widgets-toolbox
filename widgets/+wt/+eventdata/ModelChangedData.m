classdef ModelChangedData < event.EventData
    % Event data for model changes

    % Copyright 2024 The MathWorks, Inc.

    %% Properties
    properties (SetAccess = ?wt.model.BaseModel)
        Model
        Property string {mustBeScalarOrEmpty}
        Value
        Stack (1,:) cell
    end %properties


    % %% Properties
    % properties (SetAccess = protected)
    %     Model 
    %     Value
    %     Property string {mustBeScalarOrEmpty}
    %     Stack (1,:) cell
    % end %properties
    % 
    % 
    % %% Constructor
    % methods
    %     function obj = ModelChangedData(model, property, value, stack)
    % 
    %         arguments
    %             model (1,1) wt.model.BaseModel
    %             property char
    %             value = [];
    %             stack (1,:) cell = cell(1,0);
    %         end
    % 
    %         obj.Model = model;
    %         obj.Property = property;
    %         obj.Value = value;
    %         obj.Stack = stack;
    % 
    %     end %constructor
    % end %methods

end % classdef