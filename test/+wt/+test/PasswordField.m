classdef PasswordField < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
%   Copyright 2020-2025 The MathWorks Inc.
    
    
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
            testCase.verifyMatches(passField.Data.Value, newValue);
            
        end %function
        
        
        
        function testTyping(testCase)
        
            % Running in desktop mode?
            testCase.assumeEqual(exist('desktop', 'file'), 6, 'Cannot find function ''desktop.m''.')
            testCase.assumeTrue(desktop('-inuse'), 'MATLAB must run in desktop mode in order to complete current test.')
            
            % Get the password field
            passField = testCase.Widget.PasswordControl;
            newValue = "AbC435!";
            testCase.verifySetProperty("Value", newValue);

            % Allow for some time for the widget and HTML code to catch up
            pause(.5)
            focus(testCase.Widget)
            pause(.5)

            % Type a new value
            newValue = "PasswordABC123";
            simulateTyping(newValue);
            simulateTyping('ENTER')

            % Allow for some time for the widget to catch up
            pause(.5)
            testCase.verifyMatches(passField.Data.Value, newValue);
        
            % Verify callback triggered
            testCase.verifyEqual(testCase.CallbackCount, 1)
        
        end %function
        
    end %methods (Test)
    
end %classdef

function simulateTyping(S)
% Simulate typing actions

% Convert to chars
S = convertStringsToChars(S);

%Initialize the java engine 
import java.awt.*;
import java.awt.event.*;

%Create a Robot-object to do the key-pressing
rob = Robot;

% Request to press ENTER?
if strcmpi(S, 'enter')
    rob.keyPress(KeyEvent.VK_ENTER); 
    rob.keyRelease(KeyEvent.VK_ENTER); 
    return
end

% Execute each letter/number individually
for idx = 1:strlength(S)

    % Get key event ID
    p = ['VK_' upper(S(idx))];

    % For capital letters, press SHIFT
    if ~strcmp(lower(S(idx)), S(idx))
        rob.keyPress(KeyEvent.VK_SHIFT); 
    end

    % Press/release key
    rob.keyPress(KeyEvent.(p))
    rob.keyRelease(KeyEvent.(p))

    % For capital letters, release SHIFT
    if ~strcmp(lower(S(idx)), S(idx))
        rob.keyRelease(KeyEvent.VK_SHIFT); 
    end
end

end