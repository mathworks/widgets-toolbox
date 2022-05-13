classdef BackgroundColorable < handle
    
    % Mixin for component with colorable background

    % Copyright 2020-2022 The MathWorks Inc.
    
    
    %% Internal properties
    properties (AbortSet, Transient, NonCopyable, ...
            Access = {?matlab.ui.componentcontainer.ComponentContainer})
        
        % List of graphics controls to apply to
        BackgroundColorableComponents (:,1) matlab.graphics.Graphics
        
        BackgroundColorListener event.proplistener

    end %properties
    
  
    
    %% Methods
    methods (Access = protected)
        
        function updateBackgroundColorableComponents(obj)
           
            hasProp = isprop(obj.BackgroundColorableComponents,'BackgroundColor');
            wt.utility.fastSet(obj.BackgroundColorableComponents(hasProp),...
                "BackgroundColor",obj.BackgroundColor); %#ok<MCNPN> 
            
        end %function


        function listenForBackgroundChange(obj)

            % Establish Listener for Background Color Change
            if isempty(obj.BackgroundColorListener)
                obj.BackgroundColorListener = ...
                    addlistener(obj,'BackgroundColor','PostSet',...
                    @(h,e)obj.updateBackgroundColorableComponents());
            end

        end %function

    end %methods
    


    %% Accessors
    methods
        
        function set.BackgroundColorableComponents(obj,value)
            obj.BackgroundColorableComponents = value;
            obj.listenForBackgroundChange();
            obj.updateBackgroundColorableComponents()
        end
        
    end %methods
    
end %classdef