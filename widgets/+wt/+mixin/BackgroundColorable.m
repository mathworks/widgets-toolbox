classdef BackgroundColorable < handle
    % Mixin to add styles to a component

    % Copyright 2020-2023 The MathWorks Inc.


    %% Internal properties
    properties (AbortSet, Transient, NonCopyable, Hidden, SetAccess = protected)

        % List of graphics controls to apply to
        BackgroundColorableComponents (:,1) matlab.graphics.Graphics

        % Listener to background color changes
        BackgroundColorListener event.proplistener

        % Listener to background color changes
        BackgroundColorFirstUpdateListener event.listener

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


        function updateBackgroundColorableComponentsOnFirstUpdate(obj)

            % Remove the first update listener
            delete(obj.BackgroundColorFirstUpdateListener);
            obj.BackgroundColorFirstUpdateListener(:) = [];

            % Run the background color update once on first update
            obj.updateBackgroundColorableComponents();

        end %function


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
                
            end

        end %function

    end %methods

end %classdef