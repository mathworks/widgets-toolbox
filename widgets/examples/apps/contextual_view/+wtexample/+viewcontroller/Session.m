classdef Session < wt.abstract.BaseViewController
    % View for wtexample.model.Session

    %% Properties
    properties (SetObservable)
        Model = wtexample.model.Session.empty(0,0)
    end


    %% Internal Properties
    properties (Transient, Hidden, SetAccess = protected)

        FileNameLabel matlab.ui.control.Label
        FileNameField matlab.ui.control.Label

        FilePathLabel matlab.ui.control.Label
        FilePathField matlab.ui.control.Label

        DescriptionLabel matlab.ui.control.Label
        DescriptionField matlab.ui.control.EditField

    end %properties
    

    %% Protected Methods
    methods (Access = protected)

        function setup(obj)

            % Call superclass setup first
            obj.setup@wt.abstract.BaseViewController();

            % Configure grid
            obj.Grid.ColumnWidth = {'fit','1x'};
            obj.Grid.RowHeight = {'fit','fit','fit'};

            % Add fields

            % --- Height --- %
            tooltip = "File name of the session";

            obj.FileNameLabel = uilabel(obj.Grid);
            obj.FileNameLabel.Text = "File Name:";
            obj.FileNameLabel.Tooltip = tooltip;
            obj.FileNameLabel.HorizontalAlignment = "right";

            obj.FileNameField = uilabel(obj.Grid);
            obj.FileNameField.Text = "";
            obj.FileNameField.Tooltip = tooltip;
            obj.FileNameField.HorizontalAlignment = "left";


            % --- FilePath --- %
            tooltip = "File path of the session";

            obj.FilePathLabel = uilabel(obj.Grid);
            obj.FilePathLabel.Text = "File Path:";
            obj.FilePathLabel.Tooltip = tooltip;
            obj.FilePathLabel.HorizontalAlignment = "right";

            obj.FilePathField = uilabel(obj.Grid);
            obj.FilePathField.Text = "";
            obj.FilePathField.Tooltip = tooltip;
            obj.FilePathField.HorizontalAlignment = "left";


            % --- Description --- %
            tooltip = "Description of the session";

            obj.DescriptionLabel = uilabel(obj.Grid);
            obj.DescriptionLabel.Text = "Description:";
            obj.DescriptionLabel.Tooltip = tooltip;
            obj.DescriptionLabel.HorizontalAlignment = "right";

            obj.DescriptionField = uieditfield(obj.Grid);
            obj.DescriptionField.Tooltip = tooltip;
            obj.DescriptionField.ValueChangedFcn = ...
                @(~,evt)onFieldEdited(obj,evt,"Description");

        end %function


        function update(obj)

            % Call superclass method first
            obj.update@wt.abstract.BaseViewController();
            
            % Get the model to display
            [model, validToDisplay] = obj.getScalarModelToDisplay();

            % Update the fields
            obj.FileNameField.Enable = validToDisplay;
            obj.FilePathField.Enable = validToDisplay;
            obj.DescriptionField.Enable = validToDisplay;

            obj.FileNameField.Text = model.FileName;
            obj.FilePathField.Text = model.FilePath;
            obj.DescriptionField.Value = model.Description;

        end %function


        function onDescriptionEdited(obj,evt)

            newValue = evt.Value;
            obj.Model.Description = newValue;

        end %function

    end %methods

end %classdef