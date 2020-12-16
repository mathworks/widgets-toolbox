classdef BaseWidgetTest < matlab.uitest.TestCase
    % Implements a unit test for a widget or component
    
    % Copyright 2020 The MathWorks, Inc.
    
    
    %% Properties
    properties
        Figure
        Grid
        Widget
    end
    
    
    %% Class Setup
    methods (TestClassSetup)
        
        function createFigure(testCase)
            
            testCase.Figure = uifigure('Position',[100 100 300 400]);
            
            % Set up a grid layout
            numRows = 12;
            rowHeight = 25;
            testCase.Grid = uigridlayout(testCase.Figure,[numRows,1]);
            testCase.Grid.Scrollable = true;
            testCase.Grid.RowHeight = repmat({rowHeight},1,numRows);

        end %function
        
    end %methods
    
    
    %% Class Teardown
    methods (TestClassTeardown)
        
        function removeFigure(testCase)
            
            delete(testCase.Figure);
            
        end %function
        
    end %methods
    
    
    %% Helper Methods
    methods (Access = protected)
        
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
        
        
    end %methods
    
end %classdef