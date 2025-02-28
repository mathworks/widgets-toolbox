classdef FontStyled < handle
    % Mixin for component with Font properties

    % Copyright 2020-2025 The MathWorks Inc.


    %% Properties
    properties (AbortSet)

        % Font name
        FontName char {mustBeNonempty} = 'Helvetica'

        % Font size in points
        FontSize (1,1) double {mustBePositive,mustBeFinite} = 12

        % Font weight (normal/bold)
        FontWeight (1,1) wt.enum.FontWeightState = 'normal'

        % Font angle (normal/italic)
        FontAngle (1,1) wt.enum.FontAngleState = 'normal'

    end %properties


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
        FontStyledComponents (:,1) matlab.graphics.Graphics

    end %properties


    properties (Transient, NonCopyable, Access = private)

        % Listener for theme changes
        FontColorThemeChangedListener event.listener

    end %properties


    %% Property Accessors

    methods

        function set.FontName(obj,value)
            obj.FontName = value;
            obj.updateFontStyledComponents("FontName",value)
        end

        function set.FontSize(obj,value)
            obj.FontSize = value;
            obj.updateFontStyledComponents("FontSize",value)
        end

        function set.FontWeight(obj,value)
            obj.FontWeight = value;
            obj.updateFontStyledComponents("FontWeight",value)
        end

        function set.FontAngle(obj,value)
            obj.FontAngle = value;
            obj.updateFontStyledComponents("FontAngle",value)
        end

        function value = get.FontColor(obj)
            value = obj.FontColor_I;
        end

        function set.FontColor(obj, value)
            obj.FontColorMode = 'manual';
            obj.FontColor_I = value;
        end

        function set.FontColorMode(obj, value)
            obj.FontColorMode = value;
            obj.applyThemePrivate();
        end

        function set.FontColor_I(obj,value)
            obj.FontColor_I = value;
            obj.updateFontStyledComponents("FontColor", obj.FontColor_I);
        end

        function set.FontStyledComponents(obj,value)
            obj.FontStyledComponents = value;
            obj.applyThemePrivate();
            obj.updateFontStyledComponents()
        end

    end %methods


    %% Constructor
    methods

        function obj = FontStyled()

            % Listen to theme changes
            if ~isMATLABReleaseOlderThan("R2025a")
                obj.FontColorThemeChangedListener = ...
                    listener(obj, "WidgetThemeChanged", @(~,~)applyThemePrivate(obj));
            end

        end %function

    end %methods



    %% Methods
    methods (Access = protected)

        function updateFontStyledComponents(obj,prop,value)

            % Get the components
            comps = obj.FontStyledComponents;

            % Font color properties in prioritized order
            colorProps = ["FontColor","FontColor","ForegroundColor"];

            % Updating all or a specific property?
            if nargin < 3

                % Set all subcomponent properties
                wt.utility.setStylePropsInPriority(comps,"FontName",obj.FontName)
                wt.utility.setStylePropsInPriority(comps,"FontSize",obj.FontSize)
                wt.utility.setStylePropsInPriority(comps,"FontWeight",obj.FontWeight)
                wt.utility.setStylePropsInPriority(comps,"FontAngle",obj.FontAngle)
                wt.utility.setStylePropsInPriority(comps,colorProps, obj.FontColor_I);

            elseif prop == "FontColor"
                % Update just the FontColor property

                % Set the subcomponent property
                wt.utility.setStylePropsInPriority(comps, colorProps, value);

            else

                % Set the subcomponent property
                wt.utility.setStylePropsInPriority(comps, prop, value);

            end %if

        end %function

    end %methods


    methods (Abstract, Hidden)

        % This is supplied by wt.abstract.BaseWidget
        color = getThemeColor(obj, semanticColorId)

    end %methods


    methods (Access = private)

        function applyThemePrivate(obj)

            % If color mode is auto, use standard theme color
            if obj.FontColorMode == "auto" && ~isMATLABReleaseOlderThan("R2025a")

                % Use standard theme color
                obj.FontColor_I = ...
                    obj.getThemeColor("--mw-color-primary");

            end %if

        end %function

    end %methods


end %classdef