classdef BaseDialog2  < wt.abstract.BaseWidget & ...
        wt.mixin.TitleFontStyled
    % Base class for a dialog

    % Copyright 2022-2025 The MathWorks Inc.
    
    % To do:
    % - finish importing old BaseDialog
    % - observe figure resize, ensure dialog is always on screen
    % - add modal backing image
    % - make examples

    %% Public Properties
    properties (AbortSet, Dependent, Access = public)

        % Dialog Title
        Title

        % Background Color
        TitleBackgroundColor

        % Background color mode
        TitleBackgroundColorMode (1,1) wt.enum.AutoManualState = 'auto'

        % Dialog Size
        Size (1,2) double {mustBePositive}

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

        function value = get.TitleBackgroundColorMode(obj)
            value = wt.enum.AutoManualState(obj.OuterPanel.BackgroundColorMode);
        end
        function set.TitleBackgroundColorMode(obj, value)
            obj.OuterPanel.BackgroundColorMode = char(value);
        end

        function value = get.Size(obj)
            value = obj.Position(3:4);
        end
        function set.Size(obj, value)
            obj.Position(3:4) = value;
        end

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
            obj.OuterPanel.BorderWidth = 2;
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
            obj.CloseButton.Icon = "closeButton_32.png";
            obj.CloseButton.Text = "";
            obj.CloseButton.BackgroundColor = [0.8 0.2 0.2];
            obj.CloseButton.ButtonPushedFcn = @(src,evt)obj.onClosePushed();
            
            % Trigger the outer panel resize
            % This positions the close button properly
            obj.onOuterPanelResize();

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


        function onOuterPanelResize(obj)
            % Triggered when the dialog window is resized

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


        function onTitleButtonDown(obj,~)
            % Triggered on title bar button down

            % Instantiate a figure drag helper to begin dragging dialog
            obj.DragHelper = wt.utility.FigureDragHelper(obj);
            obj.DragHelper.DragFcn = @(dhObj,evt)onMouseDrag(obj,evt);

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


end %classdef