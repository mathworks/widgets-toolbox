classdef TickableDateSlider < handle
    %TickableDateSlider - Add date ticks to a slider component
    %   OBJ = TickableDateSlider(PARENT) adds shared tick calculation for
    %   date-based slider widgets.
    %
    %   See also wt.DateSlider, wt.DateRangeSlider

    % Copyright 2026 The MathWorks, Inc.

    %% Abstract properties
    properties (Abstract, Transient, NonCopyable, Hidden, SetAccess = protected)

        % Slider
        Slider

    end

    %% Protected methods
    methods (Access = protected)

        function [majorTicks, minorTicks] = getSliderTicks(obj, orientation, options)
            %getSliderTicks - Calculate major and minor date slider ticks

            arguments
                obj (1,1)
                orientation (1,1) string {mustBeMember(orientation, ["horizontal" "vertical"])} = "horizontal";
                options.TickLength (1,1) double {mustBeInteger, mustBePositive} = 11
            end

            sliderLimits = obj.Slider.Limits;
            lowerTick = ceil(sliderLimits(1));
            upperTick = floor(sliderLimits(2));

            if lowerTick > upperTick
                lowerTick = round(sliderLimits(1));
                upperTick = lowerTick;
            end

            % What space is needed for the labels?
            % Depends on font size and font weight.
            if string(obj.Slider.FontWeight) == "bold"
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
                minSpaceForTickLabel = ...
                    elSize * fontSize * options.TickLength;
            else
                % Size of slider. Always in pixel units (cannot be changed)
                sliderSpace = obj.Slider.Position(4);

                % Minimum space required for label
                minSpaceForTickLabel = elSize * fontSize * 2;
            end

            minSpaceForTickLabel = max(1, minSpaceForTickLabel);
            maxMajorTicks = max(2, floor(sliderSpace / minSpaceForTickLabel) + 1);
            majorTicks = selectSliderTicks(lowerTick, upperTick, maxMajorTicks);

            % How much space is left for the minor ticks?
            minSpaceForMinorTick = 10;
            maxMinorTicks = max(2, floor(sliderSpace / minSpaceForMinorTick) + 1);
            minorTicks = selectSliderTicks(lowerTick, upperTick, maxMinorTicks);
        end

    end

end

function ticks = selectSliderTicks(lowerTick, upperTick, maxTickCount)
%selectSliderTicks - Select integer ticks between two slider limits

span = upperTick - lowerTick;
if span == 0
    ticks = lowerTick;
    return
end

allTicks = lowerTick:upperTick;
if numel(allTicks) <= maxTickCount
    ticks = allTicks;
    return
end

maxTickCount = max(2, floor(maxTickCount));
stepSize = max(1, ceil(span / (maxTickCount - 1)));
ticks = lowerTick:stepSize:upperTick;

if ticks(end) ~= upperTick
    ticks(end + 1) = upperTick;
end

ticks = unique(ticks);

end
