classdef BaseDialog2  < wt.abstract.BaseWidget & ...
        wt.mixin.TitleFontStyled
    % Base class for a dialog

    % Copyright 2022-2025 The MathWorks Inc.
    
    % To do:
    % - finish importing old BaseDialog
    % - add modal backing image
    % - make examples

    %% Public Properties
    properties (AbortSet, Access = public)

        % Dialog Size
        Size (1,2) double {mustBePositive} = [350 200]

    end %properties


    properties (AbortSet, Dependent, Access = public)

        % Dialog Title
        Title

        % Background Color
        TitleBackgroundColor

        % Background color mode
        %TitleBackgroundColorMode (1,1) wt.enum.AutoManualState = 'auto'

    end %properties


    % Accessors
    methods

        function value = get.Title(obj)
            value = obj.OuterPanel.Title;
        end
        function set.Title(obj, value)
            obj.OuterPanel.Title = value;
        end

        function value = get.TitleBackgroundColor(obj)
            value = obj.OuterPanel.BackgroundColor;
        end
        function set.TitleBackgroundColor(obj, value)
            obj.OuterPanel.BackgroundColor = value;
        end

        % function value = get.TitleBackgroundColorMode(obj)
        %     value = wt.enum.AutoManualState(obj.OuterPanel.BackgroundColorMode);
        % end
        % function set.TitleBackgroundColorMode(obj, value)
        %     obj.OuterPanel.BackgroundColorMode = char(value);
        % end

        % function value = get.Size(obj)
        %     value = obj.Position(3:4);
        % end
        % function set.Size(obj, value)
        %     obj.Position(3:4) = value;
        % end

    end %methods


    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = private)

        % Outer grid to enable the panel to fill the component
        OuterGrid matlab.ui.container.GridLayout

        % Outer panel for the dialog
        OuterPanel matlab.ui.container.Panel

        % Close button
        CloseButton matlab.ui.control.Button

        % Temporary drag helper for moving the window
        DragHelper wt.utility.FigureDragHelper {mustBeScalarOrEmpty}

        % Listeners to reference/parent objects to trigger dialog delete
        LifecycleListeners (1,:) event.listener

        % Figure containing the dialog
        Figure matlab.ui.Figure

        % Figure resize listener
        FigureResizeListener (1,:) event.listener  {mustBeScalarOrEmpty}

    end %properties


    %% Protected methods
    methods (Access = protected)
        
        function setup(obj)
            % Configure the widget

            % Defaults
            obj.Position(3:4) = [350,200];
            obj.TitleFontSize = 16;
            
            % Outer grid to enable the dialog panel to fill the component
            obj.OuterGrid = uigridlayout(obj,[1 1]);
            obj.OuterGrid.Padding = [0 0 0 0];

            % Outer dialog panel
            obj.OuterPanel = uipanel(obj.OuterGrid);
            obj.OuterPanel.Title = "Dialog Title";
            obj.OuterPanel.BorderWidth = 1;
            obj.OuterPanel.AutoResizeChildren = false;
            obj.OuterPanel.ResizeFcn = @(~,~)onOuterPanelResize(obj);
            obj.OuterPanel.ButtonDownFcn = @(~,evt)onTitleButtonDown(obj,evt);
            
            % Inner Grid to manage building blocks
            obj.Grid = uigridlayout(obj.OuterPanel,[1 1]);
            obj.Grid.Padding = 10;
            obj.Grid.RowSpacing = 5;
            obj.Grid.ColumnSpacing = 5;
            obj.Grid.Scrollable = true;

            % Close Button
            obj.CloseButton = uibutton(obj.OuterPanel);
            obj.CloseButton.Text = "";
            obj.CloseButton.IconAlignment = "center";
            obj.CloseButton.ButtonPushedFcn = @(src,evt)obj.onClosePushed();

            % Apply theme colors
            if ~isMATLABReleaseOlderThan("R2025a")
                obj.OuterPanel.BorderColor = obj.getThemeColor("--mw-borderColor-secondary");
                obj.OuterPanel.BackgroundColor = obj.getThemeColor("--mw-backgroundColor-secondary");
                % obj.CloseButton.BackgroundColor = obj.getThemeColor("--mw-backgroundColor-iconuiFill-primary");
            else
                obj.OuterPanel.BorderColor = [.5 .5 .5];
                obj.OuterPanel.BackgroundColor = [.9 .9 .9];
                % obj.CloseButton.BackgroundColor = [.38 .38 .38];
            end

            % Apply close button color
            obj.applyCloseButtonColor()

            % Listen to figure size changes
            obj.Figure = ancestor(obj,'figure');
            obj.FigureResizeListener = listener(obj.Figure,"SizeChanged",...
                @(~,evt)onFigureResized(obj,evt));

            % Ensure it fits in the figure
            obj.resizeToFitFigure();

            % Reposition the close button
            obj.repositionCloseButton();

            % Update component lists
            obj.TitleFontStyledComponents = obj.OuterPanel;

        end %function


        function update(~)

            
        end %function


        function onClosePushed(obj)
            % Triggered when close button is pushed

            % Delete the dialog
            delete(obj)

        end %function


        function onFigureResized(obj,~)
            % Triggered on figure resize

            % Ensure it fits in the figure
            obj.resizeToFitFigure();

            % Reposition the close button
            obj.repositionCloseButton();

        end %function


        function onOuterPanelResize(obj)
            % Triggered when the dialog window is resized

            % Ensure it fits in the figure
            obj.resizeToFitFigure();

            % Reposition the close button
            obj.repositionCloseButton();

        end %function


        function onTitleButtonDown(obj,~)
            % Triggered on title bar button down

            % Instantiate a figure drag helper to begin dragging dialog
            obj.DragHelper = wt.utility.FigureDragHelper(obj);
            obj.DragHelper.DragFcn = @(dhObj,evt)onMouseDrag(obj,evt);

        end %function


        function attachLifecycleListeners(obj, owners)
            % Delete the dialog automatically upon destruction of the specified "owner" graphics objects

            arguments
                obj (1,1) wt.abstract.BaseDialog
                owners handle   
            end

            % Create listeners
            % The dialog will be deleted if the listenObj is deleted
            newListeners = listener(owners, "ObjectBeingDestroyed",...
                @(src,evt)delete(obj));

            % Add to any existing listeners
            obj.LifecycleListeners = horzcat(obj.LifecycleListeners, newListeners);

        end %function


        function color = getDefaultTitleColor(obj)
            % Returns the default color for 'auto' mode (R2025a and later)

            color = obj.getThemeColor("--mw-color-primary");

        end %function

    end %methods


    %% Private methods
    methods (Access = private)


        function repositionCloseButton(obj)
            % Triggered on figure resize

            % Outer panel inner/outer position
            outerPos = obj.OuterPanel.OuterPosition;
            wO = outerPos(3);
            hO = outerPos(4);
            
            innerPos = obj.OuterPanel.InnerPosition();
            wI = innerPos(3);
            hI = innerPos(4);
            
            % Calculate panel border width and title height
            wBorder = (wO - wI) / 2; 
            hT = hO - hI - 3*wBorder;

            % Calculate close button positioning
            hB = max(hT-4, 8) ;
            yB = hO - 2*wBorder - hB - 1;
            wB = hB;
            xB = wO - 2*wBorder - wB - 1;

            % Move the close button
            obj.CloseButton.Position = [xB yB wB hB];

        end %function


        function resizeToFitFigure(obj)
            % Triggered on figure resize
     
            % Get the current positioning
            posD = obj.Position;
            szRequest = obj.Size;
            posLowerLeft = posD(1:2);

            % Get figure size
            posF = getpixelposition(obj.Figure);
            szF = posF(3:4);
            buffer = [20 20];
            maxSize = szF - buffer;

            % Size is the smaller of requested size and figure size with
            % buffer space
            szD = min(szRequest, maxSize);

            % Restrict a minimum size also
            minSize = [30 20];
            szD = max(szD, minSize);

            % Calculate fit within figure
            posUpperRight = posLowerLeft + szD;
            if any(posUpperRight > szF)
                posAdjust = szF - posUpperRight;
                posLowerLeft = posLowerLeft + posAdjust;
            end

            % Don't go below 1
            posLowerLeft = max(posLowerLeft, 1);

            % Update position
            posNew = [posLowerLeft szD];
            obj.Position = posNew;
            
        end %function


        function onMouseDrag(obj,evt)
            % Triggered from DragHelper during drag or release

            % Check the drag event status
            switch evt.Status

                case "motion"
                    obj.Position = evt.NewPosition;

                case "complete"
                    obj.Position = evt.NewPosition;
                    delete(obj.DragHelper)
                    obj.DragHelper(:) = [];

            end %switch
            
        end %function


        function applyCloseButtonColor(obj)
            % Set color of close button

            % Create the "X" image mask
            persistent imgMask
            if isempty(imgMask)
                imgMask = eye(16,16,"logical");
                % Make it an X
                imgMask = imgMask | flip(imgMask);
                % Widen the line
                imgMask = imgMask | circshift(imgMask,1,1)  | circshift(imgMask,-1,1);
            end

            % Determine the color to use
            if ~isMATLABReleaseOlderThan("R2025a")
                bgColor = obj.getThemeColor("--mw-backgroundColor-secondary");
                iconColor = obj.getThemeColor("--mw-backgroundColor-iconuiFill-primary");
            else
                bgColor = [.9 .9 .9];
                iconColor = [.38 .38 .38];
            end

            % Create the RGB components of the image
            closeImgPage = zeros(16,16);
            closeImg = repmat(closeImgPage,[1 1 3]);
            for idx = 1:3
                closeImgPage(imgMask) = iconColor(idx);
                closeImgPage(~imgMask) = bgColor(idx);
                closeImg(:,:,idx) = closeImgPage;
            end

            % Apply theicon
            obj.CloseButton.Icon = closeImg;
            obj.CloseButton.BackgroundColor = bgColor;

        end %function

    end %methods


end %classdef