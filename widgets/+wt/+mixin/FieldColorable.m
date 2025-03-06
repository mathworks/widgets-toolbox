classdef FieldColorable < handle
    % Mixin to add styles to a component

    % Copyright 2020-2025 The MathWorks Inc.


    %% Properties
    properties (AbortSet, Dependent)

        % Field Color
        FieldColor (1,3) double {mustBeInRange(FieldColor,0,1)}

    end %properties


    properties (AbortSet, NeverAmbiguous)

        % Field color mode
        FieldColorMode (1,1) wt.enum.AutoManualState = 'auto'

    end %properties


    %% Internal properties
    properties (AbortSet, Hidden)

        % Field Color
        FieldColor_I (1,3) double {mustBeInRange(FieldColor_I,0,1)} = [1 1 1]

    end %properties


    properties (AbortSet, Transient, NonCopyable, Hidden, SetAccess = protected)

        % List of graphics controls to apply to
        FieldColorableComponents (:,1) matlab.graphics.Graphics

    end %properties


    properties (Transient, NonCopyable, Access = private)

        % Listener for theme changes
        ThemeChangedListener event.listener

    end %properties


    %% Property Accessors
    methods

        function value = get.FieldColor(obj)
            value = obj.FieldColor_I;
        end

        function set.FieldColor(obj, value)
            obj.FieldColorMode = 'manual';
            obj.FieldColor_I = value;
        end

        function set.FieldColorMode(obj, value)
            obj.FieldColorMode = value;
            obj.applyTheme();
        end

        function set.FieldColor_I(obj,value)
            obj.FieldColor_I = value;
            obj.updateFieldColorableComponents()
        end

        function set.FieldColorableComponents(obj,value)
            obj.FieldColorableComponents = value;
            obj.applyTheme();
            obj.updateFieldColorableComponents()
        end

    end %methods


    %% Constructor
    methods

        function obj = FieldColorable()

            % Confirm BaseWidget and R2025a or newer
            if matches("WidgetThemeChanged", events(obj)) ...
                    && ~isMATLABReleaseOlderThan("R2025a")

                % Listen to theme changes
                obj.ThemeChangedListener = ...
                    listener(obj, "WidgetThemeChanged", @(~,~)applyTheme(obj));

            end %if

        end %function

    end %methods


    %% Protected Methods
    methods (Access = protected)

        function updateFieldColorableComponents(obj)

            % What needs to be updated?
            comps = obj.FieldColorableComponents;
            propNames = ["FieldColor","BackgroundColor","Color"];
            color = obj.FieldColor_I;

            % Set the subcomponent properties in prioritized order
            wt.utility.setStylePropsInPriority(comps, propNames, color);

        end %function


        function color = getDefaultFieldColor(obj)
            % Returns the default color for 'auto' mode (R2025a and later)
            % The result is dependent on theme
            % Widget subclass may override this

            try
                color = obj.getThemeColor("--mw-backgroundColor-input"); %#ok<MCNPN>

            catch exception

                color = obj.FieldColor_I;

                id = "wt:applyTheme:getThemeColorFail";
                msg = "Unable to get default theme color: %s";
                warning(id, msg, exception.message)

            end %try

        end %function

    end %methods


    %% Private Methods
    methods (Access = private)

        function applyTheme(obj)

            % If color mode is auto, use standard theme color
            if obj.FieldColorMode == "auto" ...
                    && ~isMATLABReleaseOlderThan("R2025a")

                % Use standard theme color
                obj.FieldColor_I = obj.getDefaultFieldColor();                    

            end %if

        end %function

    end %methods


end %classdef