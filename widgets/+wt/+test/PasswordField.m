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
            
        function testValue(testCase)
            
            % Get the password field
            passField = testCase.Widget.PasswordControl;
            
            % Change the value programmatically
            newValue = "AbC435!";
            testCase.verifySetProperty("Value", newValue);
            testCase.verifyMatches(passField.Data, newValue);
            
            
            %testCase.verifyTypeAction(passField, newValue, "Value");
            % Verify callback triggered
            %testCase.verifyEqual(testCase.CallbackCount, 1)
            
        end %function
            
        
        %RAJ - Unfortunately, can't type in a uihtml
        
        % function testTyping(testCase)
        %
        %     % Get the password field
        %     passField = testCase.Widget.PasswordControl;
        %
        %     % Type a new value
        %     newValue = "PasswordABC123";
        %     testCase.verifyTypeAction(passField, newValue, "Value");
        %     testCase.verifyMatches(passField.Data, newValue);
        %
        %     % Verify callback triggered
        %     testCase.verifyEqual(testCase.CallbackCount, 1)
        %
        % end %function
        
    end %methods (Test)
    
end %classdef