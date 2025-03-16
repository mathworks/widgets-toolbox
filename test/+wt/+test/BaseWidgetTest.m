classdef BaseWidgetTest < matlab.uitest.TestCase
    % Implements a unit test for a widget or component
    
%   Copyright 2020-2025 The MathWorks Inc.
    
    
    %% Properties
    properties
        Figure
        Grid
        Widget
    end
    
    
    %% Properties
    properties (SetAccess = protected)
        
        % Test can trigger this when ButtonPressedFcn is fired by toolbar
        CallbackCount (1,1) double {mustBeInteger, mustBeNonnegative} = 0
        
        % Eventdata of button pushes
        CallbackEvents (:,1) %wt.eventdata.ButtonPushedData
        
    end %properties
    
    
    %% Class Setup
    methods (TestClassSetup)
        
        function createFigure(testCase)

            % Position it off the non-primary monitor if possible
            % This gets it away from the editor when writing tests
            persistent startPos
            if isempty(startPos)
                startPos = findPreferredPosition(testCase);
            end
           
            % Create the figure
            testCase.Figure = uifigure('Position',[startPos 600 600]);
            testCase.Figure.Name = "Unit Test - " + class(testCase);
            
            % Set up a grid layout
            numRows = 10;
            rowHeight = 50;
            testCase.Grid = uigridlayout(testCase.Figure,[numRows,1]);
            testCase.Grid.Scrollable = true;
            testCase.Grid.RowHeight = repmat({rowHeight},1,numRows);
            testCase.Grid.BackgroundColor = [0 .8 0];

        end %function
        
    end %methods
    
    
    %% Class Teardown
    methods (TestClassTeardown)
        
        function removeFigure(testCase)
            
            delete(testCase.Figure);
            
        end %function
        
    end %methods
    
    
    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            % Reset callback counter for each test
            testCase.CallbackCount = 0;
            testCase.CallbackEvents(:) = [];
            
        end %function
        
    end %methods
    
    
    %% Helper Methods
    methods (Access = protected)
        
        function pos = findPreferredPosition(~)
            % Callback when a button is pressed

            % Position it off the non-primary monitor if possible
            % This gets it away from the editor when writing tests
            monitorPositions = get(0, 'MonitorPositions');

            if isempty(monitorPositions)
                
                % Shouldn't happen, but just in case
                % Leave space for taskbar
                pos = [1 100];
                
            elseif size(monitorPositions,1) == 1

                % Primary monitor
                monIdx = 1;

                % Get position
                % Leave space for taskbar
                pos = monitorPositions(monIdx, 1:2) + [1 100];

            else
                % Secondary monitors available

                % Find the primary monitor
                isPrimary = all(monitorPositions(:,1:2) == [1 1], 2);

                % If multiple non-primary, choose the last one
                monIdx = find(~isPrimary,1,'last');

                % If none found, revert to the primary
                if isempty(monIdx)
                    monIdx = 1;
                end

                % Use the lower-left corner of the selected monitor
                % Leave space for taskbar

                % Get position
                pos = monitorPositions(monIdx, 1:2) + [1 100];

            end %if
            
        end %function

        
        function assumeMinimumRelease(testCase, releaseName)
            % Callback when a button is pressed
            
            isUnsupported = isMATLABReleaseOlderThan(releaseName);
            diag = "Release not supported.";
            testCase.assumeFalse(isUnsupported, diag)
            
        end %function

        
        function onCallbackTriggered(testCase, evt)
            % Callback when a button is pressed
            
            testCase.CallbackCount = testCase.CallbackCount + 1;
            if testCase.CallbackCount > 1
                testCase.CallbackEvents(end+1) = evt;
            else
                testCase.CallbackEvents = evt;
            end
            
        end %function
        
        
        function verifySetProperty(testCase,propName,newValue,expValue)
            
            % If no expected new value after set was given, assume it
            % matches the newValue provided as usual
            if nargin < 4
                expValue = newValue;
            end
            
            % Verify the set produces no warning or error
            fcn = @()set(testCase.Widget, propName, newValue);
            testCase.verifyWarningFree(fcn);
            
            % Give a moment for update to run
            drawnow
            
            % Verify new property value
            actualValue = testCase.Widget.(propName);
            testCase.verifyEquality(actualValue, expValue);
            
        end %function
        
        
        function verifySetPropertyError(testCase,propName,newValue,errorId)
            
            % Get the old value
            expValue = testCase.Widget.(propName);
            
            % Verify the set produces an error
            fcn = @()set(testCase.Widget, propName, newValue);
            testCase.verifyError(fcn, errorId);
            
            % Verify new property value did not change
            actualValue = testCase.Widget.(propName);
            testCase.verifyEquality(actualValue, expValue);
            
        end %function
        
        
        function verifyTypeAction(testCase,control,newValue,propName,expValue)
            
            % If no expected new value after set was given, assume it
            % matches the newValue provided as usual
            if nargin < 5
                expValue = newValue;
            end
            
            % Type the new value into the control
            testCase.type(control, newValue);
            
            % Verify new property value
            actualValue = testCase.Widget.(propName);
            testCase.verifyEquality(actualValue, expValue);
            
        end %function
        
        
        function verifyEquality(testCase, actualValue, expValue)
            
            if ischar(expValue) || isStringScalar(expValue)
                testCase.verifyTrue( all(strcmp(actualValue, expValue)) );
            elseif isa(actualValue,'matlab.lang.OnOffSwitchState')
                testCase.verifyTrue( all(actualValue == expValue) );
            else
                testCase.verifyEqual(actualValue, expValue);
            end
            
        end %function
        
        
        function verifyMethod(testCase, fcn, varargin)
            % Verify a method call on the widget
            
            if ~isa(fcn,'function_handle')
                fcn = str2func(fcn);
            end
            fcn_send = @()fcn(testCase.Widget, varargin{:});
            testCase.verifyWarningFree(fcn_send);

            % Give a moment for update to run
            drawnow
            
        end %function
        
        
        function verifyCallbackCount(testCase, expValue)
            % Verify the number of callbacks that have executed
            
            actValue = testCase.CallbackCount;
            diag = sprintf("Expected %d callbacks to have executed " + ...
                "at this point, but actual is %d.", expValue, actValue);
            testCase.verifyEqual(actValue, expValue, diag)
            
        end %function
        
        
        function verifyVisible(testCase, component)
            % Verify the specified component is set to visible

            arguments
                testCase matlab.uitest.TestCase
                component
            end

            import matlab.unittest.constraints.Eventually
            import matlab.unittest.constraints.IsTrue

            % Verify values
            testCase.verifyThat(...
                @()logical(component.Visible),...
                Eventually(IsTrue, "WithTimeoutOf", 5));
            
        end %function
        
        
        function verifyNotVisible(testCase, component)
            % Verify the specified component is set to not visible

            arguments
                testCase matlab.uitest.TestCase
                component
            end

            import matlab.unittest.constraints.Eventually
            import matlab.unittest.constraints.IsFalse

            % Verify values
            testCase.verifyThat(...
                @()logical(component.Visible),...
                Eventually(IsFalse, "WithTimeoutOf", 5));
            
        end %function
        
        
        function verifyEnabled(testCase, component)
            % Verify the specified component is set to enabled

            arguments
                testCase matlab.uitest.TestCase
                component
            end

            import matlab.unittest.constraints.Eventually
            import matlab.unittest.constraints.IsTrue

            % Verify values
            testCase.verifyThat(...
                @()logical(component.Enable),...
                Eventually(IsTrue, "WithTimeoutOf", 5));
            
        end %function
        
        
        function verifyNotEnabled(testCase, component)
            % Verify the specified component is set to not enabled

            arguments
                testCase matlab.uitest.TestCase
                component
            end

            import matlab.unittest.constraints.Eventually
            import matlab.unittest.constraints.IsFalse

            % Verify values
            testCase.verifyThat(...
                @()logical(component.Enable),...
                Eventually(IsFalse, "WithTimeoutOf", 5));
            
        end %function
        
    end %methods
    
end %classdef