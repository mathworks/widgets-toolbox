classdef CheckboxList < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
%   Copyright 2020-2026 The MathWorks Inc.
    
    
    
    %% Class Setup
    methods (TestClassSetup)
        
        function createFigure(testCase)
            
            % Call superclass method
            testCase.createFigure@wt.test.BaseWidgetTest();
            
            % Make the figure taller
            testCase.Figure.Position(4) = 600;
            
            % Modify the grid row height
            testCase.Grid.RowHeight = {'1x','1x','1x'};
            testCase.Grid.ColumnWidth = {'1x','1x','1x'};
            
        end %function
        
    end %methods
    
    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            fcn = @()wt.CheckboxList(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            
            % Set callback
            testCase.Widget.ValueChangedFcn = @(s,e)onCallbackTriggered(testCase,e);
            
            % Ensure it renders
            drawnow
            
        end %function
        
    end %methods
    
    
    %% Unit Tests
    methods (Test)

        function testTopPadding(testCase)

            padding = testCase.Widget.ItemCheck(1).Parent.Padding;
            testCase.verifyEqual(padding, [0 0 0 0]);

        end %function

        function testSelectAllRowHeight(testCase)

            grid = testCase.Widget.AllCheck.Parent;
            testCase.verifyEqual(grid.RowHeight{1}, 0);

            testCase.verifySetProperty("ShowSelectAll", true);
            testCase.verifyEqual(grid.RowHeight{1}, 'fit');
            testCase.verifyEqual(grid.RowSpacing, 5);
            testCase.verifyEqual(testCase.Widget.AllCheck.FontWeight, 'bold');

            testCase.verifySetProperty("ShowSelectAll", false);
            testCase.verifyEqual(grid.RowHeight{1}, 0);
            testCase.verifyEqual(testCase.Widget.AllCheck.Visible, ...
                matlab.lang.OnOffSwitchState.off);

            testCase.verifySetProperty("ShowSelectAll", true);
            testCase.verifyEqual(grid.RowHeight{1}, 'fit');

        end %function

        function testSelectAllLayoutAfterItemChanges(testCase)

            testCase.verifySetProperty("ShowSelectAll", true);
            testCase.verifySetProperty("Items", "Item " + string(1:10)');
            testCase.verifySetProperty("Items", ["First"; "Second"]);
            grid = testCase.Widget.AllCheck.Parent;
            testCase.verifyEqual(grid.RowHeight{1}, 'fit');
            testCase.verifyEqual(grid.RowSpacing, 5);
            testCase.verifyNumElements(testCase.Widget.ItemCheck, 2);

        end %function

        function testSelectAllFontStyling(testCase)

            testCase.verifySetProperty("ShowSelectAll", true);
            testCase.verifySetProperty("FontSize", 18);
            testCase.verifySetProperty("FontWeight", "normal");
            testCase.verifyEqual(testCase.Widget.AllCheck.FontWeight, 'bold');
            testCase.verifyEqual(testCase.Widget.AllCheck.FontSize, 18);
            testCase.verifyEqual(testCase.Widget.AllCheck.Parent.RowHeight{1}, 'fit');

        end %function

        function testSharedFonts(testCase)

            testCase.verifySetProperty("ShowSelectAll", true);
            testCase.verifySetProperty("FontName", 'Arial');
            testCase.verifySetProperty("FontSize", 18);
            testCase.verifySetProperty("FontAngle", 'italic');
            testCase.verifySetProperty("FontColor", [0.2 0.4 0.6]);
            testCase.verifySetProperty("FontWeight", 'normal');
            testCase.verifyMatchingFonts();
            testCase.verifySetProperty("FontWeight", 'bold');
            testCase.verifyMatchingFonts();
            testCase.verifySetProperty("ShowSelectAll", false);
            testCase.verifySetProperty("ShowSelectAll", true);
            testCase.verifySetProperty("Items", "Item " + string(1:10)');
            testCase.verifyMatchingFonts();
            testCase.verifySetProperty("Items", ["First"; "Second"]);
            testCase.verifyMatchingFonts();

        end

        function testConstructorFonts(testCase)

            widget = wt.CheckboxList(testCase.Grid, ...
                "FontName",'Arial', "FontSize",16, "FontAngle",'italic', ...
                "FontColor",[0.3 0.5 0.7], "ShowSelectAll",true);
            testCase.addTeardown(@()delete(widget));
            testCase.Widget = widget;
            drawnow
            testCase.verifyMatchingFonts();

        end

        function testSeparatorLayout(testCase)

            import matlab.unittest.constraints.Eventually
            import matlab.unittest.constraints.IsTrue

            testCase.verifySetProperty("ShowSelectAll", true);
            widget = testCase.Widget;
            separator = widget.SelectAllSeparator;
            testCase.verifyEqual(separator.Parent.RowHeight{2}, 1);
            testCase.verifyThat(@()abs(separator.Position(4) - 1) < 0.01 && ...
                abs(widget.AllCheck.Position(2) - ...
                (separator.Position(2) + separator.Position(4)) - 5) < 0.5 && ...
                abs(separator.Position(2) - ...
                (widget.ItemCheck(1).Position(2) + widget.ItemCheck(1).Position(4)) - 5) < 0.5 && ...
                abs(separator.Position(3) - widget.Grid.Position(3)) < 0.5, ...
                Eventually(IsTrue, 'WithTimeoutOf', 10));

            testCase.verifySetProperty("ShowSelectAll", false);
            testCase.verifyEqual(separator.Visible, matlab.lang.OnOffSwitchState.off);
            testCase.verifyEqual(widget.Grid.RowHeight(1:2), {0,0});
            testCase.verifyThat(@()abs(widget.ItemCheck(1).Position(2) + ...
                widget.ItemCheck(1).Position(4) - (widget.Grid.Position(4) + 1)) < 0.01, ...
                Eventually(IsTrue, 'WithTimeoutOf', 10));

        end

        function testEmptyItemsAndRegrowth(testCase)

            testCase.verifySetProperty("ShowSelectAll", true);
            testCase.verifySetProperty("Items", strings(0,1));
            testCase.verifyEmpty(testCase.Widget.ItemCheck);
            testCase.verifyEqual(testCase.Widget.Grid.RowHeight, {'fit',1});
            testCase.verifySetProperty("ShowSelectAll", false);
            testCase.verifyEqual(testCase.Widget.Grid.RowHeight, {0,0});
            testCase.verifySetProperty("Items", ["First"; "Second"]);
            testCase.verifySetProperty("ShowSelectAll", true);
            testCase.verifyEqual(arrayfun(@(c)c.Layout.Row, ...
                testCase.Widget.ItemCheck), [3 4]);
            testCase.verifyEqual(testCase.Widget.Grid.RowHeight, {'fit',1,'fit','fit'});
            testCase.verifyMatchingFonts();

        end

        function testSeparatorAutomaticColor(testCase)

            testCase.verifySetProperty("FontColor", [0.2 0.4 0.6]);
            testCase.verifySetProperty("FontColorMode", 'auto');
            testCase.verifyEqual(testCase.Widget.SelectAllSeparator.BackgroundColor, ...
                testCase.Widget.AllCheck.FontColor);

        end

        function testSeparatorEnableState(testCase)

            testCase.verifySetProperty("ShowSelectAll", true);
            testCase.verifySetProperty("FontColor", [0.2 0.4 0.6]);
            testCase.verifySetProperty("BackgroundColor", [1 1 1]);
            testCase.verifySetProperty("Enable", false);
            testCase.verifyEqual(testCase.Widget.AllCheck.Enable, ...
                matlab.lang.OnOffSwitchState.off);
            testCase.verifyEqual(testCase.Widget.SelectAllSeparator.Enable, ...
                matlab.lang.OnOffSwitchState.off);

            testCase.verifySetProperty("FontColor", [0.5 0.5 0.5]);
            testCase.verifySetProperty("BackgroundColor", [0 0 0]);
            testCase.verifyEqual(testCase.Widget.SelectAllSeparator.BackgroundColor, ...
                testCase.Widget.FontColor);
            testCase.verifySetProperty("ShowSelectAll", false);
            testCase.verifySetProperty("Items", ["First"; "Second"]);
            testCase.verifySetProperty("ShowSelectAll", true);
            testCase.verifyEqual(testCase.Widget.SelectAllSeparator.Enable, ...
                matlab.lang.OnOffSwitchState.off);
            testCase.verifySetProperty("Items", "Item " + string(1:10)');
            testCase.verifyEqual(testCase.Widget.SelectAllSeparator.Enable, ...
                matlab.lang.OnOffSwitchState.off);

            testCase.verifySetProperty("Enable", true);
            testCase.verifyEqual(testCase.Widget.SelectAllSeparator.Enable, ...
                matlab.lang.OnOffSwitchState.on);
            testCase.verifyEqual(testCase.Widget.SelectAllSeparator.BackgroundColor, ...
                testCase.Widget.AllCheck.FontColor);

        end

        function testSeparatorDisabledAtConstruction(testCase)

            widget = wt.CheckboxList(testCase.Grid, ...
                "Enable",false, "ShowSelectAll",true, ...
                "FontColor",[1 1 1], "BackgroundColor",[0 0 0]);
            testCase.addTeardown(@()delete(widget));
            drawnow
            testCase.verifyEqual(widget.SelectAllSeparator.Enable, ...
                matlab.lang.OnOffSwitchState.off);

        end
            
        function testItems(testCase)
            
            % Set the items
            items = [
                "California"
                "Massachusetts"
                "New Mexico"
                ];
            testCase.verifySetProperty("Items", items);
            
            % Verify value adapts
            numItems = numel(items);
            actVal = testCase.Widget.Value;
            expVal = true(numItems, 1);
            testCase.verifyEqual(actVal, expVal);
            
            % Add more items
            items = "Item " + string(1:10)';
            testCase.verifySetProperty("Items", items);
           
            % Verify the value adapts
            numItems = numel(items);
            actVal = testCase.Widget.Value;
            expVal = true(numItems, 1);
            testCase.verifyEqual(actVal, expVal);
            
        end %function
        
            
        function testValue(testCase)
            
            % Verify value is matching size
            numItems = numel(testCase.Widget.Items);
            actVal = testCase.Widget.Value;
            expVal = true(numItems, 1);
            testCase.verifyEqual(actVal, expVal);
            
            % Get the checkbox controls
            cbox = testCase.Widget.ItemCheck;
            
            % Change all values to false
            newValue = false(numItems, 1);
            testCase.verifySetProperty("Value", newValue)
            testCase.verifyEqual([cbox.Value]', newValue);
            
            % Toggle checkboxes
            idxOn = 3;
            testCase.choose(cbox(idxOn));
            newValue(idxOn) = true;
            testCase.verifyEqual(testCase.Widget.Value, newValue)
            testCase.verifyEqual([cbox.Value]', newValue);
            
            % Verify callback fired
            testCase.verifyEqual(testCase.CallbackCount, 1);
            
        end %function
        
            
        function testSelectAll(testCase)
            
            numItems = numel(testCase.Widget.Items);
            allFalse = false(numItems, 1);
            allTrue = true(numItems, 1);
            
            % Turn off all checkbox values
            testCase.verifySetProperty("Value", allFalse);
            
            % Toggle on select all
            testCase.verifySetProperty("ShowSelectAll", true);
            
            % Re-verify value
            testCase.verifyEqual(testCase.Widget.Value, allFalse);
            
            % Get the checkbox controls
            cbox = testCase.Widget.ItemCheck;
            AllCheck = testCase.Widget.AllCheck;
            
            % Choose select all
            testCase.choose(AllCheck);
            
            % Verify new value
            testCase.verifyEqual(testCase.Widget.Value, allTrue);
            drawnow
            testCase.verifyEqual([cbox.Value]', allTrue);
            
            % Verify callback fired
            testCase.verifyEqual(testCase.CallbackCount, 1);
            
        end %function
        
    end %methods (Test)

    methods (Access = private)
        function verifyMatchingFonts(testCase)
            widget = testCase.Widget;
            controls = [widget.AllCheck, widget.ItemCheck];
            testCase.verifyEqual({controls.FontName}, ...
                repmat({widget.FontName},1,numel(controls)));
            testCase.verifyEqual([controls.FontSize], ...
                repmat(widget.FontSize,1,numel(controls)));
            testCase.verifyEqual({controls.FontAngle}, ...
                repmat({char(widget.FontAngle)},1,numel(controls)));
            testCase.verifyEqual(vertcat(controls.FontColor), ...
                repmat(widget.FontColor,numel(controls),1));
            testCase.verifyEqual(widget.AllCheck.FontWeight, 'bold');
            testCase.verifyEqual({widget.ItemCheck.FontWeight}, ...
                repmat({char(widget.FontWeight)},1,numel(widget.ItemCheck)));
            testCase.verifyEqual(widget.SelectAllSeparator.BackgroundColor, ...
                widget.FontColor);
        end
    end
    
end %classdef