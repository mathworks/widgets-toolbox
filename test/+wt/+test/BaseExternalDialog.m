classdef BaseExternalDialog < wt.test.BaseDialogTest
    % Tests for wt.abstract.BaseExternalDialog.

    % Copyright 2026 The MathWorks, Inc.

    properties (Access = private)
        DialogButtonCount (1,1) double {mustBeInteger, mustBeNonnegative} = 0
        DialogButtonEvents (1,:) cell = {}
    end

    methods (TestMethodSetup)
        function resetEventTracking(testCase)
            testCase.DialogButtonCount = 0;
            testCase.DialogButtonEvents = {};
        end
    end

    methods (Test)
        function testDefaultsWithCallingFigure(testCase)

            dlg = testCase.createDialog();

            testCase.verifyEqual(dlg.Size, [350 200])
            testCase.verifyFalse(dlg.Modal)
            testCase.verifyEqual(dlg.Title, "")
            testCase.verifyEqual(dlg.DeleteActions, ...
                ["delete","close","ok","cancel","exit"])
            testCase.verifyFalse(dlg.IsWaitingForOutput)
            testCase.verifyEmpty(dlg.Output)
            testCase.verifyFalse(dlg.ModalImage.Visible)
            testCase.verifyEqual(dlg.CallingFigure, testCase.Figure)
            testCase.verifyTrue(isvalid(dlg.DialogFigure))

        end

        function testDialogFigureProperties(testCase)

            dlg = testCase.createDialog();
            expTitle = "External Dialog";
            expPosition = [100 120 320 240];
            expTooltip = "Dialog is open";

            dlg.Title = expTitle;
            dlg.DialogPosition = expPosition;
            dlg.ModalTooltip = expTooltip;
            drawnow

            testCase.verifyEqual(dlg.Title, expTitle)
            testCase.verifyEqual(dlg.DialogPosition, expPosition)
            testCase.verifyEqual(dlg.ModalTooltip, expTooltip)
            testCase.verifyEqual(string(dlg.DialogFigure.Name), expTitle)

        end

        function testDialogButtonProperties(testCase)

            dlg = testCase.createDialog();

            dlg.DialogButtonText = ["Apply","Cancel"];
            dlg.DialogButtonTag = ["apply","cancel"];
            dlg.DialogButtonTooltip = ["Apply changes","Cancel changes"];
            dlg.DialogButtonEnable = [true false];
            drawnow

            testCase.verifyEqual(dlg.DialogButtonText, ["Apply","Cancel"])
            testCase.verifyEqual(dlg.DialogButtonTag, ["apply","cancel"])
            testCase.verifyEqual(dlg.DialogButtonTooltip, ...
                ["Apply changes","Cancel changes"])
            testCase.verifyEqual(logical(dlg.DialogButtonEnable), ...
                [true false])
            testCase.verifyNumElements(dlg.DialogButtons.Button, 2)

        end

        function testNonDeleteButtonNotifiesWithoutDeleting(testCase)

            dlg = testCase.createDialog();
            dlg.DialogButtonText = "Apply";
            dlg.DialogButtonTag = "apply";
            dlg.DialogButtonPushedFcn = ...
                @(~,evt)testCase.onDialogButtonPushed(evt);
            drawnow


            testCase.press(dlg.DialogButtons.Button(1))
            drawnow

            testCase.verifyTrue(isvalid(dlg))
            testCase.verifyEqual(testCase.DialogButtonCount, 1)
            testCase.verifyEqual(testCase.DialogButtonEvents{1}.Action, "apply")

        end

        function testDeleteButtonDeletesDialogAndFigure(testCase)

            dlg = testCase.createDialog();
            dlg.DialogButtonText = "Cancel";
            dlg.DialogButtonTag = "cancel";
            dialogFigure = dlg.DialogFigure;
            drawnow

            testCase.press(dlg.DialogButtons.Button(1))
            drawnow

            testCase.verifyFalse(isvalid(dlg))
            testCase.verifyFalse(isvalid(dialogFigure))

        end

        function testModalTogglesOverlay(testCase)

            dlg = testCase.createDialog();

            dlg.Modal = true;
            drawnow

            testCase.verifyTrue(dlg.ModalImage.Visible)

            dlg.Modal = false;
            drawnow

            testCase.verifyFalse(dlg.ModalImage.Visible)

        end

        function testLifecycleOwnerDeletionDeletesDialog(testCase)

            dlg = testCase.createDialog();
            owner = uipanel(testCase.Figure);

            dlg.attachLifecycleListeners(owner);
            delete(owner)
            drawnow

            testCase.verifyFalse(isvalid(dlg))

        end
    end

    methods (Access = private)
        function dlg = createDialog(testCase)

            fcn = @()wt.abstract.BaseExternalDialog(testCase.Figure);
            dlg = testCase.verifyWarningFree(fcn);
            testCase.addTeardown(@()testCase.deleteDialog(dlg))
            drawnow

        end

        function deleteDialog(~, dlg)

            if isvalid(dlg)
                delete(dlg)
            end

        end

        function onDialogButtonPushed(testCase, evt)

            testCase.DialogButtonCount = testCase.DialogButtonCount + 1;
            testCase.DialogButtonEvents{end+1} = evt;

        end
    end

end
