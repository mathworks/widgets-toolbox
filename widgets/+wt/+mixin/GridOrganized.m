classdef GridOrganized < handle
    % Mixin for component to be organized within a 1x1 UIGridLayout
    %

    %% Properties
    properties (AbortSet, Transient, NonCopyable)
        
        % GridLayout
        Grid (1,1) matlab.ui.container.GridLayout = uigridlayout;

        % List of graphics controls that BackgroundColor should apply to
        BackgroundColorableComponents (:,1) matlab.graphics.Graphics

    end


    %% Accessors
    methods (Access = protected)

        function updateBackgroundColorableComponents(obj)
            % Update components that are affected by BackgroundColor
            
            hasProp = isprop(obj.BackgroundColorableComponents,'BackgroundColor');
            set(obj.BackgroundColorableComponents(hasProp),...
                "BackgroundColor",obj.BackgroundColor);
            
        end %function
    end
end