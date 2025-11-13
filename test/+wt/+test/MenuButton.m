classdef MenuButton < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component

    % Copyright 2025 The MathWorks, Inc.

    %% Class Setup
    methods (TestClassSetup)

        function createFigure(testCase)

            testCase.assumeMinimumRelease("R2022a")

            % Call superclass method
            testCase.createFigure@wt.test.BaseWidgetTest();

            % Set a background grid to put the main Grid on the right only
            backgroundGrid = uigridlayout(testCase.Grid.Parent, [1 2]);
            backgroundGrid.ColumnWidth = {'1x',70,'1x'};
            testCase.Grid.Parent = backgroundGrid;
            testCase.Grid.Layout.Column = 2;
            
            % Set up a grid layout
            numRows = 10;
            rowHeight = 30;
            testCase.Grid.RowHeight = repmat({rowHeight},1,numRows);
            testCase.Grid.ColumnWidth = {'1x'};

        end %function

    end %methods


    %% Test Method Setup
    methods (TestMethodSetup)

        function setup(testCase)

            fcn = @()wt.MenuButton(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);

            % Set callback
            testCase.Widget.MenuSelectedFcn = @(s,e)onCallbackTriggered(testCase,e);

            % % Default entries
            % newValue = [1 2 3 4];
            % testCase.verifySetProperty("Value", newValue);
            % testCase.verifyControlValues(newValue);

            % Ensure it renders
            drawnow

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(0)

        end %function

    end %methods


    %% Unit Tests
    methods (Test)

        function testAddItemsWithName(testCase)

            % Add items by name
            expNames = ["Item 1","Item 2","Item 3","Item 4"];
            testCase.Widget.addMenuItems(expNames);

            % Press the button
            button = testCase.Widget.Button;
            testCase.press(button);

            % Verify the menu items
            testCase.verifyMenuItemsExist(expNames)

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(0)

        end %function


        function testAddItemsWithNameAndTag(testCase)

            % Add items by name
            expNames = ["Item 1","Item 2","Item 3","Item 4"];
            expTags = ["i1","i2","i3","i4"];
            testCase.Widget.addMenuItems(expNames, expTags);

            % Press the button
            button = testCase.Widget.Button;
            testCase.press(button);

            % Verify the menu items
            testCase.verifyMenuItemsExist(expNames, expTags)

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(0)

        end %function


        function testMenuSelectedCallback(testCase)

            % Add items by name
            expNames = ["Item 1","Item 2","Item 3","Item 4"];
            menuItems = testCase.Widget.addMenuItems(expNames);

            % Press the button
            button = testCase.Widget.Button;
            testCase.press(button);

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(0)

            % Press a menu item
            testCase.press(menuItems(2));

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(1)

        end %function


        function testSubMenuItems(testCase)

            % Add items by name
            expNames = ["Item 1","Item 2"];
            menuItems = testCase.Widget.addMenuItems(expNames);

            % Add sub-menu items
            expSubNames = ["Item 1A","Item 1B"];
            subMenuItems = testCase.Widget.addSubMenuItems(...
                menuItems(1), expSubNames);

            % Press the button
            button = testCase.Widget.Button;
            testCase.press(button);

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(0)

            % Press sub menu item
            testCase.press(subMenuItems(2));

            % Verify number of callbacks so far
            % It will be one for parent, one for child item
            testCase.verifyCallbackCount(2)

        end %function

    end %methods (Test)


    %% Helper methods
    methods (Access = private)

        function verifyMenuItemsExist(testCase, expNames, expTags)
            % Verifies the menu has the given names

            arguments
                testCase
                expNames (:,1) string
                expTags (:,1) string = repmat("",size(expNames))
            end

            import matlab.unittest.constraints.Eventually
            import matlab.unittest.constraints.IsEqualTo

            % Verify names
            if isempty(expNames)
                testCase.verifyEmpty(testCase.Widget.Menu.Children)
            else
                constraint = Eventually(IsEqualTo(expNames), "WithTimeoutOf", 5);
                testCase.verifyThat(@()testCase.getMenuItemNames(), constraint);
            end

            % Verify tags
            constraint = Eventually(IsEqualTo(expTags), "WithTimeoutOf", 5);
            testCase.verifyThat(@()testCase.getMenuItemTags(), constraint);

        end %function


        function names = getMenuItemNames(testCase)
            % Get the menu item names

            menu = testCase.Widget.Menu;

            names = string.empty(0,1);
            if isscalar(menu) && isvalid(menu)
                items = menu.Children;
                if ~isempty(items)
                    names = string( {items.Text}' );
                    names = flip(names);
                end
            end

        end %function


        function tags = getMenuItemTags(testCase)
            % Get the menu item names

            menu = testCase.Widget.Menu;

            tags = string.empty(0,1);
            if isscalar(menu) && isvalid(menu)
                items = menu.Children;
                if ~isempty(items)
                    tags = string( {items.Tag}' );
                    tags = flip(tags);
                end
            end

        end %function

    end % methods

end %classdef

