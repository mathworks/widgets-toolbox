classdef BaseWidgetTest < wt.test.BaseTest
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
            % drawnow
            
            % Verify new property value
            % actualValue = testCase.Widget.(propName);
            % testCase.verifyEquality(actualValue, expValue);
            testCase.verifyPropertyValue(testCase.Widget, propName, expValue);
            
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
        
        
        function verifyTypeAction(testCase,component,newValue,propName,expValue)
            
            % If no expected new value after set was given, assume it
            % matches the newValue provided as usual
            if nargin < 5
                expValue = newValue;
            end
            
            % Type the new value into the control
            testCase.type(component, newValue);
            
            % Verify new property value
            % actualValue = testCase.Widget.(propName);
            % testCase.verifyEquality(actualValue, expValue);

            testCase.verifyPropertyValue(component, propName, expValue);

            
            
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
        
    end %methods
    
end %classdef