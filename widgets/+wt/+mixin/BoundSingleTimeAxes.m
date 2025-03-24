classdef BoundSingleTimeAxes < handle
    % Mixin that binds axes properties for a chartcontainer subclass

    %% Protected properties

    properties (Transient, NonCopyable, Access = protected)

        % The internal axes object to bind to
        BoundAxes matlab.graphics.axis.Axes {mustBeScalarOrEmpty}

    end %properties


    %% Public Dependent Properties (bound to contents)
    properties (AbortSet, Dependent)

        % Axes Y-Limits
        YLim (1,2)

        % Axes Y-Limit Mode
        YLimMode (1,1) string

        % Font Color
        Color

        % Grid color
        GridColor

        % Font name
        FontName

        % Font size
        FontSize

        % Font weight
        FontWeight

        % X-Axis Label
        XLabel (1,1) string

        % Y-Axis Label
        YLabel (1,1) string

        % Axes Labels Font name
        LabelFontName

        % Axes Labels Font size in points
        LabelFontSize

        % Axes Labels Font weight (normal/bold)
        LabelFontWeight

        % Axes Title Text
        Title (1,1) string

        % Title Font Color
        TitleColor

        % Title Font name
        TitleFontName

        % Title Font size in points
        TitleFontSize

        % Title Font weight (normal/bold)
        TitleFontWeight

        % Interpreter
        Interpreter

        % Show grid on each axes?
        ShowGrid

        % Show legend on each axes?
        ShowLegend

    end %properties


     %% Property Accessors
    methods

        function value = get.YLim(obj)
            value = obj.getFirstAxesPropertyValue("YLim");
        end
        function set.YLim(obj, value)
            obj.setAxesPropertyToSingleValue("YLim", value);
        end

        function value = get.YLimMode(obj)
            value = obj.getFirstAxesPropertyValue("YLimMode");
        end
        function set.YLimMode(obj, value)
            obj.setAxesPropertyToSingleValue("YLimMode", value);
        end

        function value = get.Color(obj)
            value = obj.getFirstAxesPropertyValue("Color");
        end
        function set.Color(obj, value)
            obj.setAxesPropertyToSingleValue("Color", value);
            obj.setLegendPropertyToSingleValue("Color", value);
        end

        function value = get.GridColor(obj)
            value = obj.getFirstAxesPropertyValue("GridColor");
        end
        function set.GridColor(obj, value)
            obj.setAxesPropertyToSingleValue("GridColor", value);
        end

        function value = get.XLabel(obj)
            value = obj.getFirstAxesComponentValue("XLabel", "String");
        end
        function set.XLabel(obj, value)
            obj.setAxesComponentPropertyToSingleValue("XLabel", "String", value);
        end

        function value = get.YLabel(obj)
            value = obj.getFirstAxesComponentValue("YLabel", "String");
        end
        function set.YLabel(obj, value)
            obj.setAxesComponentPropertyToSingleValue("YLabel", "String", value);
        end

        function value = get.FontName(obj)
            value = obj.getFirstAxesPropertyValue("FontName");
        end
        function set.FontName(obj, value)
            obj.setAxesPropertyToSingleValue("FontName", value);
        end

        function value = get.FontSize(obj)
            value = obj.getFirstAxesPropertyValue("FontSize");
        end
        function set.FontSize(obj, value)
            obj.setAxesPropertyToSingleValue("FontSize", value);
        end

        function value = get.FontWeight(obj)
            value = obj.getFirstAxesPropertyValue("FontWeight");
        end
        function set.FontWeight(obj, value)
            obj.setAxesPropertyToSingleValue("FontWeight", value);
        end

        function value = get.Interpreter(obj)
            value = obj.getFirstAxesComponentValue("YLabel","Interpreter");
        end
        function set.Interpreter(obj, value)
            obj.setAxesComponentPropertyToSingleValue("XLabel", "Interpreter", value);
            obj.setAxesComponentPropertyToSingleValue("YLabel", "Interpreter", value);
            obj.setAxesComponentPropertyToSingleValue("XAxis", "TickLabelInterpreter", value);
            obj.setAxesComponentPropertyToSingleValue("YAxis", "TickLabelInterpreter", value);
        end

        function value = get.LabelFontName(obj)
            value = obj.getFirstAxesComponentValue("YLabel","FontName");
        end
        function set.LabelFontName(obj, value)
            obj.setAxesComponentPropertyToSingleValue("XLabel", "FontName", value);
            obj.setAxesComponentPropertyToSingleValue("YLabel", "FontName", value);
        end

        function value = get.LabelFontSize(obj)
            value = obj.getFirstAxesComponentValue("YLabel","FontSize");
        end
        function set.LabelFontSize(obj, value)
            obj.setAxesComponentPropertyToSingleValue("XLabel", "FontSize", value);
            obj.setAxesComponentPropertyToSingleValue("YLabel", "FontSize", value);
        end

        function value = get.LabelFontWeight(obj)
            value = obj.getFirstAxesComponentValue("YLabel","FontWeight");
        end
        function set.LabelFontWeight(obj, value)
            obj.setAxesComponentPropertyToSingleValue("XLabel", "FontWeight", value);
            obj.setAxesComponentPropertyToSingleValue("YLabel", "FontWeight", value);
        end

        function value = get.Title(obj)
            value = obj.getFirstAxesComponentValue("Title", "String");
        end
        function set.Title(obj, value)
            obj.setAxesComponentPropertyToSingleValue("Title", "String", value);
        end

        function value = get.TitleFontName(obj)
            value = obj.getFirstAxesComponentValue("Title","FontName");
        end
        function set.TitleFontName(obj, value)
            obj.setAxesComponentPropertyToSingleValue("Title", "FontName", value);
        end

        function value = get.TitleFontSize(obj)
            value = obj.getFirstAxesComponentValue("Title","FontSize");
        end
        function set.TitleFontSize(obj, value)
            obj.setAxesComponentPropertyToSingleValue("Title", "FontSize", value);
        end

        function value = get.TitleFontWeight(obj)
            value = obj.getFirstAxesComponentValue("Title","FontWeight");
        end
        function set.TitleFontWeight(obj, value)
            obj.setAxesComponentPropertyToSingleValue("Title", "FontWeight", value);
        end

        function value = get.ShowGrid(obj)
            value = obj.getFirstAxesPropertyValue("YGrid");
        end
        function set.ShowGrid(obj, value)
            obj.setAxesPropertyToSingleValue("XGrid", value);
            obj.setAxesPropertyToSingleValue("YGrid", value);
        end

        function value = get.ShowLegend(obj)
            value = obj.getFirstLegendPropertyValue("Visible");
        end
        function set.ShowLegend(obj, value)
            obj.setLegendPropertyToSingleValue("Visible", value);
        end

    end %methods


    %% Private methods
    methods (Access = private)

        function [ax, isValid] = getValidAxes(obj)
            ax = obj.BoundAxes;
            isValid = isvalid(ax);
            ax = ax(isValid);
        end

        function [lgd, isValid] = getValidLegend(obj)
            [ax, isValid] = getValidAxes(obj);
            if isempty(ax) || ~isValid || isempty(ax.Legend)
                lgd = matlab.graphics.illustration.Legend.empty(0);
                isValid = logical.empty(0);
            else
                lgd = ax.Legend;
                isValid = true;
            end
        end

        function value = getFirstAxesPropertyValue(obj, propName)

            % Store a default object in case no axess exist yet
            persistent defaultAxes
            if isempty(defaultAxes)
                defaultAxes = matlab.graphics.axis.Axes("Parent",[]);
            end

            % Get the first valid axes
            ax = getValidAxes(obj);
            if isempty(ax)
                firstAxes = defaultAxes;
            else
                firstAxes = ax(1);
            end

            % Get the property requested
            value = firstAxes.(propName);

        end %function


        function value = getFirstLegendPropertyValue(obj, propName)

            % Store a default object in case no axess exist yet
            persistent defaultLegend
            if isempty(defaultLegend)
                defaultLegend = matlab.graphics.illustration.Legend(...
                    "Parent",[],"Visible","off");
            end

            % Get the first valid legend
            lgd = obj.getValidLegend();
            if isempty(lgd)
                lgd = defaultLegend;
            end

            % Get the property requested
            value = lgd(1).(propName);

        end %function


        function setAxesPropertyToSingleValue(obj, propName, value)

            % Get valid axes objects
            ax = obj.getValidAxes();

            % Set the property requested
            wt.utility.fastSet(ax, propName, value)

        end %function


        function setLegendPropertyToSingleValue(obj, propName, value)

            % Get valid legend objects
            lgd = obj.getValidLegend();

            % Set the property requested
            wt.utility.fastSet(lgd, propName, value)

        end %function


        function value = getFirstAxesComponentValue(obj, compName, propName)

            % Store a default object in case no axess exist yet
            persistent defaultAxes
            if isempty(defaultAxes)
                defaultAxes = matlab.graphics.axis.Axes("Parent",[]);
            end

            % Get the first valid axes
            ax = obj.getValidAxes();
            if isempty(ax)
                ax = defaultAxes;
            end
            
            % Get the property requested
            value = ax(1).(compName).(propName);

        end %function


        function setAxesComponentPropertyToSingleValue(obj, compName, propName, value)

            % Get valid objects
            ax = getValidAxes(obj);

            % Can't be empty
            if isempty(ax)
                warning("Axes is empty");
            end

            % Get components
            allComp = [ax.(compName)];

            % Set the property requested
            wt.utility.fastSet(allComp, propName, value)

        end %function

    end %methods


    %% Reserved for future use
    % These may be added in the future. Defining them here so that
    % subclasses should not use these reserved properties yet.
    properties (Transient, GetAccess = protected, SetAccess = immutable)

        Color_I
        ColorMode

        GridColor_I
        GridColorMode


        FontName_I
        FontNameMode

        FontSize_I
        FontSizeMode

        FontWeight_I
        FontWeightMode

        FontAngle
        FontAngle_I
        FontAngleMode

        FontUnits
        FontUnits_I
        FontUnitsMode

        FontSmoothing
        FontSmoothing_I
        FontSmoothingMode


        LabelFontName_I
        LabelFontNameMode

        LabelFontSize_I
        LabelFontSizeMode

        LabelFontWeight_I
        LabelFontWeightMode

        LabelFontAngle
        LabelFontAngle_I
        LabelFontAngleMode

        LabelFontUnits
        LabelFontUnits_I
        LabelFontUnitsMode

        LabelFontSmoothing
        LabelFontSmoothing_I
        LabelFontSmoothingMode

    end %properties

end %classdef