classdef DualSlider < matlab.ui.componentcontainer.ComponentContainer & ...
        wt.mixin.Enableable & wt.mixin.FontStyled & ...
        wt.mixin.PropertyViewable

    %DUALSLIDER A value range slider that has two tabs, allowing for user
    %selection of min/max values.

    % Copyright 2022-2023 The MathWorks Inc.

    %% Intro Setting Public Properties
    properties (Access=private, AbortSet, SetObservable)
        % Data Struct, used to pass data back and forth between MATLAB
        % and HTML. Initialized with default values for DualSlider.
        Data (1,1) struct 
    end
    
    %% Public Properties
    properties (Dependent, AbortSet, SetObservable)
        % These properties do not trigger the update method

        % - Value of the Dual Slider Thumbs (Lower/Upper)
        Value (1,2) double

        % - Range Limits of the Slider
        % Limits of Slider (Min/Max)
        Limits (1,2) double

        % - Slider Tags
        MinLabel (1,1) string
        MaxLabel (1,1) string

    end % properties

    %% Events
    events (HasCallbackProperty, NotifyAccess = protected)
        % Callback Events for the DualSlider

        % Triggered on value changed
        ValueChanged

        % Triggered on value changing during slider motion
        ValueChanging

    end %events


    %% Internal Component Propeties
    properties (Transient, NonCopyable, ...
            Access = {?matlab.ui.componentcontainer.ComponentContainer,...
            ?matlab.uitest.TestCase})

        % Grid Layout
        Grid (1,1) matlab.ui.container.GridLayout

        % HTML Element - for Slider JS
        HTMLComponent (1,1) matlab.ui.control.HTML

    end %properties
    
    %% Accessor Methods for Displaying Properties in App Window
    methods (Hidden, Access = protected)



    end %methods

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

            % Create Initial Data Structure
            obj.Data = struct("LowerValue",5,...
                "UpperValue",95,...
                "LowerLimit",0,...
                "UpperLimit",100,...
                "MinLabel","5",...
                "MaxLabel","32");

            % -- Create and place HTML component inside Grid
            % Make HTML Component and add Source
            obj.HTMLComponent = uihtml(obj.Grid);
            obj.addHTMLSource();

            % Encode Data Structure and Pass to HTML
            obj.HTMLComponent.Data = jsonencode(obj.Data);           

            % Assign HTML Data and ChangedFcn
            obj.HTMLComponent.DataChangedFcn = ...
                @(s,e)notifyDataChanged(obj);   

            % Update Method
            update(obj);

                
        end %function


        % Component Update Method
        function update(obj)
            % Update Properties of HTML Dual Slider on Startup
            
            

        end %function

        function propGroups = getPropertyGroups(obj)
            % Override the ComponentContainer GetPropertyGroups with newly
            % customiziable mixin. This will prevent the multiple defintion
            % of getPropertyGroups.
            propGroups = getPropertyGroups@wt.mixin.PropertyViewable(obj);

        end


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
            % DataNotify Callback for HTML
            % Fires when HTML Data Struct has changed from using the HTML
            % component. Need to write the updated data changes back to the
            % MATLAB object properties.

            % Update Data Structure
            obj.Data = jsondecode(obj.HTMLComponent.Data);

            % - Update Internal DualSlider Properties from New Data 
            % Slider Values
            obj.Value = [obj.Data.LowerValue,obj.Data.UpperValue];
            % Slider Limits
            obj.Limits = [obj.Data.LowerLimit,obj.Data.UpperLimit];
            % Slider Labels
            obj.MinLabel = obj.Data.MinLabel;
            obj.MaxLabel = obj.Data.MaxLabel;

            % - Notify Value Changing Function
            notify(obj,"ValueChanged");
            notify(obj,"ValueChanging");

        end %function

    end %methods


    % Accessor Methods for Dependent Properties
    methods

        % -- Test Value
        function value = get.Value(obj)
            % Query Values from HTML Data
            value = [obj.Data.LowerValue, obj.Data.UpperValue];
        end
        function set.Value(obj,value)
            % Store Input Thumb Position Values inside HTML Data
            obj.Data.LowerValue = value(1);
            obj.Data.UpperValue = value(2);

            % Encode Data Structure and Pass to HTML (Update HTML Control)
            obj.HTMLComponent.Data = jsonencode(obj.Data);  

        end

        % -- Limits Getter/Setter Value
        function value = get.Limits(obj)
            % Query Limits from HTML Data
            value = [obj.Data.LowerLimit, obj.Data.UpperLimit];

        end
        function set.Limits(obj,value)
            % Store Input Limits inside HTML Data
            obj.Data.LowerLimit = value(1);
            obj.Data.UpperLimit = value(2);

            % Encode Data Structure and Pass to HTML (Update HTML Control)
            obj.HTMLComponent.Data = jsonencode(obj.Data);  

        end

        % -- Labels Getter/Setter
        % Min Slider Label
        function value = get.MinLabel(obj)
            % Query Label from HTML Data
            value = obj.Data.MinLabel;
        end %function
        function set.MinLabel(obj,value)
            % Store Input Label inside HTML Data
            obj.Data.MinLabel = value;

            % Encode Data Structure and Pass to HTML (Update HTML Control)
            obj.HTMLComponent.Data = jsonencode(obj.Data);
        end %function

        % Max Slider Label
        function value = get.MaxLabel(obj)
            % Query Label from HTML Data
            value = obj.Data.MaxLabel;
        end %function
        function set.MaxLabel(obj,value)
            % Store Input Label inside HTML Data
            obj.Data.MaxLabel = value;

            % Encode Data Structure and Pass to HTML (Update HTML Control)
            obj.HTMLComponent.Data = jsonencode(obj.Data);
        end %function

    end %methods






end %classdef


