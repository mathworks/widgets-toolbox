classdef BaseDialog2  < wt.abstract.BaseWidget
    % Base class for a dialog

    % Copyright 2022-2025 The MathWorks Inc.
    
    % To do:
    % - finish importing old BaseDialog
    % - make examples
    % - handle theme changes

    %% Public Properties
    properties (AbortSet, Access = public)

        % Dialog Size
        Size (1,2) double {mustBePositive} = [350 200]

    end %properties


    properties (AbortSet, Dependent, Access = public)

        % Modal (block other figure interaction)
        Modal

        % Dialog Title
        Title

        % Background Color
        % TitleBackgroundColor

        % Background color mode
        %TitleBackgroundColorMode (1,1) wt.enum.AutoManualState = 'auto'

    end %properties


    % Accessors
    methods

        function value = get.Modal(obj)
            value = obj.ModalImage.Visible;
        end
        function set.Modal(obj, value)
            obj.ModalImage.Visible = value;
        end

        function value = get.Title(obj)
            value = obj.OuterPanel.Title;
        end
        function set.Title(obj, value)
            obj.OuterPanel.Title = value;
        end

        % function value = get.TitleBackgroundColor(obj)
        %     value = obj.OuterPanel.BackgroundColor;
        % end
        % function set.TitleBackgroundColor(obj, value)
        %     obj.OuterPanel.BackgroundColor = value;
        % end

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


    %% Lower Button Properties
    % The dialog subclass can change these values
    properties (Dependent)

        LowerButtonText

        LowerButtonTag

        LowerButtonTooltip

        LowerButtonEnable

        LowerButtonWidth

        LowerButtonHeight

    end %methods

    % Accessors
    methods

        function value = get.LowerButtonText(obj)
            value = obj.LowerButtons.Text;
        end
        function set.LowerButtonText(obj,value)
            obj.LowerButtons.Text = value;
        end

        function value = get.LowerButtonTag(obj)
            value = obj.LowerButtons.ButtonTag;
        end
        function set.LowerButtonTag(obj,value)
            obj.LowerButtons.ButtonTag = value;
        end

        function value = get.LowerButtonTooltip(obj)
            value = obj.LowerButtons.Tooltip;
        end
        function set.LowerButtonTooltip(obj,value)
            obj.LowerButtons.Tooltip = value;
        end

        function value = get.LowerButtonEnable(obj)
            value = obj.LowerButtons.ButtonEnable;
        end
        function set.LowerButtonEnable(obj,value)
            obj.LowerButtons.ButtonEnable = value;
        end

        function value = get.LowerButtonWidth(obj)
            value = obj.LowerButtons.ButtonWidth;
        end
        function set.LowerButtonWidth(obj,value)
            obj.LowerButtons.ButtonWidth = value;
        end

        function value = get.LowerButtonHeight(obj)
            value = obj.LowerButtons.ButtonHeight;
        end
        function set.LowerButtonHeight(obj,value)
            obj.LowerButtons.ButtonHeight = value;
        end

    end %methods


    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = private)

        % Outer grid to enable the panel to fill the component
        OuterGrid matlab.ui.container.GridLayout

        % Outer panel for the dialog
        OuterPanel matlab.ui.container.Panel

        % Inner grid to manage the content grid and status/button row
        InnerGrid matlab.ui.container.GridLayout

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

        % Modal image (optional)
        ModalImage matlab.ui.control.Image

        % Lower buttons (optional)
        LowerButtons wt.ButtonGrid

    end %properties


    %% Public methods
    methods (Access = public)

        function positionOver(obj, refComp)
            % Positions the dialog centered over a given reference component

            arguments
                obj (1,1) wt.abstract.BaseDialog2
                refComp (1,1) matlab.graphics.Graphics
            end

            % Reference component size and position
            refPos = getpixelposition(refComp, true);
            refSize = refPos(3:4);
            refCornerA = refPos(1:2);
            %refCornerB = refPos(1:2) + refPos(:,3:4) - 1;

            % Dialog size
            dlgPos = getpixelposition(obj);
            dlgSize = dlgPos(3:4);

            % Does it fit entirely within the reference component?
            if all(refSize >= dlgSize)
                % Yes - center it over the component

                % Calculate lower-left corner
                dlgPos = floor((refSize - dlgSize) / 2) + refCornerA;

            else
                % NO - position within the figure

                % Get the corners of the figure (bottom left and top right)
                figPos = getpixelposition(obj.Parent);
                figSize = figPos(3:4);

                % Start with dialog position in lower-left of widget
                dlgPos = refCornerA;
                dlgCornerB = dlgPos + dlgSize;

                % Move left and down as needed to fit in figure
                adj = figSize - dlgCornerB;
                adj(adj>0) = 0;
                dlgPos = max(dlgPos + adj, [1 1]);
                dlgCornerB = dlgPos + dlgSize;

                % If it doesn't fit in the figure, shrink it
                adj = figSize - dlgCornerB;
                adj(adj>0) = 0;
                dlgSize = dlgSize + adj;

            end %if

            % Set final position
            obj.Position = [dlgPos dlgSize];
            
        end %function


        function labels = addRowLabels(obj, names, parent, column, startRow)
            % Add a group of standard row labels to the grid (or specified
            % grid)

            arguments
                obj %#ok<INUSA> 
                names (:,1) string
                parent = obj.Grid
                column = 1
                startRow = 1
            end

            numRows = numel(names);
            labels = gobjects(1,numRows);
            hasText = false(1,numRows);
            for idx = 1:numel(names)
                thisName = names(idx);
                hasText(idx) = strlength(thisName) > 0;
                if hasText(idx)
                    h = uilabel(parent);
                    h.HorizontalAlignment = "right";
                    h.Text = thisName;
                    h.Layout.Column = column;
                    h.Layout.Row = idx + startRow - 1;
                    labels(idx) = h;
                end
            end

            % Remove the empty spaces
            labels(~hasText) = [];
            
        end %function

    end %methods


    %% Protected methods
    methods (Access = protected)
        
        function setup(obj)
            % Configure the dialog

            % Defaults
            obj.Position(3:4) = [350,200];
            
            % Outer grid to enable the dialog panel to fill the component
            obj.OuterGrid = uigridlayout(obj,[1 1]);
            obj.OuterGrid.Padding = [0 0 0 0];

            % Outer dialog panel
            obj.OuterPanel = uipanel(obj.OuterGrid);
            obj.OuterPanel.Title = "Dialog Title";
            obj.OuterPanel.FontSize = 14;
            obj.OuterPanel.FontWeight = "bold";
            obj.OuterPanel.BorderWidth = 1;
            obj.OuterPanel.AutoResizeChildren = false;
            obj.OuterPanel.ResizeFcn = @(~,~)onOuterPanelResize(obj);
            obj.OuterPanel.ButtonDownFcn = @(~,evt)onTitleButtonDown(obj,evt);

            % Close Button
            obj.CloseButton = uibutton(obj.OuterPanel);
            obj.CloseButton.Text = "";
            obj.CloseButton.Tag = "close";
            obj.CloseButton.IconAlignment = "center";
            obj.CloseButton.ButtonPushedFcn = @(src,evt)obj.onClosePushed();
            
            % Inner Grid to manage content and button area
            obj.InnerGrid = uigridlayout(obj.OuterPanel,[2 2]);
            obj.InnerGrid.Padding = 10;
            obj.InnerGrid.RowHeight = {'1x','fit'};
            obj.InnerGrid.ColumnWidth = {'1x','fit'};
            obj.InnerGrid.RowSpacing = 5;
            
            % Grid to place dialog content
            obj.Grid = uigridlayout(obj.InnerGrid,[1 1]);
            obj.Grid.Layout.Row = 1;
            obj.Grid.Layout.Column = [1 2];
            obj.Grid.Padding = 0;
            obj.Grid.RowSpacing = 5;
            obj.Grid.ColumnSpacing = 5;
            obj.Grid.Scrollable = true;

            % Apply theme colors
            if ~isMATLABReleaseOlderThan("R2025a")
                obj.OuterPanel.ForegroundColor = obj.getThemeColor("--mw-color-primary");
                obj.OuterPanel.BorderColor = obj.getThemeColor("--mw-borderColor-secondary");
                obj.OuterPanel.BackgroundColor = obj.getThemeColor("--mw-backgroundColor-secondary");
            else
                obj.OuterPanel.ForegroundColor = [0.38 0.38 0.38];
                obj.OuterPanel.BorderColor = [.5 .5 .5];
                obj.OuterPanel.BackgroundColor = [.9 .9 .9];
            end

            % Apply close button color
            obj.applyCloseButtonColor()

            % Listen to figure size changes
            obj.Figure = ancestor(obj,'figure');
            obj.FigureResizeListener = listener(obj.Figure,"SizeChanged",...
                @(~,evt)onFigureResized(obj,evt));

            % Add modal image
            obj.ModalImage = uiimage(obj.Figure);
            obj.ModalImage.ImageSource = "overlay_gray.png";
            obj.ModalImage.ScaleMethod = "stretch";
            obj.ModalImage.Visible = "off";
            posF = getpixelposition(obj.Figure);
            szF = posF(3:4);
            obj.ModalImage.Position = [1 1 szF];

            % Add lower buttons
            obj.LowerButtons = wt.ButtonGrid(obj.InnerGrid,"Text",[],"Icon",[]);
            obj.LowerButtons.Layout.Row = 2;
            obj.LowerButtons.Layout.Column = 2;
            obj.LowerButtons.DefaultSize = 'fit';

            % Bring the dialog back to the top
            uistack(obj,"top");

            % Ensure it fits in the figure
            obj.resizeToFitFigure();

            % Reposition the close button
            obj.repositionCloseButton();

        end %function


        function update(obj)

            % Ensure it fits in the figure
            obj.resizeToFitFigure();

            % Reposition the close button
            obj.repositionCloseButton();
            
        end %function
        

        function updateBackgroundColorableComponents(obj)
            % Update components that are affected by BackgroundColor
            % (overrides the superclass method)
            
            % Update grid color
            set([obj.InnerGrid, obj.Grid], "BackgroundColor", obj.BackgroundColor);

            % Call superclass method
            obj.updateBackgroundColorableComponents@wt.mixin.BackgroundColorable();
            
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
            set(obj.CloseButton,"Position",[xB yB wB hB]);

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

            % Update modal image position
            set(obj.ModalImage,"Position",[1 1 szF]);

            % Update dialog position
            posNew = [posLowerLeft szD];
            set(obj,"Position",posNew);
            
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