classdef BoundMultiTimeAxes < handle
    % Mixin that binds axes properties for a chartcontainer subclass

    %% Protected properties

    properties (Access = protected)

        % The internal axes object to bind to
        BoundAxes (:,1)

        % The axes legends to bind to
        BoundLegend (:,1)

    end %properties


    %% Public Dependent Properties (bound to contents)
    properties (AbortSet, Dependent)

        % Font Color
        Color

        % Grid color
        GridColor

        % X-Axis Label
        XLabel (1,1) string

        % Y-Axis Label
        YLabel (:,1) string

        % Axes Y-Limits
        YLim (:,2) cell

        % Axes Y-Limit Mode
        YLimMode (1,1) string

        % Font name
        FontName

        % Font size
        FontSize

        % Font weight
        FontWeight

        % Interpreter
        Interpreter

        % Axes Labels Font name
        LabelFontName

        % Axes Labels Font size in points
        LabelFontSize

        % Axes Labels Font weight (normal/bold)
        LabelFontWeight

        % Show grid on each axes?
        ShowGrid

        % Show legend on each axes?
        ShowLegend

    end %properties


     %% Property Accessors
    methods

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
            ax = getValidAxes(obj);
            if isempty(ax)
                value = "";
            else
                value = ax(end).XLabel.String;
            end
        end
        function set.XLabel(obj, value)
            ax = getValidAxes(obj);
            if ~isempty(ax)
                ax(end).XLabel.String = value;
            end
        end

        function value = get.YLabel(obj)
            [ax, isValid] = getValidAxes(obj);
            value = strings(size(isValid));
            value(isValid) = [string({ax(isValid.YLabel.String)})];
        end
        function set.YLabel(obj, value)
            [ax, isValid] = getValidAxes(obj);
            numAxes = numel(isValid);
            value = wt.utility.resizeVector(value, numAxes, "");
            valueV = value(isValid);
            for idx = 1:numel(ax)
                ax(idx).YLabel.String = valueV(idx);
            end
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
            lgd = obj.BoundLegend;
            isValid = isvalid(lgd);
            lgd = lgd(isValid);
        end

        function value = getFirstAxesPropertyValue(obj, propName)

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
            value = ax(1).(propName);

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


        % function setComponentProperty(~, allComp, propName, value)
        %
        %     % Get valid objects
        %     allComp(~isvalid(allComp)) = [];
        %
        %     % Set the property requested
        %     wt.utility.fastSet(allComp, propName, value)
        %
        % end %function


        function setAxesComponentPropertyToSingleValue(obj, compName, propName, value)

            % Get valid objects
            ax = getValidAxes(obj);

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