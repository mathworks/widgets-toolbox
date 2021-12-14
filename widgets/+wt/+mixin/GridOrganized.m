classdef GridOrganized < handle
    % Mixin for component to be organized within a 1x1 UIGridLayout
    %

    %% Properties
    properties (AbortSet, Transient, NonCopyable)
        
        % GridLayout
        Grid (1,1) matlab.ui.container.GridLayout

    end


    %% Accessors
    methods (Access = protected)

       function establishGrid(obj)

            % Construct Grid Layout to Manage Building Blocks
            obj.Grid = uigridlayout(obj);
            obj.Grid.ColumnWidth = {'1x'};
            obj.Grid.RowHeight = {'1x'};
            obj.Grid.RowSpacing = 2;
            obj.Grid.ColumnSpacing = 2;
            obj.Grid.Padding = 2;            

       end
       
    end
end