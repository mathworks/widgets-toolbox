classdef TickableDateSlider < handle
    % Mixin to add date ticks to a slider component

    %% Abstract properties
    properties (Abstract, Transient, NonCopyable, Hidden, SetAccess = protected)

        % Slider
        Slider matlab.ui.control.internal.model.mixin.SliderComponent {mustBeScalarOrEmpty}

    end

    %% Protected methods
    methods (Access = protected)

        function [majorTicks, minorTicks] = getSliderTicks(obj, orientation, options)
            % Update the limits in date-picker and slider

            arguments
                obj (1,1)                
                orientation (1,1) string {mustBeMember(orientation, ["horizontal" "vertical"])} = "horizontal";
                options.TickLength (1,1) double {mustBeInteger, mustBePositive}
            end

            % How many days?
            nDays = obj.Slider.Limits(2) + 1;

            % What space is needed for the labels?
            % Depends on font size and font weight.
            if obj.Slider.FontWeight == "bold"
                elSize = 0.6;
            else
                elSize = 0.5;
            end
            fontSize = obj.Slider.FontSize; 

            % What is the slider orientation?
            if orientation == "horizontal"

                % Size of slider. Always in pixel units (cannot be changed)
                sliderSpace = obj.Slider.Position(3);

                % Minimum space required for label
                if isfield(options, 'TickLength')
                    tickLength = options.TickLength;
                else
                    tickLength = 11;
                end
                minSpaceForTickLabel = elSize * fontSize * tickLength;
            else                
                % Size of slider. Always in pixel units (cannot be changed)
                sliderSpace = obj.Slider.Position(4);

                % Minimum space required for label
                minSpaceForTickLabel = elSize * fontSize * 2;
            end

            % How many major ticks fit in the available size?
            maxMajorInterval = floor(sliderSpace / minSpaceForTickLabel) - 1;
            maxMajorInterval = max(1, maxMajorInterval);

            % How large are the steps for the major ticks?

            % Is the interval size a prime number?
            if isprime((nDays - 1))
                majorIntervalStep = max(1, round((nDays - 1) / maxMajorInterval));
            else
                majorStepArray = (nDays - 1) ./ (maxMajorInterval:-1:1);
                isIntegerStepSize = majorStepArray == floor(majorStepArray);
                majorIntervalStep = majorStepArray(find(isIntegerStepSize, 1));
            end

            % At what tick location do the major tick labels need to go?
            majorTicks = floor(0:majorIntervalStep:(nDays - 1));
            majorTicks(end + 1) = (nDays - 1);

            % How much space is left for the minor ticks?
            minSpaceForMinorTick = 10;
            nMajorInterval = ((nDays - 1) / majorIntervalStep);
            maxMinorInterval = floor(sliderSpace / nMajorInterval / minSpaceForMinorTick);
            
            % Is there enough room for all steps that are left between the major
            % ticks?
            if maxMinorInterval < majorIntervalStep

                % What is the maximum number of minor ticks that can fit in the
                % major tick interval?
                minorStepArray = majorIntervalStep ./ (maxMinorInterval:-1:1);
                isIntegerStepSize = minorStepArray == floor(minorStepArray);
                minorIntervalStep = minorStepArray(find(isIntegerStepSize, 1));
            else
                minorIntervalStep = 1;
            end

            % How much room is available between the major ticks?
            minorTickSteps = majorTicks(1):minorIntervalStep:majorTicks(2);
            minorTicks = majorTicks + minorTickSteps(:);
            minorTicks = unique(minorTicks(:)');
        end

    end

end