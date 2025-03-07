classdef BackgroundColorable < handle
    % Mixin to add styles to a component

    % Copyright 2020-2025 The MathWorks Inc.


    %% Internal properties
    properties (AbortSet, Transient, NonCopyable, Hidden, SetAccess = protected)

        % List of graphics controls to apply to
        BackgroundColorableComponents (:,1) matlab.graphics.Graphics

    end %properties


    properties (Transient, NonCopyable, Access = private)

        % Listener to background color changes
        BackgroundColorListener event.proplistener

        % Listener to update complete
        PostUpdateListener event.listener

        % Last known color (for change detection)
        LastColor (1,3) double = nan(1,3)

    end %properties


    %% Property Accessors
    methods

        function set.BackgroundColorableComponents(obj,value)

            % Update the list of components
            obj.BackgroundColorableComponents = value;

            % Ensure listeners have been attached
            obj.attachListeners();

            % Update the color of each component in the list
            obj.updateBackgroundColorableComponents()

        end

    end %methods


    %% Constructor
    methods

        function obj = BackgroundColorable()

            % Ensure listeners have been attached
            obj.attachListeners();

        end %function

    end %methods



    %% Protected Methods
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


    %% Private Methods
    methods (Access = private)

        function attachListeners(obj)

            % Establish Listeners once
            if isempty(obj.BackgroundColorListener)

                % Listener for BackgroundColor changes
                obj.BackgroundColorListener = ...
                    listener(obj,'BackgroundColor','PostSet',...
                    @(h,e)obj.onBackgroundColorChanged());

                % Listen for completion of the update method
                obj.PostUpdateListener = ...
                    listener(obj,'PostUpdate',...
                    @(h,e)obj.onPostUpdate());

            end %if

        end %function


        function onBackgroundColorChanged(obj)

            % Apply color updates
            obj.applyColorChange();

        end %function


        function onPostUpdate(obj)
            % Called after update occurs

            % Was the color changed?
            if ~all(obj.LastColor == obj.BackgroundColor_I) %#ok<MCNPN>

                % Apply color updates
                obj.applyColorChange();

            end %if

        end %function


        function applyColorChange(obj)
                % Apply color updates

                % Set the last known color for change tracking
                obj.LastColor = obj.BackgroundColor_I; %#ok<MCNPN>

                % Update component colors
                obj.updateBackgroundColorableComponents();
            
        end %function

    end %methods

end %classdef