classdef Login < wt.abstract.BaseInternalDialog
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

            % Configure which actions close the dialog
            obj.DeleteActions = ["close","login","cancel"];

            % Call superclass method
            obj.setup@wt.abstract.BaseInternalDialog();

            % Add buttons
            obj.DialogButtonText = ["Login","Cancel"];
            obj.DialogButtonTag = ["login","cancel"];
            obj.DialogButtonEnable = [true, true];

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
            obj.LoginField.ValueChangedFcn = @(~,~)onValueEdited(obj);
            obj.LoginField.ValueChangingFcn = @(~,~)onValueEdited(obj);

            obj.PasswordField = wt.PasswordField(obj.Grid);
            obj.PasswordField.Layout.Row = 2;
            obj.PasswordField.Layout.Column = 2;
            obj.PasswordField.ValueChangedFcn = @(~,~)onValueEdited(obj);
            obj.PasswordField.ValueChangingFcn = @(~,~)onValueEdited(obj);

            % Update component lists
            % obj.BackgroundColorableComponents = [obj.Grid]

        end %function


        function update(obj)

            % Check if Login button can be enabled
            obj.updateButtonEnables();

        end %function


        function updateButtonEnables(obj)

            % enable Login button if both fields have typed values
            hasUser = strlength(obj.LoginField.Value) > 0;
            hasPass = strlength(obj.PasswordField.Value) > 0;
            obj.DialogButtonEnable(1) = hasUser && hasPass;

        end %function


        function onValueEdited(obj)

            % Check if Login button can be enabled
            obj.updateButtonEnables();

        end %function


        function assignOutput(obj)

            % Assign output
            output.Login = string( obj.LoginField.Value );
            output.Password = string( obj.PasswordField.Value );
            obj.Output = output;

        end %function

    end %methods

end %classdef