classdef ImageGallery < wt.abstract.BaseWidget
    % A gallery of images

    % Copyright 2020-2021 The MathWorks Inc.

    %RAJ - to do:
    % verify performance with bigger files
    % Do we need thumbnail generation??
    % Enable setting a folder instead of a file list
    %   Enable a file type filter in this case

    %% Public properties
    properties (AbortSet)

        % Size of the image space in pixels
        ImageSize (1,1) double = 200

        % Image file sources
        ImageSource (:,1) string = [""; ""; ""]

    end %properties


    %% Internal Properties
    properties ( Transient, NonCopyable, ...
            Access = {?wt.abstract.BaseWidget, ?wt.test.BaseWidgetTest} )

        % Image controls
        Image (1,:) matlab.ui.control.Image

        % Size changed listener
        SizeChangedListener event.listener

    end %properties


    properties (AbortSet, Transient, NonCopyable, ...
            Access = {?wt.abstract.BaseWidget, ?wt.test.BaseWidgetTest} )

        % Number of visible [rows columns]
        GridSize (1,2) double = [1 3]

    end %properties



    %% Protected methods
    methods (Access = protected)

        function setup(obj)

            % Call superclass setup first to establish the grid
            obj.setup@wt.abstract.BaseWidget();

            % Set default size
            obj.Position(3:4) = [400 400];
            obj.Grid.Padding = [0 0 0 0];

            % Turn on scrollability
            obj.Grid.Scrollable = true;

            % Listen to resize events
            obj.SizeChangedListener = event.listener(obj,"SizeChanged",...
                @(src,evt)obj.onSizeChanged(evt) );

        end %function


        function update(obj)

            % How many images are needed?
            numImg = numel(obj.ImageSource);
            oldNum = numel(obj.Image);

            % Check and update grid size as needed
            obj.updateGridSize();

            % Calculate layout position of each image
            cIdx = repmat(1:obj.GridSize(2), obj.GridSize(1), 1)';
            rIdx = repmat(1:obj.GridSize(1), obj.GridSize(2), 1);

            % Add new images if needed
            if numImg > oldNum
                for idx = oldNum+1:numImg
                    obj.Image(idx) = uiimage(obj.Grid, "ScaleMethod", "fill");
                    obj.Image(idx).Layout.Row = rIdx(idx);
                    obj.Image(idx).Layout.Column = cIdx(idx);
                end
            end %if

            % Update each image source
            for idx = 1:numImg
                wt.utility.fastSet(obj.Image(idx),...
                    "ImageSource", obj.ImageSource(idx));
            end %for

            % Delete any extra images
            delete( obj.Image(numImg+1:end) )
            obj.Image(numImg+1:end) = [];

        end %function

    end %methods



    %% Private methods
    methods %(Access = private)

        function onSizeChanged(obj,~)
            % Triggered on size changed

            % Check and update grid size as needed
            %obj.updateGridSize();
            obj.requestUpdate();

        end %function


        function updateGridSize(obj)
            % Calculate and update the grid size

            % How many images?
            numImg = numel(obj.ImageSource);

            % How much space do we have?
            if obj.Units == "pixels"
                wAvail = obj.Position(3) + obj.Grid.ColumnSpacing;
            else
                pos = getpixelposition(obj.Grid);
                wAvail = (pos(3) + obj.Grid.ColumnSpacing);
            end

            % How many images do we need to fit?
            wPerImg = obj.ImageSize + obj.Grid.ColumnSpacing;

            % How many full columns fit across?
            numCol = max(1, floor(wAvail/wPerImg));

            % How many rows do we need? (Rows can be scrolled down)
            numRow = max(1, ceil(numImg/numCol));

            % Update the layout size
            obj.GridSize = [numRow numCol];

        end %function


        function updateLayout(obj)
            % Update the layout based on the current GridSize
            % This should only be called by set.GridSize

            % How many images?
            numImg = min( prod(obj.GridSize), numel(obj.Image) );

            % Make the layout updates
            colWidth = repmat({obj.ImageSize}, 1, obj.GridSize(2));
            rowHeight = repmat({obj.ImageSize}, 1, obj.GridSize(1));

            % Calculate layout position of each image
            rIdx = repmat(1:obj.GridSize(1), obj.GridSize(2), 1);
            cIdx = repmat(1:obj.GridSize(2), obj.GridSize(1), 1)';

            % Update layout position of each image
            for idx = 1:numImg
                obj.Image(idx).Layout.Row = rIdx(idx);
                if obj.Image(idx).Layout.Column ~= cIdx(idx)
                    obj.Image(idx).Layout.Column = cIdx(idx);
                end
            end %for

            % Update the grid layout sizes
            obj.Grid.RowHeight = rowHeight;
            obj.Grid.ColumnWidth = colWidth;

        end %function


    end %methods


    %% Accessors
    methods

        function set.GridSize(obj,value)
            obj.GridSize = value;
            obj.updateLayout();
        end

    end % methods

end % classdef

