classdef ListSelectionDialog < wt.test.BaseDialogTest
    % Implements a unit test for a widget or component
    
    %   Copyright 2025 The MathWorks Inc.
    
    %% Properties
    properties
        ItemNames = "TestItem" + string(1:5);
        ItemData = "TestData" + string(1:5);
    end


    properties (Access = private)
        ResizePositions = zeros(0,4)
    end
     
    
    %% Unit Test
    methods (Test)

        function testDefaults(testCase)

            % Create the dialog
            dlg = wt.dialog.ListSelection(testCase.Figure);

            % Get the listbox
            listControl = dlg.ListBox;

            % Enable drawing to complete
            drawnow

            % List should still be empty
            testCase.verifyEmpty(dlg.Items);
            testCase.verifyEmpty(dlg.ItemsData);
            testCase.verifyEmpty(listControl.Items);
            testCase.verifyEmpty(listControl.ItemsData);

            % Default property values
            testCase.verifyEqual(dlg.Prompt, "");
            testCase.verifyFalse(dlg.Multiselect);
            testCase.verifyTrue(dlg.Modal);
            testCase.verifyEqual(dlg.DialogButtonText, ["OK","Cancel"]);
            testCase.verifyEqual(dlg.DialogButtonTag, ["ok","cancel"]);
            testCase.verifyEqual(dlg.DeleteActions, ["close","ok","cancel"]);
            testCase.verifyEmpty(dlg.Output);
            testCase.verifyFalse(dlg.IsWaitingForOutput);
            testCase.verifyFalse(dlg.Resizable);

            % Size was honored
            testCase.verifyEqual(dlg.Position(3:4), [300 300]);

        end %function


        function testResizableProperty(testCase)

            % Create the dialog
            dlg = wt.dialog.ListSelection(testCase.Figure);
            drawnow

            % Enable resize behavior
            dlg.Resizable = true;
            drawnow

            testCase.verifyTrue(dlg.Resizable);
            testCase.verifyEqual(dlg.Position(3:4), [300 300]);

            % Disable resize behavior
            dlg.Resizable = false;
            drawnow

            testCase.verifyFalse(dlg.Resizable);
            testCase.verifyEqual(dlg.Position(3:4), [300 300]);

        end %function


        function testResizableHoverPointer(testCase)

            import matlab.unittest.constraints.Eventually
            import matlab.unittest.constraints.IsEqualTo

            % Create the dialog
            dlg = wt.dialog.ListSelection(testCase.Figure);
            dlg.Resizable = true;
            drawnow

            % Hover over the right edge
            pos = dlg.Position;
            edgePoint = [pos(1)+pos(3)-2, pos(2)+round(pos(4)/2)];
            testCase.hover(testCase.Figure, edgePoint);

            % Verify the figure pointer indicates horizontal resizing
            testCase.verifyThat(@()string(testCase.Figure.Pointer), ...
                Eventually(IsEqualTo("right"), "WithTimeoutOf", 5));

            % Hover inside the dialog away from the edge
            centerPoint = pos(1:2) + round(pos(3:4)/2);
            testCase.hover(testCase.Figure, centerPoint);

            % Verify the figure pointer is restored
            testCase.verifyThat(@()string(testCase.Figure.Pointer), ...
                Eventually(IsEqualTo("arrow"), "WithTimeoutOf", 5));

        end %function


        function testResizableLeftEdgeDragUpdatesSizeDuringGesture(testCase)

            % Create the dialog
            dlg = wt.dialog.ListSelection(testCase.Figure);
            dlg.Resizable = true;
            dlg.Position = [250 180 300 260];
            dlg.Size = [300 260];
            drawnow

            % Track all size changes while the gesture is running
            testCase.ResizePositions = zeros(0,4);
            dlg.SizeChangedFcn = ...
                @(src,~)recordResizePosition(testCase, src.Position);

            % Drag the left edge leftward
            pos = dlg.Position;
            startPoint = [pos(1)+2, pos(2)+round(pos(4)/2)];
            stopPoint = startPoint + [-60 0];
            testCase.drag(testCase.Figure, startPoint, stopPoint);
            drawnow

            % Verify there was at least one live intermediate resize
            widths = testCase.ResizePositions(:,3);
            testCase.verifyGreaterThan(size(testCase.ResizePositions,1), 1)
            testCase.verifyTrue(any(widths > 300 & widths < 360))

            % Verify the right edge stayed anchored
            testCase.verifyEqual(dlg.Position, [190 180 360 260])
            testCase.verifyEqual(dlg.Size, [360 260])

        end %function


        function testResizableBottomEdgeDragAnchorsTopEdge(testCase)

            % Create the dialog
            dlg = wt.dialog.ListSelection(testCase.Figure);
            dlg.Resizable = true;
            dlg.Position = [250 180 300 260];
            dlg.Size = [300 260];
            drawnow

            % Drag the bottom edge downward
            pos = dlg.Position;
            startPoint = [pos(1)+round(pos(3)/2), pos(2)+2];
            stopPoint = startPoint + [0 -40];
            testCase.drag(testCase.Figure, startPoint, stopPoint);
            drawnow

            % Verify it resized vertically with the top edge anchored
            testCase.verifyEqual(dlg.Position, [250 140 300 300])
            testCase.verifyEqual(dlg.Size, [300 300])

        end %function


        function testResizableTopEdgeDragDoesNotMoveDialog(testCase)

            % Create the dialog
            dlg = wt.dialog.ListSelection(testCase.Figure);
            dlg.Resizable = true;
            dlg.Position = [250 180 300 260];
            dlg.Size = [300 260];
            drawnow

            % Drag the top edge upward
            pos = dlg.Position;
            startPoint = [pos(1)+round(pos(3)/2), pos(2)+pos(4)-2];
            stopPoint = startPoint + [0 60];
            testCase.drag(testCase.Figure, startPoint, stopPoint);
            drawnow

            % Verify it resized vertically instead of moving the dialog
            testCase.verifyEqual(dlg.Position, [250 180 300 320])
            testCase.verifyEqual(dlg.Size, [300 320])

        end %function


        function testExampleCode(testCase)

            % Create the dialog
            dlg = wt.dialog.ListSelection(testCase.Figure);

            % Get the listbox
            listControl = dlg.ListBox;

            % Values to populate
            expTitle = "Make your selection:";
            expSize = [250 250]; % width, height
            expItems = ["Apple","Banana","Cherry","Grape","Orange","Pineapple"];
            expValue = "Grape";

            % Populate the dialog
            dlg.Title = expTitle;
            dlg.Size = expSize;
            dlg.Items = expItems;
            dlg.Value = expValue;

            % Enable drawing to complete
            drawnow

            % Verify values
            testCase.verifyEqual(string(dlg.OuterPanel.Title), expTitle)
            testCase.verifyEqual(string(listControl.Items), expItems);
            testCase.verifyEqual(dlg.Items, expItems);
            testCase.verifyEqual(dlg.Value, expValue);
            testCase.verifyEqual(string(listControl.Value), expValue);

            % testCase.verifyEqual(dlg.Position(3:4), expSize);
            testCase.verifyPixelSize(dlg, expSize);

        end %function


        function testButtonEnables(testCase)

            % Create the dialog
            dlg = wt.dialog.ListSelection(testCase.Figure);
            dlg.Items = testCase.ItemNames;

            % Enable drawing to complete
            drawnow

            % Assume no initial selection
            testCase.assumeEmpty(dlg.Value)

            % Verify button states
            testCase.verifyNotEnabled(dlg.DialogButtons.Button(1))
            testCase.verifyEnabled(dlg.DialogButtons.Button(2))
        
            % Select a value
            dlg.Value = testCase.ItemNames(2);
            drawnow;

            % Verify button states after selection
            testCase.verifyEnabled(dlg.DialogButtons.Button(1))
            testCase.verifyEnabled(dlg.DialogButtons.Button(2))

        end %function


        function testMultiselectButtonEnables(testCase)

            % Create the dialog
            dlg = wt.dialog.ListSelection(testCase.Figure);
            dlg.Items = testCase.ItemNames;
            dlg.Multiselect = true;

            % Enable drawing to complete
            drawnow

            % Assume no initial selection
            testCase.assumeEmpty(dlg.Value)

            % Verify button states
            testCase.verifyNotEnabled(dlg.DialogButtons.Button(1))
            testCase.verifyEnabled(dlg.DialogButtons.Button(2))
            testCase.verifyEqual(logical(dlg.DialogButtonEnable), [false true]);
        
            % Select one value
            dlg.Value = testCase.ItemNames(2);
            drawnow;

            % Verify button states after selection
            testCase.verifyEnabled(dlg.DialogButtons.Button(1))
            testCase.verifyEnabled(dlg.DialogButtons.Button(2))
            testCase.verifyEqual(logical(dlg.DialogButtonEnable), [true true]);
        
            % Select two values
            dlg.Value = testCase.ItemNames(2:3);
            drawnow;

            % Verify button states after selection
            testCase.verifyEnabled(dlg.DialogButtons.Button(1))
            testCase.verifyEnabled(dlg.DialogButtons.Button(2))
            testCase.verifyEqual(logical(dlg.DialogButtonEnable), [true true]);

            % Select NO values
            dlg.Value = "";
            drawnow;

            % Verify button states after selection
            testCase.verifyNotEnabled(dlg.DialogButtons.Button(1))
            testCase.verifyEnabled(dlg.DialogButtons.Button(2))
            testCase.verifyEqual(logical(dlg.DialogButtonEnable), [false true]);

        end %function


        function testModalBackground(testCase)

            % Create the dialog
            dlg = wt.dialog.ListSelection(testCase.Figure);
            dlg.Items = testCase.ItemNames;
            drawnow

            % Verify that Modal is true
            testCase.assumeTrue(dlg.Modal);

            % Verify ModalImage is visible
            testCase.verifyTrue(dlg.ModalImage.Visible);

            % Toggle off modal
            dlg.Modal = false;
            drawnow; % Ensure the dialog updates to reflect the modal state

            % Verify ModalImage is NOT visible
            testCase.verifyFalse(dlg.ModalImage.Visible);
            
        end %function


        function testInteractiveSelection(testCase)

            % Create the dialog
            dlg = wt.dialog.ListSelection(testCase.Figure);
            dlg.Items = testCase.ItemNames;
            dlg.ItemsData = testCase.ItemData;
            drawnow

            % Get the listbox
            listControl = dlg.ListBox;

            % Select item with mouse
            expIdx = 2;
            expValue = testCase.ItemData(expIdx);
            testCase.choose(listControl, expIdx)

            % Verify selection
            testCase.verifyEqual(dlg.Value, expValue);
            testCase.verifyEqual(listControl.Value, expValue);

            % Select item with mouse
            expValue = testCase.ItemData(expIdx);
            testCase.choose(listControl, expIdx)

            % Verify selection
            testCase.verifyEqual(dlg.Value, expValue);
            testCase.verifyEqual(listControl.Value, expValue);

        end %function


        function testOkButton(testCase)

            % Create the dialog
            dlg = wt.dialog.ListSelection(testCase.Figure);
            dlg.Items = testCase.ItemNames;
            dlg.Value = testCase.ItemNames(1);
            drawnow

            % Press button
            testCase.assumeTrue(dlg.DialogButtons.Button(1).Enable)
            testCase.press(dlg.DialogButtons.Button(1))
            drawnow
           
            % Verify dlg was deleted
            testCase.verifyFalse(isvalid(dlg));

        end %function


        function testCancelButton(testCase)

            % Create the dialog
            dlg = wt.dialog.ListSelection(testCase.Figure);
            dlg.Items = testCase.ItemNames;
            dlg.Value = testCase.ItemNames(1);
            drawnow

            % Press button
            testCase.assumeTrue(dlg.DialogButtons.Button(2).Enable)
            testCase.press(dlg.DialogButtons.Button(2))
            drawnow
           
            % Verify dlg was deleted
            testCase.verifyFalse(isvalid(dlg));

        end %function


        function testCloseButton(testCase)

            % Create the dialog
            dlg = wt.dialog.ListSelection(testCase.Figure);
            dlg.Items = testCase.ItemNames;
            dlg.Value = testCase.ItemNames(1);
            drawnow

            % Press button
            testCase.assumeTrue(dlg.CloseButton.Enable)
            testCase.press(dlg.CloseButton)
            drawnow
           
            % Verify dlg was deleted
            testCase.verifyFalse(isvalid(dlg));

        end %function


        function testStyleProperties(testCase)

            % Create the dialog
            dlg = wt.dialog.ListSelection(testCase.Figure);
            dlg.Title = "Title";
            dlg.Prompt = "Prompt";
            dlg.Items = testCase.ItemNames;
            dlg.Value = testCase.ItemNames(1);
            drawnow

            % Get the controls
            listControl = dlg.ListBox;
            buttonGrid = dlg.DialogButtons;
            okButton = buttonGrid.Button(1);
            % closeButton = dlg.CloseButton;
            prompt = dlg.PromptLabel;
            grid = dlg.Grid;
            innerGrid = dlg.InnerGrid;
            outerPanel = dlg.OuterPanel;
            % outerGrid = dlg.OuterGrid;

            % Set font color
            expValue = [0 1 0];
            dlg.FontColor = expValue;
            testCase.verifyPropertyValue(listControl, "FontColor", expValue)
            testCase.verifyPropertyValue(okButton, "FontColor", expValue)

            % Set button background color
            expValue = [.6 .6 .6];
            dlg.ButtonColor = expValue;
            testCase.verifyPropertyValue(okButton, "BackgroundColor", expValue)

            % Set background color
            expValue = [.5 .5 .5];
            dlg.BackgroundColor = expValue;
            testCase.verifyPropertyValue(grid, "BackgroundColor", expValue)
            testCase.verifyPropertyValue(innerGrid, "BackgroundColor", expValue)
            testCase.verifyPropertyValue(buttonGrid, "BackgroundColor", expValue)
            testCase.verifyPropertyValue(prompt, "BackgroundColor", 'none')

            % Set font size
            expValue = 18;
            dlg.FontSize = expValue;
            testCase.verifyPropertyValue(prompt, "FontSize", expValue)
            testCase.verifyPropertyValue(listControl, "FontSize", expValue)
            testCase.verifyPropertyValue(okButton, "FontSize", expValue)

            % Set title size
            expValue = 22;
            dlg.TitleFontSize = expValue;
            testCase.verifyPropertyValue(outerPanel, "FontSize", expValue)

            % Set field background color
            expValue = [.4 .4 .4];
            dlg.FieldColor = expValue;
            testCase.verifyPropertyValue(listControl, "BackgroundColor", expValue)

        end %function
        
    end %methods (Test)


    methods (Access = private)

        function recordResizePosition(testCase, position)

            testCase.ResizePositions(end+1,:) = position;

        end %function

    end %methods
    
end %classdef
