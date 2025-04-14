classdef Toolbar < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
%   Copyright 2021-2025 The MathWorks Inc.
    
    
    %% Properties
    properties (SetAccess = protected)
        
        % Test can trigger this when ButtonPressedFcn is fired by toolbar
        ButtonPushCallbackDone (1,1) logical = false;
        
    end %properties
    
    
    %% Class Setup
    methods (TestClassSetup)
        
        function createFigure(testCase)
            
            % Call superclass method
            testCase.createFigure@wt.test.BaseWidgetTest();
            
            % Make the figure wider
            testCase.Figure.Position([3 4]) = [600 600];
            
            % Modify the grid row height
            numRows = 6;
            rowHeight = 90;
            testCase.Grid.RowHeight = repmat({rowHeight},1,numRows);
            
        end %function
        
    end %methods
    
    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            fcn = @()wt.Toolbar(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            
            % Set default callback
            testCase.Widget.ButtonPushedFcn = @(s,e)onButtonPushed(testCase);
            
            % Default state is false when each test begins
            testCase.ButtonPushCallbackDone = false;
            
            % Ensure it renders
            drawnow
            
        end %function
        
    end %methods
    
    
    %% Helper methods
    methods (Access = private)
        
        function onButtonPushed(testCase, ~)
            % Callback when a button is pressed
            
            testCase.ButtonPushCallbackDone = true;
            
        end %function
        
        
        function button = verifyAddButton(testCase, section, name, icon)
            % Adds a button to the last horizontal section (or to the
            % specified section)
            
            arguments
                testCase
                section (1,1) wt.toolbar.BaseSection
                name (1,1) string = ""
                icon (1,1) string = ""
            end
        
            fcn = @()addButton(section, icon, name);
            button = testCase.verifyWarningFree(fcn);
            drawnow
            
            % Verify the buttons changed
            newButton = section.Component(end);
            testCase.verifyClass(newButton, "matlab.ui.control.Button")
            testCase.verifyMatches(name, newButton.Text)
            testCase.verifyMatches(icon, newButton.Icon)
            
        end %function
        
        
        function button = verifyAddStateButton(testCase, section, name, icon)
            % Adds a button to the last horizontal section (or to the
            % specified section)
            
            arguments
                testCase
                section (1,1) wt.toolbar.BaseSection
                name (1,1) string = ""
                icon (1,1) string = ""
            end
        
            fcn = @()addStateButton(section, icon, name);
            button = testCase.verifyWarningFree(fcn);
            drawnow
            
            % Verify the buttons changed
            newButton = section.Component(end);
            testCase.verifyClass(newButton, "matlab.ui.control.StateButton")
            testCase.verifyMatches(name, newButton.Text)
            testCase.verifyMatches(icon, newButton.Icon)
            
        end %function
        
        
        function section = verifyAddVerticalSection(testCase, section)
            % Adds a vertical section to the last horizontal section (or to
            % the specified section)
            
            arguments
                testCase
                section (1,1) wt.toolbar.BaseSection
            end
        
            fcn = @()addVerticalSection(section);
            section = testCase.verifyWarningFree(fcn);
            drawnow
            
        end %function
        
        
        function section = addMultiSections(testCase, sizes)
            
            % Preallocate
            section(numel(sizes),1) = wt.toolbar.HorizontalSection();
            
            % Create each section
            for sIdx = 1:numel(sizes)
                section(sIdx) = wt.toolbar.HorizontalSection();
                section(sIdx).Title = "SECTION " + sIdx;
                for bIdx = 1:sizes(sIdx)
                    section(sIdx).addButton("", string(bIdx));
                end
            end
            drawnow
            
            % Attach the sections to the toolbar
            testCase.verifySetProperty("Section", section)
            
        end %function
        
    end % methods
    
    
    %% Unit Tests
    methods (Test)
        
        function testHorizontalSection(testCase)
            import matlab.unittest.constraints.Eventually
            import matlab.unittest.constraints.IsGreaterThan
            % Add a single horizontal section (always required)
            fcn = @()wt.toolbar.HorizontalSection();
            section = verifyWarningFree(testCase, fcn);
            
            % Add buttons
            testCase.verifyAddButton(section,"Open","open_24.png");
            testCase.verifyAddButton(section,"Save","save_24.png");
            
            % Set the section title
            newValue = "MY HORIZONTAL SECTION";
            section.Title = newValue;
            
            % Attach the sections to the toolbar
            testCase.verifySetProperty("Section", section)
            
            % Verify the label changed
            actValue = testCase.Widget.SectionLabel(1).Text;
            testCase.verifyMatches(newValue, actValue)
            
            % Verify the section width
            testCase.verifyNumElements(testCase.Widget.Grid.ColumnWidth, 2)
            minWidth = 99; %pixels
            testCase.verifyThat(@()testCase.Widget.Grid.ColumnWidth{1}, Eventually(IsGreaterThan(minWidth)));
            
        end %function
        
        
        function testStateButtons(testCase)

            % Add a single horizontal section (always required)
            fcn = @()wt.toolbar.HorizontalSection();
            section = verifyWarningFree(testCase, fcn);
            
            % Add buttons
            b1 = testCase.verifyAddStateButton(section,"Play","play_24.png");
            b2 = testCase.verifyAddStateButton(section,"Stop","stop_24.png");
            
            % Attach the sections to the toolbar
            testCase.verifySetProperty("Section", section)
            
            % Press a state button
            testCase.ButtonPushCallbackDone = false;
            testCase.press(b1)
            
            % Verify the callback was fired
            testCase.verifyTrue(testCase.ButtonPushCallbackDone);
            
            % Verify states
            testCase.verifyTrue(b1.Value)
            testCase.verifyFalse(b2.Value)
            
            % Press the other state button
            testCase.ButtonPushCallbackDone = false;
            testCase.press(b2)
            
            % Verify the callback was fired
            testCase.verifyTrue(testCase.ButtonPushCallbackDone);
            
            % Verify states
            testCase.verifyTrue(b1.Value)
            testCase.verifyTrue(b2.Value)
            
        end %function
        
        
        function testVerticalSection(testCase)
            
            % Add a single horizontal section (always required)
            fcn = @()wt.toolbar.HorizontalSection();
            section = verifyWarningFree(testCase, fcn);
            
            % Add vertical section
            sectionV = testCase.verifyAddVerticalSection(section);
            
            % Add buttons
            testCase.verifyAddButton(sectionV,"Play","play_24.png");
            testCase.verifyAddButton(sectionV,"Stop","stop_24.png");
            
            % Attach the sections to the toolbar
            testCase.verifySetProperty("Section", section)
            
            % Verify the section width
            testCase.verifyNumElements(testCase.Widget.Grid.ColumnWidth, 2)
            sectionWidth = testCase.Widget.Grid.ColumnWidth{1};
            minWidth = 75; %pixels
            testCase.verifyGreaterThan(sectionWidth, minWidth)
            
            % Verify the section heights
            expValue = {'fit'  'fit'};
            actValue = sectionV.Grid.RowHeight;
            testCase.verifyEqual(actValue, expValue)

        end %function
        
        
        function testCustomComponent(testCase)
            
            % Add a single horizontal section (always required)
            fcn = @()wt.toolbar.HorizontalSection();
            section = verifyWarningFree(testCase, fcn);
            
            % Add custom component to horizontal section
            customA = uiimage("Parent",[]);
            section.Component(end+1) = customA;
            
            % Add vertical section
            sectionV = testCase.verifyAddVerticalSection(section);
            
            % Add button
            testCase.verifyAddButton(sectionV,"Play","play_24.png");
            
            % Add custom component to vertical section
            customB = uislider("Parent",[]);
            sectionV.Component(end+1) = customB;
            
            % Attach the sections to the toolbar
            testCase.verifySetProperty("Section", section)

            % Verify the component placement
            testCase.verifyEqual(customA.Parent, section.Grid)
            testCase.verifyEqual(customB.Parent, sectionV.Grid)
            
            % Verify the section width
            testCase.verifyNumElements(testCase.Widget.Grid.ColumnWidth, 2)
            sectionWidth = testCase.Widget.Grid.ColumnWidth{1};
            minWidth = 150; %pixels
            testCase.verifyGreaterThan(sectionWidth, minWidth)
            
            % Verify the section heights
            expValue = {'fit'  'fit'};
            actValue = sectionV.Grid.RowHeight;
            testCase.verifyEqual(actValue, expValue)

        end %function
        
        
        function testSectionPopout(testCase)
            
            % Add multiple section
            sizes = [4 3 5 1];
            section = testCase.addMultiSections(sizes);
            
            % Grab the toolbar section buttons (internal)
            sb = testCase.Widget.SectionButton;
            
            % Sections 1 & 2 should be visible
            testCase.verifyEqual(section(1).Parent, testCase.Widget.Grid)
            testCase.verifyEqual(section(2).Parent, testCase.Widget.Grid)
            testCase.verifyTrue(section(1).Visible)
            testCase.verifyTrue(section(2).Visible)
            testCase.verifyFalse(sb(1).Visible)
            testCase.verifyFalse(sb(2).Visible)
            
            % Section 3 should be hidden by a button (too big)
            testCase.verifyEqual(section(3).Parent, testCase.Widget.Grid)
            testCase.verifyFalse(section(3).Visible)
            testCase.verifyTrue(sb(3).Visible)
            
            % Pop out section 3
            testCase.press(sb(3))
            
            % SectionIsOpen is correct - NO sections open
            expVal = [false false true false]';
            testCase.verifyEqual(testCase.Widget.SectionIsOpen, expVal);
            
            % Section 3 should be popped out below, parented to the figure
            testCase.verifyEqual(section(3).Parent, testCase.Figure)
            testCase.verifyTrue(section(3).Visible)
            testCase.verifyTrue(sb(3).Visible)
            
            % Section 3 popout is positioned below the button
            posS = section(3).Position;
            posB = getpixelposition(sb(3),true);
            yBotB = posB(2);
            yTopS = posS(2) + posS(4);
            testCase.verifyLessThanOrEqual(yTopS, yBotB)
            
            % Section 3 popout is fully within the figure
            figPos = testCase.Figure.Position;
            testCase.verifyLessThan(posS(3), figPos(3))
            testCase.verifyLessThan(posS(4), figPos(4))
            testCase.verifyGreaterThan(posS(1), 0)
            testCase.verifyGreaterThan(posS(2), 0)
            
            % Press the last button in the popout
            button = section(3).Component(end);
            testCase.ButtonPushCallbackDone = false;
            testCase.press(button)
            
            % Verify the callback was fired
            testCase.verifyTrue(testCase.ButtonPushCallbackDone);
            
            % Section 3 should be closed and hidden by button again
            testCase.verifyEqual(section(3).Parent, testCase.Widget.Grid)
            testCase.verifyFalse(section(3).Visible)
            testCase.verifyTrue(sb(3).Visible)
            
            % SectionIsOpen is correct - Section 3 open
            expVal = [false false false false]';
            testCase.verifyEqual(testCase.Widget.SectionIsOpen, expVal);
            
            % Pop out section 3 again
            testCase.press(sb(3))
            
            % SectionIsOpen is correct
            expVal = [false false true false]';
            testCase.verifyEqual(testCase.Widget.SectionIsOpen, expVal);
            
            % Press a button in another section
            button = testCase.Widget.Section(1).Component(1);
            testCase.ButtonPushCallbackDone = false;
            testCase.press(button)
            
            % Verify the callback was fired
            testCase.verifyTrue(testCase.ButtonPushCallbackDone);
            
            % SectionIsOpen is correct - NO sections open
            expVal = [false false false false]';
            testCase.verifyEqual(testCase.Widget.SectionIsOpen, expVal);
            
        end %function
         
    end %methods (Test)
    
end %classdef