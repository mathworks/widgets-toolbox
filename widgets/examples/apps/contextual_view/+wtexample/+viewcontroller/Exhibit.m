classdef Exhibit < wt.abstract.BaseViewController
    % View/Controller for Exhibit
    
    %% Properties
    properties (AbortSet, SetObservable)

        % Model class
        Model = wtexample.model.Exhibit.empty(0,0)

    end %properties

    
    %% Internal Components
    properties (Transient, Hidden, SetAccess = protected)

        NameLabel matlab.ui.control.Label
        NameField matlab.ui.control.EditField

        LocationLabel matlab.ui.control.Label
        LocationFieldX matlab.ui.control.NumericEditField
        LocationFieldY matlab.ui.control.NumericEditField

    end %properties


    %% Protected Methods
    methods (Access = protected)

        function setup(obj)

            % Call superclass setup first
            obj.setup@wt.abstract.BaseViewController();

            % Configure grid
            obj.Grid.ColumnWidth = {'fit','1x','1x'};
            obj.Grid.RowHeight = {'fit','fit'};


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
                model = wtexample.model.Exhibit;
            end

            % Update the fields
            name = model.Name;
            obj.NameField.Value = name;
            obj.NameField.Enable = enable;

            locX = model.Location(1);
            obj.LocationFieldX.Value = locX;
            obj.LocationFieldX.Enable = enable;

            locY = model.Location(2);
            obj.LocationFieldY.Value = locY;
            obj.LocationFieldY.Enable = enable;

        end %function

    end %methods

end %classdef

