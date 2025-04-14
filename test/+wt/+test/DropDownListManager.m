classdef DropDownListManager < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component

    % Copyright 2025 The MathWorks, Inc.

    %% Class Setup
    methods (TestClassSetup)

        function createFigure(testCase)

            % Call superclass method
            testCase.createFigure@wt.test.BaseWidgetTest();

            % Set up a grid layout
            numRows = 14;
            rowHeight = 30;
            testCase.Grid.RowHeight = repmat({rowHeight},1,numRows);

        end %function

    end %methods


    %% Test Method Setup
    methods (TestMethodSetup)

        function setup(testCase)

            fcn = @()wt.DropDownListManager(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);

            % Set callback
            testCase.Widget.ItemsChangedFcn = @(s,e)onCallbackTriggered(testCase,e);

            % Set initial list items
            testCase.Widget.Items = [
                "Initial Configuration"
                "Revision 1"
                "Revision 2"
                ];

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(0)

            % Ensure it renders
            drawnow

        end %function

    end %methods


    %% Helper methods
    methods (Access = private)

        function verifyControlValue(testCase, expValue)
            % Verifies the dropdown field has the specified value

            import matlab.unittest.constraints.Eventually
            import matlab.unittest.constraints.Matches

            % Verify values
            testCase.verifyThat(...
                @()testCase.Widget.DropDown.Items{testCase.Widget.DropDown.Value},...
                Eventually(Matches(expValue), "WithTimeoutOf", 5));

        end %function


        function verifyControlIndex(testCase, expValue)
            % Verifies the dropdown field has the specified value

            import matlab.unittest.constraints.Eventually
            import matlab.unittest.constraints.IsEqualTo

            % Verify values
            testCase.verifyThat(...
                @()testCase.Widget.Index,...
                Eventually(IsEqualTo(expValue), "WithTimeoutOf", 5));

        end %function


        function verifyValueProperty(testCase, expValue)
            % Verifies the Value property has the specified value

            import matlab.unittest.constraints.Eventually
            import matlab.unittest.constraints.Matches

            % Verify values
            testCase.verifyThat(...
                @()testCase.Widget.Value,...
                Eventually(Matches(expValue), "WithTimeoutOf", 5));

        end %function

    end % methods


    %% Unit Tests
    methods (Test)

        function testValueProperty(testCase)

            % Verify a value set
            newValue = "Revision 1";
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValue(newValue);

            % Verify a value set
            newValue = "Initial Configuration";
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValue(newValue);

            % Verify a value set
            newValue = "Revision 2";
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValue(newValue);

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(0)

        end %function


        function testIndexProperty(testCase)

            % Verify index set
            newValue = 3;
            testCase.verifySetProperty("Index", newValue);
            testCase.verifyControlValue("Revision 2");

            % Verify index set
            newValue = 1;
            testCase.verifySetProperty("Index", newValue);
            testCase.verifyControlValue("Initial Configuration");

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(0)

        end %function


        function testDropdownChoice(testCase)

            % Get the controls
            ddField = testCase.Widget.DropDown;

            % Select a valid value
            newValue = "Revision 1";
            testCase.choose(ddField, newValue);
            testCase.verifyValueProperty(newValue)
            testCase.verifyControlIndex(2)

            % Select a valid value
            newValue = "Initial Configuration";
            testCase.choose(ddField, newValue);
            testCase.verifyValueProperty(newValue)
            testCase.verifyControlIndex(1)

            % Select a valid value
            newValue = "Revision 2";
            testCase.choose(ddField, newValue);
            testCase.verifyValueProperty(newValue)
            testCase.verifyControlIndex(3)

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(3)

        end %function


        function testAdd(testCase)

            % Get the controls
            ddField = testCase.Widget.DropDown;
            editField = testCase.Widget.EditField;
            addButton = testCase.Widget.AddButton;

            % Verify states
            testCase.verifyFalse(testCase.Widget.IsAddingItem);
            testCase.verifyFalse(testCase.Widget.IsRenamingItem);

            % Push the button
            testCase.press(addButton)

            % Verify edit field is active
            testCase.verifyVisible(editField)
            testCase.verifyNotVisible(ddField)
            
            % Verify states
            testCase.verifyTrue(testCase.Widget.IsAddingItem);
            testCase.verifyFalse(testCase.Widget.IsRenamingItem);
            testCase.verifyMatches(editField.Value, '<New Item>');

            % Enter a new item
            newValue = "Revision 3";
            testCase.type(editField, newValue);
            testCase.verifyValueProperty(newValue)
            testCase.verifyControlIndex(4)

            % Verify dropdown is active
            testCase.verifyVisible(ddField)
            testCase.verifyNotVisible(editField)

            % Verify states
            testCase.verifyFalse(testCase.Widget.IsAddingItem);
            testCase.verifyFalse(testCase.Widget.IsRenamingItem);

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(1)

            % Verify length of Items
            testCase.verifyNumElements(testCase.Widget.Items, 4);

        end %function


        function testAddFromEmpty(testCase)

            % Clear the items
            testCase.verifySetProperty("Items", string.empty(1,0));

            % Get the controls
            ddField = testCase.Widget.DropDown;
            editField = testCase.Widget.EditField;
            addButton = testCase.Widget.AddButton;

            % Verify dropdown not enabled
            testCase.verifyNotEnabled(ddField)

            % Push the add button
            testCase.press(addButton)

            % Verify edit field is active
            testCase.verifyVisible(editField)
            testCase.verifyNotVisible(ddField)

            % Enter a new item
            newValue = "New Initial Version";
            testCase.type(editField, newValue);
            testCase.verifyValueProperty(newValue)
            testCase.verifyControlIndex(1)

            % Verify dropdown enabled
            testCase.verifyEnabled(ddField)

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(1)

        end %function


        function testRename(testCase)

            % Get the controls
            ddField = testCase.Widget.DropDown;
            editField = testCase.Widget.EditField;
            renameButton = testCase.Widget.RenameButton;

            % Verify a value set
            newValue = "Revision 2";
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValue(newValue);

            % Verify states
            testCase.verifyFalse(testCase.Widget.IsAddingItem);
            testCase.verifyFalse(testCase.Widget.IsRenamingItem);

            % Push the button
            testCase.press(renameButton)

            % Verify edit field is active
            testCase.verifyVisible(editField)
            testCase.verifyNotVisible(ddField)

            % Verify states
            testCase.verifyFalse(testCase.Widget.IsAddingItem);
            testCase.verifyTrue(testCase.Widget.IsRenamingItem);

            % Enter a new item
            newValue = "Modified - Revision 2";
            testCase.type(editField, newValue);
            testCase.verifyValueProperty(newValue)
            testCase.verifyControlIndex(3)

            % Verify dropdown is active
            testCase.verifyVisible(ddField)
            testCase.verifyNotVisible(editField)

            % Verify states
            testCase.verifyFalse(testCase.Widget.IsAddingItem);
            testCase.verifyFalse(testCase.Widget.IsRenamingItem);

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(1)

            % Verify length of Items
            testCase.verifyNumElements(testCase.Widget.Items, 3);

        end %function


        function testRemove(testCase)

            % Get the controls
            ddField = testCase.Widget.DropDown;
            editField = testCase.Widget.EditField;
            removeButton = testCase.Widget.RemoveButton;

            % Verify a value set
            newValue = "Revision 1";
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyControlValue(newValue);

            % Push the button
            testCase.press(removeButton)

            % Verify the new selection
            testCase.verifyValueProperty("Revision 2")
            testCase.verifyControlIndex(2)

            % Verify dropdown is active
            testCase.verifyVisible(ddField)
            testCase.verifyNotVisible(editField)

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(1)

            % Verify length of Items
            testCase.verifyNumElements(testCase.Widget.Items, 2);


            % Push the button
            testCase.press(removeButton)

            % Verify the new selection
            testCase.verifyValueProperty("Initial Configuration")
            testCase.verifyControlIndex(1)

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(2)

            % Verify length of Items
            testCase.verifyNumElements(testCase.Widget.Items, 1);


            % Push the button
            testCase.press(removeButton)

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(3)

            % Verify length of Items
            testCase.verifyNumElements(testCase.Widget.Items, 0);

        end %function


        function testAllowItemRemove(testCase)

            % Get the controls
            ddField = testCase.Widget.DropDown;
            addButton = testCase.Widget.AddButton;
            renameButton = testCase.Widget.RenameButton;
            removeButton = testCase.Widget.RemoveButton;

            % Disallow removing second item
            testCase.Widget.AllowItemRemove(2) = false;

            % Verify button enables
            testCase.verifyEnabled(addButton)
            testCase.verifyEnabled(renameButton)
            testCase.verifyEnabled(removeButton)

            % Choose second item
            newValue = "Revision 1";
            testCase.choose(ddField, newValue);

            % Verify button enables
            testCase.verifyEnabled(addButton)
            testCase.verifyEnabled(renameButton)
            testCase.verifyNotEnabled(removeButton)

            % Choose third item
            newValue = "Revision 2";
            testCase.choose(ddField, newValue);

            % Verify button enables
            testCase.verifyEnabled(addButton)
            testCase.verifyEnabled(renameButton)
            testCase.verifyEnabled(removeButton)

        end %function


        function testAllowItemRename(testCase)

            % Get the controls
            ddField = testCase.Widget.DropDown;
            addButton = testCase.Widget.AddButton;
            renameButton = testCase.Widget.RenameButton;
            removeButton = testCase.Widget.RemoveButton;

            % Verify button enables
            testCase.verifyEnabled(addButton)
            testCase.verifyEnabled(renameButton)
            testCase.verifyEnabled(removeButton)

            % Disallow renaming second item
            testCase.Widget.AllowItemRename(2) = false;

            % Choose second item
            newValue = "Revision 1";
            testCase.choose(ddField, newValue);

            % Verify button enables
            testCase.verifyEnabled(addButton)
            testCase.verifyNotEnabled(renameButton)
            testCase.verifyEnabled(removeButton)

            % Choose third item
            newValue = "Revision 2";
            testCase.choose(ddField, newValue);

            % Verify button enables
            testCase.verifyEnabled(addButton)
            testCase.verifyEnabled(renameButton)
            testCase.verifyEnabled(removeButton)

        end %function


        function testAllowRemove(testCase)

            % Get the controls
            grid = testCase.Widget.Grid;
            renameButton = testCase.Widget.RenameButton;
            removeButton = testCase.Widget.RemoveButton;

            % Verify button parents
            testCase.verifyEqual(renameButton.Parent, grid)
            testCase.verifyEqual(removeButton.Parent, grid)

            % Disallow renaming anything
            testCase.Widget.AllowRemove = false;

            % Verify button parents
            testCase.verifyEqual(renameButton.Parent, grid)
            testCase.verifyEmpty(removeButton.Parent)
            
        end %function


        function testAllowRename(testCase)

            % Get the controls
            grid = testCase.Widget.Grid;
            renameButton = testCase.Widget.RenameButton;
            removeButton = testCase.Widget.RemoveButton;

            % Verify button parents
            testCase.verifyEqual(renameButton.Parent, grid)
            testCase.verifyEqual(removeButton.Parent, grid)

            % Disallow renaming anything
            testCase.Widget.AllowRename = false;

            % Verify button parents
            testCase.verifyEmpty(renameButton.Parent)
            testCase.verifyEqual(removeButton.Parent, grid)

        end %function

    end %methods (Test)

end %classdef

