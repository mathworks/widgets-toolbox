classdef DividerColorable < handle
    % Mixin to add styles to a component

    % Copyright 2020-2025 The MathWorks Inc.


    %% Properties
    properties (AbortSet, Dependent)

        % Divider Color
        DividerColor (1,3) double {mustBeInRange(DividerColor,0,1)}

    end %properties


    properties (AbortSet, NeverAmbiguous)

        % Divider color mode
        DividerColorMode (1,1) wt.enum.AutoManualState = 'auto'

    end %properties


    %% Internal properties
    properties (AbortSet, Hidden)

        % Divider Color
        DividerColor_I (1,3) double {mustBeInRange(DividerColor_I,0,1)} = [.5 .5 .5]

    end %properties


    properties (AbortSet, Transient, NonCopyable, Hidden, SetAccess = protected)

        % List of graphics controls to apply to
        DividerColorableComponents (:,1) matlab.graphics.Graphics

    end %properties


    properties (Transient, NonCopyable, Access = private)

        % Listener for theme changes
        ThemeChangedListener event.listener

    end %properties


    %% Property Accessors
    methods

        function value = get.DividerColor(obj)
            value = obj.DividerColor_I;
        end

        function set.DividerColor(obj, value)
            obj.DividerColorMode = 'manual';
            obj.DividerColor_I = value;
        end

        function set.DividerColorMode(obj, value)
            obj.DividerColorMode = value;
            obj.applyTheme();
        end

        function set.DividerColor_I(obj,value)
            obj.DividerColor_I = value;
            obj.updateDividerColorableComponents()
        end

        function set.DividerColorableComponents(obj,value)
            obj.DividerColorableComponents = value;
            obj.applyTheme();
            obj.updateDividerColorableComponents()
        end

    end %methods


    %% Constructor
    methods

        function obj = DividerColorable()

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

        function updateDividerColorableComponents(obj)

            % What needs to be updated?
            comps = obj.DividerColorableComponents;
            propNames = ["DividerColor","Color","BackgroundColor"];
            color = obj.DividerColor_I;

            % Set the subcomponent properties in prioritized order
            wt.utility.setStylePropsInPriority(comps, propNames, color);

        end %function


        function color = getDefaultDividerColor(obj)
            % Returns the default color for 'auto' mode (R2025a and later)
            % The result is dependent on theme
            % Widget subclass may override this

            color = obj.getThemeColor("--mw-color-secondary"); %#ok<MCNPN>

        end %function

    end %methods


    %% Private Methods
    methods (Access = private)

        function applyTheme(obj)

            % If color mode is auto, use standard theme color
            if obj.DividerColorMode == "auto" ...
                    && isa(obj,"wt.abstract.BaseWidget") ...
                    && ~isMATLABReleaseOlderThan("R2025a")

                % Use standard theme color
                obj.DividerColor_I = obj.getDefaultDividerColor();                    

            end %if

        end %function

    end %methods


end %classdef