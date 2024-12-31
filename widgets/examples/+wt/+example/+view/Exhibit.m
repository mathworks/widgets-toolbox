classdef Exhibit < wt.abstract.BaseViewController
    % View/Controller for Exhibit
    
    %% Properties
    properties (AbortSet, SetObservable)

        % Model class
        Model = wt.example.model.Exhibit.empty(0,0)

    end %properties

    
    %% Internal Components
    properties (SetAccess = protected)

        NameLabel matlab.ui.control.Label
        NameField matlab.ui.control.EditField

        LocationLabel matlab.ui.control.Label
        LocationFieldX matlab.ui.control.NumericEditField
        LocationFieldY matlab.ui.control.NumericEditField

        NumEnclosuresLabel matlab.ui.control.Label
        NumEnclosuresField matlab.ui.control.Label

        NumAnimalsLabel matlab.ui.control.Label
        NumAnimalsField matlab.ui.control.Label

    end %properties


    %% Protected Methods
    methods (Access = protected)

        function setup(obj)

            % Call superclass setup first
            obj.setup@wt.abstract.BaseViewController();

            % Configure grid
            obj.Grid.ColumnWidth = {'fit','1x','1x'};
            obj.Grid.RowHeight = {'fit','fit','fit','fit'};


            % Name field
            tooltip = "Name of the exhibit";

            obj.NameLabel = uilabel(obj.Grid,...
                "Text","Name:",...
                "Tooltip",tooltip,...
                "HorizontalAlignment","right");
            obj.NameLabel.Layout.Row = 1;
            obj.NameLabel.Layout.Column = 1;

            obj.NameField = uieditfield(obj.Grid,...
                "Tooltip",tooltip,...
                "ValueChangedFcn",@(~,evt)onFieldEdited(obj,evt,"Name"));
            obj.NameField.Layout.Row = 1;
            obj.NameField.Layout.Column = [2 3];


            % Location fields
            tooltip = "Point location of the exhibit";

            obj.LocationLabel = uilabel(obj.Grid,...
                "Text","Location:",...
                "Tooltip",tooltip,...
                "HorizontalAlignment","right");
            obj.LocationLabel.Layout.Row = 2;
            obj.LocationLabel.Layout.Column = 1;


            obj.LocationFieldX = uieditfield(obj.Grid,'numeric',...
                "Tooltip",tooltip,...
                "ValueChangedFcn",@(~,evt)onFieldEdited(obj,evt,"Location",1));
            obj.LocationFieldX.Layout.Row = 2;
            obj.LocationFieldX.Layout.Column = 2;

            obj.LocationFieldY = uieditfield(obj.Grid,'numeric',...
                "Tooltip",tooltip,...
                "ValueChangedFcn",@(~,evt)onFieldEdited(obj,evt,"Location",2));
            obj.LocationFieldY.Layout.Row = 2;
            obj.LocationFieldY.Layout.Column = 3;


            % Number of Enclosures field
            tooltip = "The total number of enclosures in this exhibit";

            obj.NumEnclosuresLabel = uilabel(obj.Grid,...
                "Text","Enclosures:",...
                "Tooltip",tooltip,...
                "HorizontalAlignment","right");
            obj.NumEnclosuresLabel.Layout.Row = 3;
            obj.NumEnclosuresLabel.Layout.Column = 1;

            obj.NumEnclosuresField = uilabel(obj.Grid,...
                "Text","",...
                "Tooltip",tooltip,...
                "HorizontalAlignment","left");
            obj.NumEnclosuresField.Layout.Row = 3;
            obj.NumEnclosuresField.Layout.Column = [2 3];


            % Number of Animals field
            tooltip = "The total number of animals in this exhibit";

            obj.NumAnimalsLabel = uilabel(obj.Grid,...
                "Text","Animals:",...
                "Tooltip",tooltip,...
                "HorizontalAlignment","right");
            obj.NumAnimalsLabel.Layout.Row = 4;
            obj.NumAnimalsLabel.Layout.Column = 1;

            obj.NumAnimalsField = uilabel(obj.Grid,...
                "Text","",...
                "Tooltip",tooltip,...
                "HorizontalAlignment","left");
            obj.NumAnimalsField.Layout.Row = 4;
            obj.NumAnimalsField.Layout.Column = [2 3];

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
                model = wt.example.model.Exhibit;
            end

            % Update the name field
            name = model.Name;
            obj.NameField.Value = name;
            obj.NameField.Enable = enable;

            % Update the location fields
            locX = model.Location(1);
            obj.LocationFieldX.Value = locX;
            obj.LocationFieldX.Enable = enable;

            locY = model.Location(2);
            obj.LocationFieldY.Value = locY;
            obj.LocationFieldY.Enable = enable;

            % Update the number of enclosures field
            numEnclosures = string(model.NumEnclosures);
            obj.NumEnclosuresField.Text = numEnclosures;
            obj.NumEnclosuresField.Enable = enable;

            % Update the number of animals field
            numAnimals = string(model.NumAnimals);
            obj.NumAnimalsField.Text = numAnimals;
            obj.NumAnimalsField.Enable = enable;

        end %function

    end %methods

end %classdef

