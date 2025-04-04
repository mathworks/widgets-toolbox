classdef Login < wt.abstract.BaseDialog2
    % Implements a simple login dialog


    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = private)

        LoginField matlab.ui.control.EditField

        PasswordField wt.PasswordField

    end %properties


    %% Protected methods
    methods (Access = protected)

        function setup(obj)
            % Configure the widget

            % Defaults
            obj.Size = [300,140];

            % Call superclass method
            obj.setup@wt.abstract.BaseDialog2();

            % Add buttons
            obj.LowerButtonText = ["Login","Cancel"];
            obj.LowerButtonTag = ["login","cancel"];

            % Configure grid
            obj.Grid.RowHeight = {25,25};
            obj.Grid.ColumnWidth = {'fit','1x'};

            % Set title
            obj.Title = "Login";

            % Add labels
            col = 1;
            startRow = 1;
            obj.addRowLabels(["Username:","Password"], ...
                obj.Grid, col, startRow);

            % Add controls
            obj.LoginField = uieditfield(obj.Grid);
            obj.LoginField.Layout.Row = 1;
            obj.LoginField.Layout.Column = 2;

            obj.PasswordField = wt.PasswordField(obj.Grid);
            obj.PasswordField.Layout.Row = 2;
            obj.PasswordField.Layout.Column = 2;

            % Update component lists
            % obj.BackgroundColorableComponents = [obj.Grid]

        end %function

    end %methods

end %classdef