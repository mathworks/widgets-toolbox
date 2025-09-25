classdef BaseInternalDialog  < wt.abstract.BaseWidget & ...
        wt.mixin.ButtonColorable & ...
        wt.mixin.TitleFontStyled & ...
        wt.mixin.FontStyled & ...
        wt.mixin.FieldColorable
    % Base class for a dialog that opens as a panel within the figure
    % window.  The dialog's lifecycle is tied to the app that launched it. 
    %
    % This enables compatibility with web apps.
    %
    % The dialog may flicker when resizing the figure if
    % AutoResizeChildren is on. Disabling this is recommended.

    % ** This is a prototype component that may change in the future. 

    % Copyright 2022-2025 The MathWorks Inc.


    %% Events
    events (HasCallbackProperty)

        % Triggered on dialog button pushed
        DialogButtonPushed

    end %properties


    %% Public Properties
    properties (AbortSet, Access = public)

        % Dialog Size
        Size (1,2) double {mustBePositive} = [350 200]

        % Modal (block other figure interaction)
        Modal (1,1) logical = false

        % Dialog Title
        Title (1,1) string = ""

    end %properties


    %% Dialog Button Properties
    % The dialog subclass can change these values
    properties (Dependent)

        DialogButtonText

        DialogButtonTag

        DialogButtonTooltip

        DialogButtonEnable

        DialogButtonWidth

        DialogButtonHeight

    end %methods

    % Accessors
    methods

        function value = get.DialogButtonText(obj)
            value = obj.DialogButtons.Text;
        end
        function set.DialogButtonText(obj,value)
            obj.DialogButtons.Text = value;
        end

        function value = get.DialogButtonTag(obj)
            value = obj.DialogButtons.ButtonTag;
        end
        function set.DialogButtonTag(obj,value)
            obj.DialogButtons.ButtonTag = value;
        end

        function value = get.DialogButtonTooltip(obj)
            value = obj.DialogButtons.Tooltip;
        end
        function set.DialogButtonTooltip(obj,value)
            obj.DialogButtons.Tooltip = value;
        end

        function value = get.DialogButtonEnable(obj)
            value = obj.DialogButtons.ButtonEnable;
        end
        function set.DialogButtonEnable(obj,value)
            obj.DialogButtons.ButtonEnable = value;
        end

        function value = get.DialogButtonWidth(obj)
            value = obj.DialogButtons.ButtonWidth;
        end
        function set.DialogButtonWidth(obj,value)
            obj.DialogButtons.ButtonWidth = value;
        end

        function value = get.DialogButtonHeight(obj)
            value = obj.DialogButtons.ButtonHeight;
        end
        function set.DialogButtonHeight(obj,value)
            obj.DialogButtons.ButtonHeight = value;
        end

    end %methods


    %% Dialog Actions Properties
    properties (AbortSet, Access = public)

        % Dialog button action names that trigger deletion (button tags/names)
        DeleteActions (1,:) string = ["delete","close","ok","cancel","exit"]

    end %properties


    properties (SetAccess = protected)

        % Results / Output Data from the dialog
        Output = []

        % True if dialog is waiting for output
        IsWaitingForOutput (1,1) logical = false
        % Pressing a button (ok, cancel, or close) will toggle this false
        % and cause the waitForOutput() method to complete.

    end %properties


    %% Internal Properties
    properties (Hidden)

        % Minimum allowable size before cropping
        MinimumSize (1,2) double {mustBePositive} = [30 20];

        % Buffer border space required on each side when sizing in figure 
        % Buffer (1,1) double {mustBeNonnegative} = 0

    end %properties


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

        % Dialog buttons (optional)
        DialogButtons wt.ButtonGrid

        % Last action when closing dialog
        LastAction string = []

    end %properties


    %% Constructor
    methods

        function obj = BaseInternalDialog(fig, varargin)

            arguments
                % Figure parent - Create a figure if not provided
                fig (1,1) matlab.ui.Figure = uifigure("AutoResizeChildren","off");
            end

            arguments (Repeating)
                % Property-value pairs
                varargin
            end

            % Get the figure size
            posF = getpixelposition(fig);
            szFig = posF(3:4);

            % Add modal image
            modalImage = uiimage(fig);
            modalImage.ImageSource = "overlay_gray.png";
            modalImage.ScaleMethod = "stretch";
            modalImage.Visible = "off";
            modalImage.Position = [1 1 szFig];
            modalImage.Tag = "ModalImage";

            % Call superclass constructor
            obj = obj@wt.abstract.BaseWidget(fig, varargin{:});

            % Store the modal background image
            obj.ModalImage = modalImage;

            % Update the modal image positioning
            obj.updateModalImage();

        end %function

    end %methods


    %% Destructor
    methods
        function delete(obj)
    
            % Delete the modal image
            delete(obj.ModalImage)
            
        end %function
    end %methods


    %% Public methods
    methods (Sealed, Access = public)

        function positionOver(obj, refComp)
            % Positions the dialog centered over a given reference component

            arguments
                obj (1,1) wt.abstract.BaseInternalDialog
                refComp (1,1) matlab.graphics.Graphics
            end

            % Reference component size and position
            refPos = getpixelposition(refComp, true);
            % refSize = refPos(3:4);
            
            % Lower left corner depends if it's a figure
            if isa(refComp, "matlab.ui.Figure")
                % refCornerA = [1 1];
                refPos(1:2) = [1 1];
            else
                % refCornerA = refPos(1:2);
            end

            % Dialog position
            posNew = obj.Position;

            % Calculate the dialog position
            % Request to center over refPos
            posNew = calculatePositionWithinBounds(obj, posNew, refPos);

            % Update dialog position
            if ~isequal(obj.Position, posNew)
                fprintf(" Change position: posOld = %f  posNew = %f\n", obj.Position, posNew);
                obj.Position = posNew;
            end

        end %function


        function labels = addRowLabels(obj, names, parent, column, startRow)
            % Add a group of standard row labels to the grid (or specified
            % grid)

            arguments
                obj %#ok<INUSA>
                names (:,1) string
                parent matlab.graphics.Graphics = obj.Grid
                column (1,1) double {mustBeInteger} = 1
                startRow (1,1) double {mustBeInteger} = 1
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


    %% Public Methods
    methods (Access = public)

        function [output, lastAction] = waitForOutput(obj)
            % Puts MATLAB in a wait state until the dialog buttons trigger
            % action

            % Wait for action
            obj.IsWaitingForOutput = true;
            waitfor(obj,'IsWaitingForOutput',false)

            % Complete the wait action
            % Is the dialog still present?
            if isvalid(obj)

                % Assign the output
                output = obj.Output;
                lastAction = obj.LastAction;

                % Check for deletion criteria and delete dialog
                obj.checkDeletionCriteria()

            else
                
                % Dialog or figure was deleted
                output = [];
                lastAction = "close";

            end

        end %function

    end %methods


    %% Protected methods
    methods (Sealed, Access = public)

        function attachLifecycleListeners(obj, owners)
            % Delete the dialog automatically upon destruction of the
            % specified "owner" graphics objects

            arguments
                obj (1,1) wt.abstract.BaseInternalDialog
                owners (1,:) matlab.graphics.Graphics
            end

            % Create listeners
            % The dialog will be deleted if the listenObj is deleted
            newListeners = listener(owners, "ObjectBeingDestroyed",...
                @(src,evt)forceCloseDialog(obj));

            % Add to any existing listeners
            obj.LifecycleListeners = horzcat(obj.LifecycleListeners, newListeners);

        end %function

    end %methods


    %% Protected methods
    methods (Access = protected)

        function assignOutput(~)
            % Triggered when the dialog should assign the output, generally
            % in the case of a blocking dialog.

            % For blocking dialogs, the subclass should implement the
            % assignOutput method.

            % Example subclass implementation:
            %
            %   function assignOutput(obj)
            %
            %       % Assign output
            %       obj.Output = <assign appropriate data here>;
            %
            %   end %function


        end %function


        function setup(obj)
            % Configure the dialog

            % Store the figure
            obj.Figure = ancestor(obj,'figure');

            % Outer grid to enable the dialog panel to fill the component
            obj.OuterGrid = uigridlayout(obj,[1 1]);
            obj.OuterGrid.Padding = [0 0 0 0];

            % Outer dialog panel
            obj.OuterPanel = uipanel(obj.OuterGrid);
            obj.OuterPanel.Title = "Dialog Title";
            obj.OuterPanel.FontSize = 16;
            obj.OuterPanel.FontWeight = "bold";
            %obj.OuterPanel.BorderWidth = 1;
            obj.OuterPanel.AutoResizeChildren = false;
            obj.OuterPanel.ButtonDownFcn = @(~,evt)onTitleButtonDown(obj,evt);

            % Close Button
            obj.CloseButton = uibutton(obj);
            obj.CloseButton.Text = "";
            obj.CloseButton.Tag = "close";
            obj.CloseButton.IconAlignment = "center";
            obj.CloseButton.ButtonPushedFcn = ...
                @(src,evt)onDialogButtonPushed(obj,evt);

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
                obj.OuterPanel.ForegroundColor = ...
                    obj.getThemeColor("--mw-color-primary");
                obj.OuterPanel.BorderColor = ...
                    obj.getThemeColor("--mw-borderColor-secondary");
                obj.OuterPanel.BackgroundColor = ...
                    obj.getThemeColor("--mw-backgroundColor-secondary");
            elseif isMATLABReleaseOlderThan("R2023a")
                obj.OuterPanel.ForegroundColor = [0.38 0.38 0.38];
                obj.OuterPanel.BackgroundColor = [.9 .9 .9];
            else
                obj.OuterPanel.ForegroundColor = [0.38 0.38 0.38];
                obj.OuterPanel.BorderColor = [.5 .5 .5];
                obj.OuterPanel.BackgroundColor = [.9 .9 .9];
            end

            % Apply close button color
            obj.applyCloseButtonColor()

            % Listen to figure size changes
            obj.FigureResizeListener = listener(obj.Figure,"SizeChanged",...
                @(~,evt)onFigureResized(obj,evt));

            % Add lower buttons
            obj.DialogButtons = wt.ButtonGrid(obj.InnerGrid,"Text",[],"Icon",[]);
            obj.DialogButtons.Layout.Row = 2;
            obj.DialogButtons.Layout.Column = 2;
            obj.DialogButtons.DefaultSize = 'fit';
            obj.DialogButtons.ButtonPushedFcn = ...
                @(src,evt)onDialogButtonPushed(obj,evt);

            % Update component lists
            obj.ButtonColorableComponents = [obj.DialogButtons];
            obj.TitleFontStyledComponents = [obj.OuterPanel];
            obj.FontStyledComponents = [obj.DialogButtons];

            % Listen to resizing of OuterPanel
            % This enables the close button to stay in the correct spot
            obj.OuterPanel.ResizeFcn = @(~,~)onOuterPanelResize(obj);

            % Ensure it fits in the figure
            obj.resizeToFitFigure();

            % Reposition the close button
            repositionCloseButton(obj)

        end %function


        function update(obj)

            % Update title
            if strlength(obj.Title)
                obj.OuterPanel.Title = obj.Title;
            else
                obj.OuterPanel.Title = " ";
            end

            % Ensure it fits in the figure
            % This is only needed if AutoResizeChildren is on
            if obj.Figure.AutoResizeChildren
                obj.resizeToFitFigure();
            end

        end %function


        function updateBackgroundColorableComponents(obj)
            % Update components that are affected by BackgroundColor
            % (overrides the superclass method)

            % Update dialog and button background grids
            set([obj.InnerGrid, obj.Grid, obj.DialogButtons],...
                "BackgroundColor", obj.BackgroundColor);

            % Call superclass method
            obj.updateBackgroundColorableComponents@wt.mixin.BackgroundColorable();

        end %function

    end %methods


    methods (Sealed, Access = protected)

        function forceCloseDialog(obj)
            % Should the dialog be deleted?

            obj.Output = [];
            obj.LastAction = 'delete';

            if ~obj.IsWaitingForOutput

                % Delete the dialog
                delete(obj)

            else

                obj.IsWaitingForOutput = false;

            end

        end %function


        function checkDeletionCriteria(obj)
            % Should the dialog be deleted?

            % Check if ready to delete
            isDeleteAction = matches(obj.LastAction, obj.DeleteActions, ...
                "IgnoreCase", true);

            if ~obj.IsWaitingForOutput && isDeleteAction

                % Delete the dialog
                delete(obj)

            end

        end %function

    end %methods


    %% Private methods
    methods (Access = private)

        function resizeToFitFigure(obj)
            % Triggered on figure resize

            % Update modal image
            obj.updateModalImage();

            % Get the current positioning
            posNew = obj.Position;
            % posLowerLeft = posOld(1:2);

            % Calculate the dialog size
            szDlg = calculateDialogSize(obj);
            posNew(3:4) = szDlg;

            % Calculate the dialog position
            if obj.SetupFinished
                posNew = calculatePositionWithinBounds(obj, posNew);
            else
                % Try to center over figure by default
                posFig = getpixelposition(obj.Figure);
                posFig(1:2) = 1;
                posNew = calculatePositionWithinBounds(obj, posNew, posFig);
            end

            % Update dialog position
            if ~isequal(obj.Position, posNew)
                obj.Position = posNew;
            end

        end %function


        function szDlg = calculateDialogSize(obj)
            % Calculate the dialog size to use, given the set Size and
            % figure constraints

            % Get figure size
            posFig = getpixelposition(obj.Figure);

            % Calculate allowed dialog size
            szDlg = max( min(obj.Size, posFig(3:4)), obj.MinimumSize);

        end %function


        function posOut = calculatePositionWithinBounds(obj, posIn, posCenter)
            % Confirm and verify the position is within the figure bounds

            arguments
                obj (1,1) wt.abstract.BaseInternalDialog
                posIn (1,4) double {mustBeFinite} %requested [x,y,w,h] location
                posCenter (1,4) double = nan(1,4) %optional - center over this [x,y,w,h]
            end

            % Default output
            posOut = posIn;

            % Get figure size
            figPos = getpixelposition(obj.Figure);
            figSize = figPos(3:4);

            % Center over a component? (optional posCenter)
            if ~any(ismissing(posCenter))
                centerPoint = floor(posCenter(1:2) + posCenter(3:4)/2);
                posOut(1:2) = floor(centerPoint - posOut(3:4)/2);
            end

            % Ensure upper right corner is within the figure
            dlgUpperRight = posOut(1:2) + posOut(3:4) - [1 1];
            if any(dlgUpperRight > figSize)
                dlgAdjust = dlgUpperRight - figSize;
                dlgAdjust(dlgAdjust < 0) = 0;
                posOut(1:2) = posOut(1:2) - dlgAdjust;
            end
            
            % Ensure lower left corner is within the figure
            posOut(1:2) = max(posOut(1:2), [1 1]);

        end %function


        function repositionCloseButton(obj)
            % Called at end of resize

            % Get current position
            oldPos = obj.CloseButton.Position;

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
            newPos = floor([xB yB wB hB]);

            % Move the close button
            if ~isequal(oldPos, newPos)
                obj.CloseButton.Position = newPos;
            end

        end %function


        function updateModalImage(obj)
            % Update modal image size and visibility

            % Only run if ModalImage exists
            if isscalar(obj.ModalImage) && isvalid(obj.ModalImage)

                % Set modal image position to match the figure
                posF = getpixelposition(obj.Figure);
                szFig = posF(3:4);
                obj.ModalImage.Position = [1 1 szFig];

                % Toggle visibility
                obj.ModalImage.Visible = obj.Modal;

            end %if

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


        function onDialogButtonPushed(obj,evt)
            % Triggered when a dialog button is pushed (close, ok, etc.)

            % For blocking dialogs, the subclass should implement the
            % assignOutput method. The assignOutput will be called based on
            % which dialog button was pushed.

            % The pushed button's Tag (or Name if Tag is empty) will be
            % set as the LastAction

            % What button was pushed?
            if isa(evt, "wt.eventdata.ButtonPushedData")
                % The lower dialog buttons (wt.ButtonGrid)
                srcButton = evt.Button;
            else
                % Assume a regular button
                srcButton = evt.Source;
            end
            action = srcButton.Tag;
            if isempty(action)
                action = srcButton.Text;
            end

            % Set last action
            obj.LastAction = action;

            % Request to assign output
            obj.assignOutput();

            % Prep event data
            evtOut = wt.eventdata.DialogButtonPushedData;
            evtOut.Action = obj.LastAction;
            evtOut.Output = obj.Output;

            % Notify listeners / callback about output
            obj.notify("DialogButtonPushed", evtOut)

            % Should the dialog be deleted?
            if obj.IsWaitingForOutput

                % Don't delete here. Toggle status, allowing
                % waitForOutput() to complete and handle deletion.
                obj.IsWaitingForOutput = false;

            else

                % Check for deletion criteria
                obj.checkDeletionCriteria()

            end

        end %function


        function onFigureResized(obj,~)
            % Triggered on figure resize

            % Ensure it fits in the figure
            obj.resizeToFitFigure();

        end %function


        function onOuterPanelResize(obj)
            % Triggered when the dialog window is resized

            % Reposition the close button
            repositionCloseButton(obj)

        end %function


        function onTitleButtonDown(obj,~)
            % Triggered on title bar button down

            % Instantiate a figure drag helper to begin dragging dialog
            obj.DragHelper = wt.utility.FigureDragHelper(obj);
            obj.DragHelper.DragFcn = @(dhObj,evt)onMouseDrag(obj,evt);

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