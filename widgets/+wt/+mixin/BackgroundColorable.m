classdef BackgroundColorable < handle
    % Mixin to add styles to a component

    % Copyright 2020-2023 The MathWorks Inc.


    %% Internal properties
    properties (AbortSet, Transient, NonCopyable, Hidden, SetAccess = protected)

        % List of graphics controls to apply to
        BackgroundColorableComponents (:,1) matlab.graphics.Graphics

        % Listener to update method
        UpdateListener event.listener

    end %properties


    %% Accessors
    methods

        function set.BackgroundColorableComponents(obj,value)
            obj.BackgroundColorableComponents = value;
            obj.updateBackgroundColorableComponents()
            obj.listenForBackgroundChange();
        end

    end %methods



    %% Methods
    methods (Access = protected)

        function updateBackgroundColorableComponents(obj)

            % What needs to be updated?
            comps = obj.BackgroundColorableComponents;
            newValue = obj.BackgroundColor; %#ok<MCNPN> 
            propNames = ["BackgroundColor","Color"];

            % Set the subcomponent properties in prioritized order
            wt.utility.setStylePropsInPriority(comps, propNames, newValue);

        end %function


        function listenForBackgroundChange(obj)

            % Establish Listener for PostUpdate event triggered by a background 
            % color change. Listen to PostUpdate event to reload widget with 
            % custom background color from AppDesigner.
            if isempty(obj.UpdateListener)
                obj.UpdateListener = ...
                    addlistener(obj,'PostUpdate',...
                    @(h,e)obj.updateBackgroundColorableComponents());
            end

        end %function

    end %methods

end %classdef