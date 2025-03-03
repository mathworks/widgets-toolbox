classdef ButtonColorable < handle
    % Mixin to add styles to a component

    % Copyright 2020-2025 The MathWorks Inc.

    %% Properties
    properties (AbortSet, Dependent)

        % Button Color
        ButtonColor (1,3) double {mustBeInRange(ButtonColor,0,1)}

    end %properties


    properties (AbortSet, NeverAmbiguous)

        % Button color mode
        ButtonColorMode (1,1) wt.enum.AutoManualState = 'auto'

    end %properties


    %% Internal properties
    properties (AbortSet, Hidden)

        % Button Color
        ButtonColor_I (1,3) double {mustBeInRange(ButtonColor_I,0,1)} = [1 1 1]

    end %properties


    properties (AbortSet, Transient, NonCopyable, Hidden, SetAccess = protected)

        % List of graphics controls to apply to
        ButtonColorableComponents (:,1) matlab.graphics.Graphics

    end %properties


    properties (Transient, NonCopyable, Access = private)

        % Listener for theme changes
        ThemeChangedListener event.listener

    end %properties


    %% Property Accessors
    methods

        function value = get.ButtonColor(obj)
            value = obj.ButtonColor_I;
        end

        function set.ButtonColor(obj, value)
            obj.ButtonColorMode = 'manual';
            obj.ButtonColor_I = value;
        end

        function set.ButtonColorMode(obj, value)
            obj.ButtonColorMode = value;
            obj.applyTheme();
        end

        function set.ButtonColor_I(obj,value)
            obj.ButtonColor_I = value;
            obj.updateButtonColorableComponents()
        end

        function set.ButtonColorableComponents(obj,value)
            obj.ButtonColorableComponents = value;
            obj.applyTheme();
            obj.updateButtonColorableComponents()
        end

    end %methods


    %% Constructor
    methods

        function obj = ButtonColorable()

            % Confirm BaseWidget and R2025a or newer
            if isa(obj,"wt.abstract.BaseWidget") ...
                    && ~isMATLABReleaseOlderThan("R2025a")

                % Listen to theme changes
                obj.ThemeChangedListener = ...
                    listener(obj, "WidgetThemeChanged", @(~,~)applyTheme(obj));

            end %if

        end %function

    end %methods


    %% Protected Methods
    methods (Access = protected)

        function updateButtonColorableComponents(obj)

            % What needs to be updated?
            comps = obj.ButtonColorableComponents;
            propNames = ["ButtonColor","BackgroundColor","Color"];
            color = obj.ButtonColor_I;

            % Set the subcomponent properties in prioritized order
            wt.utility.setStylePropsInPriority(comps, propNames, color);

        end %function

    end %methods


    %% Private Methods
    methods (Access = private)

        function applyTheme(obj)

            % If color mode is auto, use standard theme color
            if obj.ButtonColorMode == "auto" ...
                    && isa(obj,"wt.abstract.BaseWidget") ...
                    && ~isMATLABReleaseOlderThan("R2025a")

                % Use standard theme color
                obj.ButtonColor_I = ...
                    obj.getThemeColor("--mw-backgroundColor-primary"); %#ok<MCNPN>

            end %if

        end %function

    end %methods

end %classdef