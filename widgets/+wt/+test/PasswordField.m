classdef PasswordField < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
    % Copyright 2020 The MathWorks, Inc.
    
    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            fcn = @()wt.PasswordField(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            
            % Set callback
            testCase.Widget.ValueChangedFcn = @(s,e)onCallbackTriggered(testCase,e);
            
            % Ensure it renders
            drawnow
            
        end %function
        
    end %methods
    
    
    %% Unit Tests
    methods (Test)
            
        function testEditing(testCase)
        
        end %function
        
    end %methods (Test)
    
end %classdef