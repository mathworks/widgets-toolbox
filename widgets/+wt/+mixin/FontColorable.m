classdef FontColorable < handle
    % Mixin to add styles to a component

    % Copyright 2020-2025 The MathWorks Inc.


    %% Properties
    properties (AbortSet, Dependent)

        % Font Color
        FontColor (1,3) double {mustBeInRange(FontColor,0,1)}

    end %properties


    properties (AbortSet, NeverAmbiguous)

        % Font color mode
        FontColorMode (1,1) wt.enum.AutoManualState = 'auto'

    end %properties



    %% Internal properties
    properties (AbortSet, Hidden)

        % Font Color
        FontColor_I (1,3) double {mustBeInRange(FontColor_I,0,1)} = [0 0 0]

    end %properties


    properties (AbortSet, Transient, NonCopyable, Hidden, SetAccess = protected)

        % List of graphics controls to apply to
        FontColorableComponents (:,1) matlab.graphics.Graphics

    end %properties


    properties (Transient, NonCopyable, Access = private)

        % Listener for theme changes
        ThemeChangedListener event.listener

    end %properties


    %% Accessors
    methods

        function value = get.FontColor(obj)
            value = obj.FontColor_I;
        end

        function set.FontColor(obj, value)
            obj.FontColorMode = 'manual';
            obj.FontColor_I = value;
        end

        function set.FontColorMode(obj, value)
            obj.FontColorMode = value;
            obj.applyTheme();
        end

        function set.FontColor_I(obj,value)
            obj.FontColor_I = value;
            obj.updateFontColorableComponents("FontColor", obj.FontColor_I);
        end

        function set.FontColorableComponents(obj,value)
            obj.FontColorableComponents = value;
            obj.applyTheme();
            obj.updateFontColorableComponents()
        end

    end %methods


    %% Constructor
    methods

        function obj = FontColorable()

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

        function updateFontColorableComponents(obj)

            % Get the components
            comps = obj.FontColorableComponents;

            % Font color properties in prioritized order
            colorProps = ["FontColor","ForegroundColor"];

            % Set the subcomponent properties in prioritized order
            wt.utility.setStylePropsInPriority(comps,colorProps, obj.FontColor_I);

        end %function


        function color = getDefaultFontColor(obj)
            % Returns the default color for 'auto' mode (R2025a and later)
            % The result is dependent on theme
            % Widget subclass may override this

            try
                color = obj.getThemeColor("--mw-color-primary"); %#ok<MCNPN>

            catch exception

                color = obj.FontColor_I;

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
            if obj.FontColorMode == "auto" ...
                    && ~isMATLABReleaseOlderThan("R2025a")

                % Use standard theme color
                obj.FontColor_I = obj.getDefaultFontColor();

            end %if

        end %function

    end %methods


end %classdef