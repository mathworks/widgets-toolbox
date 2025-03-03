classdef SelectionColorable < handle
    % Mixin to add styles to a component

    % This mixin does not provide a list of components to update, but
    % rather depends on selection color being handled in the widget's
    % update method. Selection is typically something that is handled
    % there.

    % Copyright 2020-2025 The MathWorks Inc.


    %% Properties
    properties (AbortSet, Dependent)

        % Selection Color
        SelectionColor (1,3) double {mustBeInRange(SelectionColor,0,1)}

    end %properties


    properties (AbortSet, NeverAmbiguous)

        % Selection color mode
        SelectionColorMode (1,1) wt.enum.AutoManualState = 'auto'

    end %properties


    %% Internal properties
    properties (AbortSet, Hidden)

        % Selection Color
        SelectionColor_I (1,3) double {mustBeInRange(SelectionColor_I,0,1)} = [0.7059    0.8706    1.0000]

    end %properties


    properties (Transient, NonCopyable, Access = private)

        % Listener for theme changes
        ThemeChangedListener event.listener

    end %properties


    %% Property Accessors
    methods

        function value = get.SelectionColor(obj)
            value = obj.SelectionColor_I;
        end

        function set.SelectionColor(obj, value)
            obj.SelectionColorMode = 'manual';
            obj.SelectionColor_I = value;
        end

        function set.SelectionColorMode(obj, value)
            obj.SelectionColorMode = value;
            obj.applyTheme();
        end

    end %methods


    %% Constructor
    methods

        function obj = SelectionColorable()

            % Confirm BaseWidget and R2025a or newer
            if isa(obj,"wt.abstract.BaseWidget") ...
                    && ~isMATLABReleaseOlderThan("R2025a")

                % Listen to theme changes
                obj.ThemeChangedListener = ...
                    listener(obj, "WidgetThemeChanged", @(~,~)applyTheme(obj));

                % Get the initial color
                obj.applyTheme();

            end %if

        end %function

    end %methods


    %% Protected Methods
    methods (Access = protected)

        function color = getDefaultSelectionColor(obj)
            % Returns the default color for 'auto' mode (R2025a and later)
            % The result is dependent on theme
            % Widget subclass may override this

            color = obj.getThemeColor("--mw-backgroundColor-selectedFocus"); %#ok<MCNPN>

        end %function

    end %methods


    %% Private Methods
    methods (Access = private)

        function applyTheme(obj)

            % If color mode is auto, use standard theme color
            if obj.SelectionColorMode == "auto" ...
                    && isa(obj,"wt.abstract.BaseWidget") ...
                    && ~isMATLABReleaseOlderThan("R2025a")

                % Use standard theme color
                obj.SelectionColor_I = obj.getDefaultSelectionColor();                    

            end %if

        end %function

    end %methods


end %classdef