classdef BaseExternalDialog  < wt.abstract.BaseWidget
    % Base class for a dialog that opens externally, in a separate figure
    % window. The dialog's lifecycle is tied to the app that launched it. 
    %
    % Note that this is incompatible with web apps, which support only a
    % single figure. Use BaseInternalDialog for web app support.

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
        Size double {mustBePositive} = [350 200]

        % Modal (block other figure interaction)
        Modal (1,1) logical = false

    end %properties


    properties (AbortSet, Dependent, Access = public)

        % Modal tooltip
        ModalTooltip (1,1) string

        % Position on screen [left bottom width height]
        DialogPosition 

        % Dialog Title
        Title

    end %properties


    % Accessors
    methods

        function set.Modal(obj, value)
            obj.Modal = value;
            obj.updateModalImage();
        end

        function value = get.Title(obj)
            value = string(obj.DialogFigure.Name);
        end
        function set.Title(obj, value)
            obj.DialogFigure.Name = value;
        end

        function value = get.DialogPosition(obj)
            value = obj.DialogFigure.Position;
        end
        function set.DialogPosition(obj, value)
            obj.DialogFigure.Position = value;
        end

        function value = get.Size(obj)
            if isscalar(obj.DialogFigure)
                value = obj.DialogFigure.Position(3:4);
            else
                value = obj.Size;
            end
        end
        function set.Size(obj, value)
            obj.Size = value;
            if isscalar(obj.DialogFigure) %#ok<MCSUP> 
                obj.DialogFigure.Position(3:4) = value; %#ok<MCSUP> 
            end
        end

        function value = get.ModalTooltip(obj)
            value = string(obj.ModalImage.Tooltip);
        end
        function set.ModalTooltip(obj, value)
            obj.ModalImage.Tooltip = value;
        end

    end %methods


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
    properties (Transient, NonCopyable, Hidden, SetAccess = private)

        % Outer grid to enable the component to fill the figure
        OuterGrid matlab.ui.container.GridLayout

        % Inner grid to manage the content grid and status/button row
        InnerGrid matlab.ui.container.GridLayout

        % Listeners to reference/parent objects to trigger dialog delete
        LifecycleListeners (1,:) event.listener

        % Modal image (optional)
        ModalImage matlab.ui.control.Image

        % Dialog buttons (optional)
        DialogButtons wt.ButtonGrid

        % Last action when closing dialog
        LastAction string = []

    end %properties


    properties (Transient, NonCopyable, Hidden, SetAccess = protected)

        % Figure tied to the dialog lifecycle
        CallingFigure matlab.ui.Figure

        % This dialog's figure
        DialogFigure matlab.ui.Figure

    end %properties



    %% Destructor
    methods
        function delete(obj)
    
            % Delete the modal image
            delete(obj.ModalImage)

            % Delete the figure
            delete(obj.DialogFigure)
            
        end %function
    end %methods


    %% Public methods
    methods (Sealed, Access = public)

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

            % Produce output
            if isvalid(obj)
                output = obj.Output;
                lastAction = obj.LastAction;
            else
                % Dialog or figure was deleted
                output = [];
                lastAction = "close";
            end


            % Check for deletion criteria
            obj.checkDeletionCriteria()

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

            % Store the parent figure
            obj.CallingFigure = ancestor(obj,'figure');

            % Get the size input
            sizeInput = obj.Size;

             % Create a new figure for this dialog
            obj.DialogFigure = uifigure();
            obj.DialogFigure.AutoResizeChildren = false;
            obj.DialogFigure.Units = "pixels";
            obj.DialogFigure.Position(3:4) = sizeInput;
            obj.positionOverCallingFigure()

            % Apply the same theme (R2025a and later)
            if ~isMATLABReleaseOlderThan("R2025a")
                obj.DialogFigure.Theme = obj.CallingFigure.Theme;
            end

            % Give the figure a grid layout
            obj.OuterGrid = uigridlayout(obj.DialogFigure, [1 1]);
            obj.OuterGrid.Padding = 0;

            % Move the content to the new figure
            obj.Parent = obj.OuterGrid;

            % Attach figure callbacks
            obj.DialogFigure.DeleteFcn = @(~,~)delete(obj);
            obj.DialogFigure.CloseRequestFcn = @(~,evt)onDialogButtonPushed(obj,evt);

            % Inner Grid to manage content and button area
            obj.InnerGrid = uigridlayout(obj,[2 2]);
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

            % Add modal image over the app's figure
            obj.ModalImage = uiimage(obj.CallingFigure);
            obj.ModalImage.ImageSource = "overlay_gray.png";
            obj.ModalImage.ScaleMethod = "stretch";
            obj.ModalImage.Tooltip = "Close the dialog box to continue using the app.";
            obj.ModalImage.Visible = "off";
            obj.ModalImage.Position = [1 1 1 1];

            % Add lower buttons
            obj.DialogButtons = wt.ButtonGrid(obj.InnerGrid,"Text",[],"Icon",[]);
            obj.DialogButtons.Layout.Row = 2;
            obj.DialogButtons.Layout.Column = 2;
            obj.DialogButtons.DefaultSize = 'fit';
            obj.DialogButtons.ButtonPushedFcn = ...
                @(src,evt)onDialogButtonPushed(obj,evt);

        end %function


        function update(~)


        end %function


        function updateBackgroundColorableComponents(obj)
            % Update components that are affected by BackgroundColor
            % (overrides the superclass method)

            % Update grid color
            set([obj.InnerGrid, obj.Grid], "BackgroundColor", obj.BackgroundColor);

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


        function positionOverCallingFigure(obj)
            % Positions the dialog centered over the reference figure

            % Reference component size and position
            refPos = getpixelposition(obj.CallingFigure, true);
            refSize = refPos(3:4);
            refCornerA = refPos(1:2);

            % Dialog size
            dlgSize = obj.DialogFigure.Position(3:4);

            % center it over the figure

            % Calculate lower-left corner
            dlgPos = floor((refSize - dlgSize) / 2) + refCornerA;

            % Set final position
            obj.DialogFigure.Position = [dlgPos dlgSize];


        end %function

    end %methods


    %% Private methods
    methods (Access = private)

        function updateModalImage(obj)
            % Triggered when the Modal property is changed

            % If toggled on, do the following
            if obj.Modal

                % Set position to match the figure
                posF = getpixelposition(obj.CallingFigure);
                szF = posF(3:4);
                obj.ModalImage.Position = [1 1 szF];

            end %if

            % Toggle visibility
            obj.ModalImage.Visible = obj.Modal;

        end %function


        function onDialogButtonPushed(obj,evt)
            % Triggered when a dialog button is pushed (close, ok, etc.)

            % For blocking dialogs, the subclass should implement the
            % assignOutput method. The assignOutput will be called based on
            % which dialog button was pushed.

            % The pushed button's Tag (or Name if Tag is empty) will be
            % set as the LastAction

            % Request to assign output
            obj.assignOutput();

            % What button was pushed?
            if isa(evt, "matlab.ui.eventdata.WindowCloseRequestData")
                srcButton = "close";
                action = "close";
            elseif isa(evt, "wt.eventdata.ButtonPushedData")
                % The lower dialog buttons (wt.ButtonGrid)
                srcButton = evt.Button;
                action = srcButton.Tag;
            else
                % Assume a regular button
                srcButton = evt.Source;
                action = srcButton.Tag;
            end

            % What action is being taken?
            if isempty(action)
                action = srcButton.Text;
            end

            % Set last action
            obj.LastAction = action;

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

    end %methods


end %classdef