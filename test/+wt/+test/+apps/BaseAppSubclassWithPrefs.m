classdef BaseAppSubclassWithPrefs < wt.apps.BaseApp
    % Test app utilizing the BaseApp subclass
    %   Copyright 2025 The MathWorks Inc.

    %% Properties
    properties (AbortSet)

        % Name of the app
        PropertyA (1,1) double = 10

    end %properties


    %% Constructor / destructor
    methods (Access = public)

        function app = BaseAppSubclassWithPrefs(varargin)
            % Constructor

            % Custom preferences
            prefs = wt.test.model.CustomPreferenceForTest();
            prefGroup = "wtTemporaryPreferenceGroup";

            % Call the superclass constructor with custom prefs
            app@wt.apps.BaseApp(...
                "PreferenceGroup",prefGroup,...
                "Preferences",prefs,...
                varargin{:});

        end %methods

    end %function


    %% Internal Properties
    properties (Hidden, SetAccess = private)

        % Label
        Label matlab.ui.control.Label

        EditField matlab.ui.control.NumericEditField

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

            % Create a label in the grid
            app.EditField = uieditfield(app.Grid,'numeric');
            app.EditField.FontSize = 24;

        end %function


        function update(app)

            app.Label.Text = "Text App - update";
            app.EditField.Value = app.PropertyA;

        end %function

    end %methods

end %classdef