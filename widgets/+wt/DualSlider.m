classdef DualSlider < matlab.ui.componentcontainer.ComponentContainer
    %DUALSLIDER A value range slider that has two tabs, allowing for user
    %selection of min/max values.

    % Copyright 2022 The MathWorks Inc.
    
    %% Public Properties
    properties 
        Data
    end

    %% Internal Component Propeties
    properties (Transient, NonCopyable, ...
            Access = {?matlab.ui.componentcontainer.ComponentContainer,...
            ?matlab.uitest.TestCase})

        % Grid Layout
        Grid (1,1) matlab.ui.container.GridLayout

        % HTML Element - for Slider JS
        HTMLComponent (1,1) matlab.ui.control.HTML

    end %properties
    

    %% Protected Methods
    methods (Access = protected)
        
        % Component Setup Method
        function setup(obj)

            % Set initial size/position of component
            obj.Position(3:4) = [300,60];

            % Construct Grid Layout to manage building blocks
            obj.Grid = uigridlayout(obj,[1,1]);
            obj.Grid.ColumnWidth = {'1x'};
            obj.Grid.ColumnSpacing = 0;
            obj.Grid.RowHeight = {'1x'};
            obj.Grid.RowSpacing = 0;
            obj.Grid.Padding = [0 0 0 0];

            % Create and place HTML component inside Grid
            obj.HTMLComponent = uihtml(obj.Grid);

            % Assign HTML Source
            obj.addHTMLSource();


            % Assign HTML Data and ChangedFcn
            obj.HTMLComponent.Data = struct("Name","Sammy");
            obj.HTMLComponent.DataChangedFcn = @(s,e)notifyDataChanged(obj);           

        end %function


        % Component Update Method
        function update(obj)


            

        end %function

        % HTML Data Source Addition
        function addHTMLSource(obj)
            % Due to the directories shuffling the PWD output when called
            % from this file or when called from the app designer, we have
            % to set the source rather conditionally.

            % Create HTML Path
            htmlPath = "+wt/+html/DualSliderHTML.html";
            obj.HTMLComponent.HTMLSource = htmlPath;

        end %function


        % HTML Component DataChgFunction
        function notifyDataChanged(obj)

            % Notify Data Changed
            disp(obj.Data);

        end %function

    end %methods

end %classdef


