classdef MenuSelectedData < event.EventData & dynamicprops
    % Event data for menu selection
    %
    % Syntax:
    %           obj = wt.eventdata.MenuSelectedData(eventData)
    %

    %   Copyright 2025 The MathWorks Inc.

    %% Properties
    properties (SetAccess = protected)
        Menu matlab.ui.container.Menu
        Text (1,1) string
        Tag (1,1) string
    end %properties


    %% Constructor / destructor
    methods
        function obj = MenuSelectedData(eventData)

            obj.Menu = eventData.Source;
            obj.Text = eventData.Source.Text;
            obj.Tag = eventData.Source.Tag;

        end %constructor
    end %methods

end % classdef