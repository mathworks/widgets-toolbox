classdef Animal < wt.abstract.BaseViewController
    % View/Controller for Exhibit
    
    %% Properties
    properties (AbortSet, SetObservable)

        % Model class
        Model = wt.example.model.Animal.empty(0,0)

    end %properties

    
    %% Internal Components
    properties (SetAccess = protected)
        
        SpeciesLabel matlab.ui.control.Label
        SpeciesField matlab.ui.control.Label

        NameLabel matlab.ui.control.Label
        NameField matlab.ui.control.EditField

        BirthDateLabel matlab.ui.control.Label
        BirthDateField matlab.ui.control.DatePicker
        
        AgeLabel matlab.ui.control.Label
        AgeField matlab.ui.control.Label

        SexLabel matlab.ui.control.Label
        SexField matlab.ui.control.DropDown

    end %properties


    %% Protected Methods
    methods (Access = protected)

        function setup(obj)

            % Call superclass setup first
            obj.setup@wt.abstract.BaseViewController();

            % Configure grid
            obj.Grid.ColumnWidth = {'fit','1x'};
            obj.Grid.RowHeight = {'fit','fit','fit','fit','fit'};


            % Species field
            tooltip = "Species of the animal";

            obj.SpeciesLabel = uilabel(obj.Grid,...
                "Text","Species:",...
                "Tooltip",tooltip,...
                "HorizontalAlignment","right");

            obj.SpeciesField = uilabel(obj.Grid,...
                "Text","",...
                "Tooltip",tooltip);


            % Name field
            tooltip = "Name of the animal";

            obj.NameLabel = uilabel(obj.Grid,...
                "Text","Name:",...
                "Tooltip",tooltip,...
                "HorizontalAlignment","right");

            obj.NameField = uieditfield(obj.Grid,...
                "Tooltip",tooltip,...
                "ValueChangedFcn",@(~,evt)onFieldEdited(obj,evt,"Name"));
        

            % BirthDate field
            tooltip = "Birthdate of the animal";

            obj.BirthDateLabel = uilabel(obj.Grid,...
                "Text","Birth Date:",...
                "Tooltip",tooltip,...
                "HorizontalAlignment","right");

            obj.BirthDateField = uidatepicker(obj.Grid,...
                "Tooltip",tooltip,...
                "ValueChangedFcn",@(~,evt)onFieldEdited(obj,evt,"BirthDate"));
        
      
            % Age field
            tooltip = "Age of the animal";

            obj.AgeLabel = uilabel(obj.Grid,...
                "Text","Age:",...
                "Tooltip",tooltip,...
                "HorizontalAlignment","right");

            obj.AgeField = uilabel(obj.Grid,...
                "Text","",...
                "Tooltip",tooltip);
        
            
            % Sex field
            tooltip = "Sex of the animal";

            obj.SexLabel = uilabel(obj.Grid,...
                "Text","Sex:",...
                "Tooltip",tooltip,...
                "HorizontalAlignment","right");

            items = string(enumeration("wt.example.enum.Sex"));
            obj.SexField = uidropdown(obj.Grid,...
                "Tooltip",tooltip,...
                "Items",items,...
                "ValueChangedFcn",@(~,evt)onFieldEdited(obj,evt,"Sex")); 

        end %function


        function update(obj)

            % Call superclass method
            obj.update@wt.abstract.BaseViewController();

            % Is there a valid model?
            if isscalar(obj.Model) && isvalid(obj.Model)
                % YES - enable controls and get the model
                enable = true;
                model = obj.Model;
            else
                % NO - disable controls, show default model values
                enable = false;
                model = wt.example.model.Animal;
            end

            % Update the fields
            species = model.Species;
            obj.SpeciesField.Text = species;
            obj.SpeciesField.Enable = enable;

            name = model.Name;
            obj.NameField.Value = name;
            obj.NameField.Enable = enable;

            birthDate = model.BirthDate;
            obj.BirthDateField.Value = birthDate;
            obj.BirthDateField.Enable = enable;

            age = model.Age;
            obj.AgeField.Text = string(age);
            obj.AgeField.Enable = enable;

            sex = model.Sex;
            obj.SexField.Value = sex;
            obj.SexField.Enable = enable;

        end %function

    end %methods

end %classdef

