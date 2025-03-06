classdef SeparatorColorable < handle
    % Mixin to add styles to a component

    % Copyright 2020-2025 The MathWorks Inc.


    %% Properties
    properties (AbortSet, Dependent)

        % Separator Color
        SeparatorColor (1,3) double {mustBeInRange(SeparatorColor,0,1)}

    end %properties


    properties (AbortSet, NeverAmbiguous)

        % Separator color mode
        SeparatorColorMode (1,1) wt.enum.AutoManualState = 'auto'

    end %properties


    %% Internal properties
    properties (AbortSet, Hidden)

        % Separator Color
        SeparatorColor_I (1,3) double {mustBeInRange(SeparatorColor_I,0,1)} = [.5 .5 .5]

    end %properties


    properties (AbortSet, Transient, NonCopyable, Hidden, SetAccess = protected)

        % List of graphics controls to apply to
        SeparatorColorableComponents (:,1) matlab.graphics.Graphics

    end %properties


    properties (Transient, NonCopyable, Access = private)

        % Listener for theme changes
        ThemeChangedListener event.listener

    end %properties


    %% Property Accessors
    methods

        function value = get.SeparatorColor(obj)
            value = obj.SeparatorColor_I;
        end

        function set.SeparatorColor(obj, value)
            obj.SeparatorColorMode = 'manual';
            obj.SeparatorColor_I = value;
        end

        function set.SeparatorColorMode(obj, value)
            obj.SeparatorColorMode = value;
            obj.applyTheme();
        end

        function set.SeparatorColor_I(obj,value)
            obj.SeparatorColor_I = value;
            obj.updateSeparatorColorableComponents()
        end

        function set.SeparatorColorableComponents(obj,value)
            obj.SeparatorColorableComponents = value;
            obj.applyTheme();
            obj.updateSeparatorColorableComponents()
        end

    end %methods


    %% Constructor
    methods

        function obj = SeparatorColorable()

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

        function updateSeparatorColorableComponents(obj)

            % What needs to be updated?
            comps = obj.SeparatorColorableComponents;
            propNames = ["SeparatorColor","Color","BackgroundColor"];
            color = obj.SeparatorColor_I;

            % Set the subcomponent properties in prioritized order
            wt.utility.setStylePropsInPriority(comps, propNames, color);

        end %function


        function color = getDefaultSeparatorColor(obj)
            % Returns the default color for 'auto' mode (R2025a and later)
            % The result is dependent on theme
            % Widget subclass may override this

            try
                color = obj.getThemeColor("--mw-borderColor-primary"); %#ok<MCNPN>

            catch exception

                color = obj.SeparatorColor_I;

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
            if obj.SeparatorColorMode == "auto" ...
                    && ~isMATLABReleaseOlderThan("R2025a")

                % Use standard theme color
                obj.SeparatorColor_I = obj.getDefaultSeparatorColor();

            end %if

        end %function

    end %methods


end %classdef