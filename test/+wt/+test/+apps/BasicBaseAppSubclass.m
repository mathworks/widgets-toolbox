classdef BasicBaseAppSubclass < wt.apps.BaseApp
    % Test app utilizing the BaseApp subclass
    
%% Internal Properties
properties (Hidden, SetAccess = private)

    % Label
    Label matlab.ui.control.Label

end %properties


    %% Protectected Methods
    methods (Access = protected)

        function setup(app)

            % Create a label in the grid
            app.Label = uilabel(app.Grid);
            app.Label.HorizontalAlignment = "center";
            app.Label.VerticalAlignment = "center";
            app.Label.FontSize = 24;
            app.Label.Text = "Test App - setup";
            
        end %function


        function update(app)

            app.Label.Text = "Text App - update";

        end %function

    end %methods

end %classdef