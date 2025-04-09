classdef BoundTitleText < handle
    % Mixin that binds title properties for primitive text object(s)

    %   Copyright 2025 The MathWorks Inc.

    %% Protected properties

    properties (Access = protected)

        % The internal title object(s) to bind to
        BoundTitle (:,1) matlab.graphics.primitive.Text

    end %properties


    %% Public Dependent Properties (bound to contents)
    properties (AbortSet, Dependent)

        % Axes Title Text
        Title (:,1) string

        % Title Font Color
        TitleColor

        % Title Font name
        TitleFontName

        % Title Font size in points
        TitleFontSize

        % Title Font weight (normal/bold)
        TitleFontWeight

        % Title Interpreter
        TitleInterpreter

    end %properties


     %% Property Accessors
    methods

        function value = get.BoundTitle(obj)
            value = obj.BoundTitle;
            value(~isvalid(value)) = [];
        end

        function value = get.Title(obj)
            value = obj.getTitleStrings();
        end
        function set.Title(obj, value)
            obj.setTitleStrings(value);
        end

        function value = get.TitleColor(obj)
            value = obj.getFirstTitlePropertyValue("Color");
        end
        function set.TitleColor(obj, value)
            obj.setAllTitlesToMatchingPropertyValue("Color", value);
        end

        function value = get.TitleFontName(obj)
            value = obj.getFirstTitlePropertyValue("FontName");
        end
        function set.TitleFontName(obj, value)
            obj.setAllTitlesToMatchingPropertyValue("FontName", value);
        end

        function value = get.TitleFontSize(obj)
            value = obj.getFirstTitlePropertyValue("FontSize");
        end
        function set.TitleFontSize(obj, value)
            obj.setAllTitlesToMatchingPropertyValue("FontSize", value);
        end

        function value = get.TitleFontWeight(obj)
            value = obj.getFirstTitlePropertyValue("FontWeight");
        end
        function set.TitleFontWeight(obj, value)
            obj.setAllTitlesToMatchingPropertyValue("FontWeight", value);
        end

        function value = get.TitleInterpreter(obj)
            value = obj.getFirstTitlePropertyValue("Interpreter");
        end
        function set.TitleInterpreter(obj, value)
            obj.setAllTitlesToMatchingPropertyValue("Interpreter", value);
        end

    end %methods


    %% Private methods
    methods (Access = private)

        function value = getTitleStrings(obj)
           
            % Get all title objects
            allTitle = obj.BoundTitle;

            % Default output
            value = strings(size(allTitle));

            % Get the string of each title
            isKeep = isvalid(allTitle);
            [value(isKeep)] = string({allTitle.String}');

        end %function


        function setTitleStrings(obj, value)

            arguments
                obj (1,1)
                value (:,1) string
            end

            % Get all title objects
            allTitle = obj.BoundTitle;

            % How many can we set?
            numItems = min(numel(allTitle), numel(value));

            % Loop on each
            isKeep = isvalid(allTitle);
            for idx = 1:numItems
                if isKeep(idx)
                    allTitle(idx).String = value(idx);
                end
            end

        end %function

        function value = getFirstTitlePropertyValue(obj, propName)

            % Store a default object in case no titles exist yet
            persistent defaultTitle
            if isempty(defaultTitle)
                defaultTitle = matlab.graphics.primitive.Text("Parent",[]);
            end

            % Get the first valid title
            allTitle = obj.BoundTitle(isvalid(obj.BoundTitle));
            if isempty(allTitle)
                firstTitle = defaultTitle;
            else
                firstTitle = allTitle(1);
            end

            % Get the property requested
            value = firstTitle.(propName);

        end %function


        function setAllTitlesToMatchingPropertyValue(obj, propName, value)

            % Get valid title objects
            allTitle = obj.BoundTitle(isvalid(obj.BoundTitle));

            % Set the property requested
            wt.utility.fastSet(allTitle, propName, value)

        end %function

    end %methods


    %% Reserved for future use
    % These may be added in the future. Defining them here so that
    % subclasses should not use these reserved properties yet.
    properties (Transient, GetAccess = protected, SetAccess = immutable)

        TitleFontName_I
        TitleFontNameMode

        TitleFontSize_I
        TitleFontSizeMode

        TitleFontWeight_I
        TitleFontWeightMode

        TitleColor_I
        TitleColorMode

        TitleFontAngle
        TitleFontAngle_I
        TitleFontAngleMode

        TitleFontUnits
        TitleFontUnits_I
        TitleFontUnitsMode

        TitleFontSmoothing
        TitleFontSmoothing_I
        TitleFontSmoothingMode

    end %properties

end %classdef