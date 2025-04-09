classdef FigureDragData < event.EventData
    % Event data for dragging an object within a figure
    
    % Copyright 2025 The MathWorks, Inc.

    %% Properties
    properties
        Status (1,1) string {mustBeMember(Status,["motion","complete"])} = "motion"
        InitialPosition (1,4) double = nan(1,4)
        NewPosition (1,4) double = nan(1,4)
        MouseStartPoint (1,2) double = nan(1,2)
        MouseCurrentPoint (1,2) double = nan(1,2)
        MouseDistance (1,2) double = nan(1,2)
    end %properties


end % classdef