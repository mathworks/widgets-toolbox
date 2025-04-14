classdef FigureDragHelper < handle
    % Helper for dragging a component within a figure

    % Copyright 2025 The MathWorks, Inc.

    %% Events
    events

        % Triggered during drag and on button release
        Drag

    end %events


    %% Properties
    properties

        DragFcn function_handle {mustBeScalarOrEmpty}

    end %properties


    properties (SetAccess = private)

        % Status of the helper
        Status (1,1) string {mustBeMember(Status,["motion","complete"])} = "motion"

        % The subject being dragged
        Subject

        % Size of the subject
        SubjectSize (1,2) double = nan(1,2)

        % Initial position of the subject
        InitialPosition (1,4) double = nan(1,4)

        % Initial point where the drag begins
        StartPoint (1,2) double = nan(1,2)

        % Figure containing the subject
        Figure

        % Position of the container
        FigurePosition (1,4) double = nan(1,4)

        % Container the subject is dragged within
        % Container

    end %properties

    
    properties

        % Minimum subject position when dragging
        MinSubjectPosition (1,2) double = nan(1,2)

        % Maximum subject position when dragging
        MaxSubjectPosition (1,2) double = nan(1,2)

    end %properties


    properties (Access = private)

        % Listener for figure mouse motion
        MouseMotionListener

        % Listener for mouse button release
        MouseReleaseListener

    end %properties


    %% Constructor
    methods

        function obj = FigureDragHelper(subject, bounds)

            arguments
                subject (1,1) matlab.graphics.Graphics
                bounds (1,4) double = nan(1,4)
            end

            % Get figure
            obj.Figure = ancestor(subject,'figure');

            % Ensure figure is in pixels
            if obj.Figure.Units ~= "pixels"
                id = "wt:utility:DragHelper:FigurePixels";
                msg = "DragHelper requires setting figure Units to pixels.";
                warning(id,msg);
                obj.Figure.Units = "pixels";
            end

            % Get starting point in figure
            obj.StartPoint = obj.Figure.CurrentPoint;

            % Get figure size
            posFig = obj.Figure.Position;
            szFig = posFig(3:4);

            % Get container the drag is within
            %obj.Container = subject.Parent;

            % Get subject
            obj.Subject = subject;

            % Get subject size
            if isprop(subject,"OuterPosition")
                obj.InitialPosition = subject.OuterPosition;
            else
                obj.InitialPosition = subject.Position;
            end
            obj.SubjectSize = obj.InitialPosition(3:4);

            % Get bounds. If not provided, use the figure bounds.
            if any(ismissing(bounds))
                obj.FigurePosition = posFig;
            else
                obj.FigurePosition = bounds;
            end

            % Find valid drag position range
            obj.MinSubjectPosition = [1 1];
            obj.MaxSubjectPosition = szFig - obj.SubjectSize;

            % While dragging, listen to figure mouse events
            obj.MouseMotionListener = listener(obj.Figure,...
                "WindowMouseMotion",@(~,evt)onMouseMotion(obj,evt));
            obj.MouseReleaseListener = listener(obj.Figure,...
                "WindowMouseRelease",@(~,evt)onMouseRelease(obj,evt));

        end %function

    end %methods


    %% Private methods
    methods (Access = private)

        function onMouseMotion(obj,evt)

            % Calculate position change
            currentPoint = evt.Point;
            dPos = currentPoint - obj.StartPoint;
            posNew = obj.InitialPosition(1:2) + dPos;

            % Keep new position within bounds
            posNew = max(posNew, obj.MinSubjectPosition);
            posNew = min(posNew, obj.MaxSubjectPosition);

            % Prepare event data
            evt = wt.eventdata.FigureDragData;
            evt.Status = obj.Status;
            evt.NewPosition = [posNew, obj.InitialPosition(3:4)];
            evt.InitialPosition = obj.InitialPosition;
            evt.MouseDistance = dPos;
            evt.MouseStartPoint = obj.StartPoint;
            evt.MouseCurrentPoint = currentPoint;

            % Trigger event and call callback function
            notify(obj,"Drag",evt)
            if ~isempty(obj.DragFcn)
                obj.DragFcn(obj.Subject, evt);
            end

        end %function


        function onMouseRelease(obj,evt)

            % Terminate the listeners
            delete(obj.MouseMotionListener)
            delete(obj.MouseReleaseListener)
            obj.MouseMotionListener = [];
            obj.MouseReleaseListener = [];

            % Inidicate status complete
            obj.Status = "complete";

            % Calculate position change
            currentPoint = evt.Point;
            dPos = currentPoint - obj.StartPoint;
            posNew = obj.InitialPosition(1:2) + dPos;

            % Keep new position within bounds
            posNew = max(posNew, obj.MinSubjectPosition);
            posNew = min(posNew, obj.MaxSubjectPosition);

            % Prepare event data
            evt = wt.eventdata.FigureDragData;
            evt.Status = obj.Status;
            evt.NewPosition = [posNew, obj.InitialPosition(3:4)];
            evt.InitialPosition = obj.InitialPosition;
            evt.MouseDistance = dPos;
            evt.MouseStartPoint = obj.StartPoint;
            evt.MouseCurrentPoint = currentPoint;

            % Trigger event and call callback function
            notify(obj,"Drag",evt)
            if ~isempty(obj.DragFcn)
                obj.DragFcn(obj.Subject, evt);
            end

        end %function


    end %methods


end %classdef