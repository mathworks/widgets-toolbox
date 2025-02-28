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
        FieldColorThemeChangedListener event.listener

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
            obj.applyThemePrivate();
        end

        function set.FieldColor_I(obj,value)
            obj.FieldColor_I = value;
            obj.updateFieldColorableComponents()
        end

        function set.FieldColorableComponents(obj,value)
            obj.FieldColorableComponents = value;
            obj.applyThemePrivate();
            obj.updateFieldColorableComponents()
        end

    end %methods


    %% Constructor
    methods

        function obj = FieldColorable()

            % Listen to theme changes
            if ~isMATLABReleaseOlderThan("R2025a")
                obj.FieldColorThemeChangedListener = ...
                    listener(obj, "WidgetThemeChanged", @(~,~)applyThemePrivate(obj));
            end

        end %function

    end %methods


    %% Methods
    methods (Access = protected)

        function updateFieldColorableComponents(obj)

            % What needs to be updated?
            comps = obj.FieldColorableComponents;
            propNames = ["FieldColor","BackgroundColor","Color"];
            color = obj.FieldColor_I;

            % Set the subcomponent properties in prioritized order
            wt.utility.setStylePropsInPriority(comps, propNames, color);

        end %function

    end %methods


    methods (Abstract, Hidden)

        % This is supplied by wt.abstract.BaseWidget
        color = getThemeColor(obj, semanticColorId)

    end %methods


    methods (Access = private)

        function applyThemePrivate(obj)

            % If color mode is auto, use standard theme color
            if obj.FieldColorMode == "auto" && ~isMATLABReleaseOlderThan("R2025a")

                % Use standard theme color
                obj.FieldColor_I = ...
                    obj.getThemeColor("--mw-backgroundColor-input");

            end %if

        end %function

    end %methods


end %classdef