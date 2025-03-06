classdef TitleColorable < handle
    % Mixin to add styles to a component

    % Copyright 2020-2025 The MathWorks Inc.


    %% Properties
    properties (AbortSet, Dependent)

        % Title Color
        TitleColor (1,3) double {mustBeInRange(TitleColor,0,1)}

    end %properties


    properties (AbortSet, NeverAmbiguous)

        % Title color mode
        TitleColorMode (1,1) wt.enum.AutoManualState = 'auto'

    end %properties


    %% Internal properties
    properties (AbortSet, Hidden)

        % Title Color
        TitleColor_I (1,3) double {mustBeInRange(TitleColor_I,0,1)} = [1 1 1]

    end %properties


    properties (AbortSet, Transient, NonCopyable, Hidden, SetAccess = protected)

        % List of graphics controls to apply to
        TitleColorableComponents (:,1) matlab.graphics.Graphics

    end %properties


    properties (Transient, NonCopyable, Access = private)

        % Listener for theme changes
        ThemeChangedListener event.listener

    end %properties


    %% Property Accessors
    methods

        function value = get.TitleColor(obj)
            value = obj.TitleColor_I;
        end

        function set.TitleColor(obj, value)
            obj.TitleColorMode = 'manual';
            obj.TitleColor_I = value;
        end

        function set.TitleColorMode(obj, value)
            obj.TitleColorMode = value;
            obj.applyTheme();
        end

        function set.TitleColor_I(obj,value)
            obj.TitleColor_I = value;
            obj.updateTitleColorableComponents()
        end

        function set.TitleColorableComponents(obj,value)
            obj.TitleColorableComponents = value;
            obj.applyTheme();
            obj.updateTitleColorableComponents()
        end

    end %methods


    %% Constructor
    methods

        function obj = TitleColorable()

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

        function updateTitleColorableComponents(obj)

            % What needs to be updated?
            comps = obj.TitleColorableComponents;
            propNames = ["TitleColor","FontColor","ForegroundColor"];
            color = obj.TitleColor_I;

            % Set the subcomponent properties in prioritized order
            wt.utility.setStylePropsInPriority(comps, propNames, color); 

        end %function


        function color = getDefaultTitleColor(obj)
            % Returns the default color for 'auto' mode (R2025a and later)
            % The result is dependent on theme
            % Widget subclass may override this

            try
                color = obj.getThemeColor("--mw-color-secondary"); %#ok<MCNPN>

            catch exception

                color = obj.TitleColor_I;

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
            if obj.TitleColorMode == "auto" ...
                    && ~isMATLABReleaseOlderThan("R2025a")

                % Use standard theme color
                obj.TitleColor_I = obj.getDefaultTitleColor();

            end %if

        end %function

    end %methods


end %classdef