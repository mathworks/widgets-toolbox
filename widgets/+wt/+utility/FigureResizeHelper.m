classdef FigureResizeHelper < handle
    % Helper for resizing a component within a figure

    % Copyright 2026 The MathWorks, Inc.

    %% Events
    events

        % Triggered during resize and on button release
        Resize

    end %events


    %% Properties
    properties

        ResizeFcn function_handle {mustBeScalarOrEmpty}

    end %properties


    properties (SetAccess = private)

        % Status of the helper
        Status (1,1) string {mustBeMember(Status,["motion","complete"])} = "motion"

        % The subject being resized
        Subject

        % Edge being resized
        Edge (1,1) string {mustBeMember(Edge,["left","right","top","bottom",...
            "top-left","top-right","bottom-left","bottom-right"])} = "right"

        % Minimum subject size
        MinimumSize (1,2) double = [1 1]

        % Initial position of the subject
        InitialPosition (1,4) double = nan(1,4)

        % Initial point where the resize begins
        StartPoint (1,2) double = nan(1,2)

        % Figure containing the subject
        Figure

        % Bounds for the subject [left bottom width height]
        Bounds (1,4) double = nan(1,4)

    end %properties


    properties (Access = private)

        % Listener for figure mouse motion
        MouseMotionListener

        % Listener for mouse button release
        MouseReleaseListener

    end %properties


    %% Constructor / Destructor
    methods

        function obj = FigureResizeHelper(subject, edge, minimumSize, bounds)

            arguments
                subject (1,1) matlab.graphics.Graphics
                edge (1,1) string {mustBeMember(edge,["left","right","top","bottom",...
                    "top-left","top-right","bottom-left","bottom-right"])}
                minimumSize (1,2) double {mustBePositive} = [1 1]
                bounds (1,4) double = nan(1,4)
            end

            % Get figure
            obj.Figure = ancestor(subject,'figure');

            % Ensure figure is in pixels
            if obj.Figure.Units ~= "pixels"
                id = "wt:utility:ResizeHelper:FigurePixels";
                msg = "ResizeHelper requires setting figure Units to pixels.";
                warning(id,msg);
                obj.Figure.Units = "pixels";
            end

            % Get starting point in figure
            obj.StartPoint = obj.Figure.CurrentPoint;

            % Get bounds. If not provided, use the figure bounds.
            if any(isnan(bounds))
                posFig = getpixelposition(obj.Figure);
                obj.Bounds = [1 1 posFig(3:4)];
            else
                obj.Bounds = bounds;
            end

            % Get subject
            obj.Subject = subject;
            obj.Edge = edge;
            obj.MinimumSize = minimumSize;

            % Get subject position
            if isprop(subject,"OuterPosition")
                obj.InitialPosition = subject.OuterPosition;
            else
                obj.InitialPosition = subject.Position;
            end

            % While resizing, listen to figure mouse events
            obj.MouseMotionListener = listener(obj.Figure,...
                "WindowMouseMotion",@(~,evt)onMouseMotion(obj,evt));
            obj.MouseReleaseListener = listener(obj.Figure,...
                "WindowMouseRelease",@(~,evt)onMouseRelease(obj,evt));

        end %function


        function delete(obj)

            delete(obj.MouseMotionListener)
            delete(obj.MouseReleaseListener)

        end %function

    end %methods


    %% Static methods
    methods (Static)

        function edge = getResizeEdge(point, position, borderWidth)
            % Get the resize edge for a point over a positioned rectangle

            arguments
                point (1,2) double {mustBeFinite}
                position (1,4) double {mustBeFinite}
                borderWidth (1,1) double {mustBeNonnegative}
            end

            % Default: no resize edge
            edge = "";

            if borderWidth == 0
                return
            end

            % Get inclusive edges
            left = position(1);
            bottom = position(2);
            right = position(1) + position(3) - 1;
            top = position(2) + position(4) - 1;

            % Is the point within the rectangle?
            isInside = point(1) >= left && point(1) <= right && ...
                point(2) >= bottom && point(2) <= top;
            if ~isInside
                return
            end

            % Is the point within any resize border?
            isLeft = point(1) - left < borderWidth;
            isRight = right - point(1) < borderWidth;
            isBottom = point(2) - bottom < borderWidth;
            isTop = top - point(2) < borderWidth;

            % Determine edge/corner
            if isLeft && isTop
                edge = "top-left";
            elseif isRight && isTop
                edge = "top-right";
            elseif isLeft && isBottom
                edge = "bottom-left";
            elseif isRight && isBottom
                edge = "bottom-right";
            elseif isLeft
                edge = "left";
            elseif isRight
                edge = "right";
            elseif isTop
                edge = "top";
            elseif isBottom
                edge = "bottom";
            end

        end %function


        function pointer = getResizePointer(edge)
            % Get the figure pointer name for a resize edge

            arguments
                edge (1,1) string
            end

            switch edge
                case "left"
                    pointer = "left";
                case "right"
                    pointer = "right";
                case "top"
                    pointer = "top";
                case "bottom"
                    pointer = "bottom";
                case "top-left"
                    pointer = "topl";
                case "top-right"
                    pointer = "topr";
                case "bottom-left"
                    pointer = "botl";
                case "bottom-right"
                    pointer = "botr";
                otherwise
                    pointer = "arrow";
            end

        end %function


        function tf = isResizePointer(pointer)
            % Is a figure pointer one of the resize pointers?

            arguments
                pointer (1,1) string
            end

            resizePointers = ["left","right","top","bottom",...
                "topl","topr","botl","botr"];
            tf = any(pointer == resizePointers);

        end %function


        function posNew = calculateResizedPosition(initialPosition, mouseDistance, edge, bounds, minimumSize)
            % Calculate a resized position constrained by bounds and size

            arguments
                initialPosition (1,4) double {mustBeFinite}
                mouseDistance (1,2) double {mustBeFinite}
                edge (1,1) string
                bounds (1,4) double {mustBeFinite}
                minimumSize (1,2) double {mustBePositive}
            end

            % Bounds
            boundsLeft = bounds(1);
            boundsBottom = bounds(2);
            boundsRight = bounds(1) + bounds(3) - 1;
            boundsTop = bounds(2) + bounds(4) - 1;
            minimumSize = min(minimumSize, bounds(3:4));

            % Initial edges
            left = initialPosition(1);
            bottom = initialPosition(2);
            right = initialPosition(1) + initialPosition(3) - 1;
            top = initialPosition(2) + initialPosition(4) - 1;

            % Requested mouse movement
            dx = mouseDistance(1);
            dy = mouseDistance(2);

            % Horizontal resize
            if contains(edge,"left")
                requestedLeft = initialPosition(1) + dx;
                left = max(requestedLeft, boundsLeft);
                left = min(left, right - minimumSize(1) + 1);
            elseif contains(edge,"right")
                requestedRight = initialPosition(1) + initialPosition(3) - 1 + dx;
                right = min(requestedRight, boundsRight);
                right = max(right, left + minimumSize(1) - 1);
            end

            % Vertical resize
            if contains(edge,"bottom")
                requestedBottom = initialPosition(2) + dy;
                bottom = max(requestedBottom, boundsBottom);
                bottom = min(bottom, top - minimumSize(2) + 1);
            elseif contains(edge,"top")
                requestedTop = initialPosition(2) + initialPosition(4) - 1 + dy;
                top = min(requestedTop, boundsTop);
                top = max(top, bottom + minimumSize(2) - 1);
            end

            % Compose output position
            posNew = [left bottom right-left+1 top-bottom+1];

        end %function

    end %methods


    %% Private methods
    methods (Access = private)

        function onMouseMotion(obj,evt)

            obj.sendResizeEvent(evt.Point);

        end %function


        function onMouseRelease(obj,evt)

            % Terminate the listeners
            delete(obj.MouseMotionListener)
            delete(obj.MouseReleaseListener)
            obj.MouseMotionListener = [];
            obj.MouseReleaseListener = [];

            % Indicate status complete
            obj.Status = "complete";

            obj.sendResizeEvent(evt.Point);

        end %function


        function sendResizeEvent(obj, currentPoint)

            % Calculate position change
            dPos = currentPoint - obj.StartPoint;
            posNew = wt.utility.FigureResizeHelper.calculateResizedPosition(...
                obj.InitialPosition, dPos, obj.Edge, obj.Bounds, obj.MinimumSize);

            % Prepare event data
            evt = wt.eventdata.FigureResizeData;
            evt.Status = obj.Status;
            evt.Edge = obj.Edge;
            evt.NewPosition = posNew;
            evt.InitialPosition = obj.InitialPosition;
            evt.MouseDistance = dPos;
            evt.MouseStartPoint = obj.StartPoint;
            evt.MouseCurrentPoint = currentPoint;

            % Trigger event and call callback function
            notify(obj,"Resize",evt)
            if ~isempty(obj.ResizeFcn)
                obj.ResizeFcn(obj.Subject, evt);
            end

        end %function

    end %methods

end %classdef
