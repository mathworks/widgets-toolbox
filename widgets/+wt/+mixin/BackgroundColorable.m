classdef BackgroundColorable < handle
    % Mixin to add styles to a component

    % Copyright 2020-2025 The MathWorks Inc.


    %% Internal properties
    properties (AbortSet, Transient, NonCopyable, Hidden, SetAccess = protected)

        % List of graphics controls to apply to
        BackgroundColorableComponents (:,1) matlab.graphics.Graphics

        % Listener to background color changes
        BackgroundColorListener event.proplistener

        % Listener to background color changes
        BackgroundColorFirstUpdateListener event.listener

    end %properties


    properties (Transient, NonCopyable, Access = private)

        % Listener for theme changes
        % BackgroundColorableThemeChangedListener event.listener

    end %properties


    %% Property Accessors
    methods

        % function set.FieldColorMode(obj, value)
        %     obj.FieldColorMode = value;
        %     obj.applyThemePrivate();
        % end

        % function set.FieldColor_I(obj,value)
        %     obj.FieldColor_I = value;
        %     obj.updateFieldColorableComponents()
        % end

        % function set.FieldColorableComponents(obj,value)
        %     obj.FieldColorableComponents = value;
        %     obj.applyThemePrivate();
        %     obj.updateFieldColorableComponents()
        % end

        function set.BackgroundColorableComponents(obj,value)
            obj.BackgroundColorableComponents = value;
            obj.listenForBackgroundChange();
            obj.updateBackgroundColorableComponents()
        end

    end %methods


    %% Constructor
    methods

        function obj = BackgroundColorable()

            obj.listenForBackgroundChange();
            % Listen to theme changes
            if ~isMATLABReleaseOlderThan("R2025a")
                % obj.BackgroundColorableThemeChangedListener = ...
                %     listener(obj, "WidgetThemeChanged", @(~,~)applyThemePrivate(obj));
            end

        end %function

    end %methods



    %% Methods
    methods (Access = protected)

        function updateBackgroundColorableComponents(obj)

            % What needs to be updated?
            comps = obj.BackgroundColorableComponents;
            propNames = ["BackgroundColor","Color"];
            color = obj.BackgroundColor_I; %#ok<MCNPN>

            % Set the subcomponent properties in prioritized order
            wt.utility.setStylePropsInPriority(comps, propNames, color);

        end %function

    end %methods


    methods (Access = private)

        function listenForBackgroundChange(obj)

            % Establish Listener for Background Color Change
            if isempty(obj.BackgroundColorListener)

                obj.BackgroundColorListener = ...
                    listener(obj,'BackgroundColor','PostSet',...
                    @(h,e)obj.updateBackgroundColorableComponents());

                % This enables it to display correctly when loading into
                % App Designer. It triggers
                % updateBackgroundColorableComponents after the first time
                % the update method is called.
                obj.BackgroundColorFirstUpdateListener = ...
                    listener(obj,'PostUpdate',...
                    @(h,e)obj.updateBackgroundColorableComponentsOnFirstUpdate());
                
            end %if

        end %function


        function updateBackgroundColorableComponentsOnFirstUpdate(obj)

            % Remove the first update listener
            delete(obj.BackgroundColorFirstUpdateListener);
            obj.BackgroundColorFirstUpdateListener(:) = [];

            % Run the background color update once on first update
            obj.updateBackgroundColorableComponents();

        end %function

    end %methods

end %classdef