classdef BaseDialogTest < wt.test.BaseTest
    % Implements a unit test for a widget or component
    
    %   Copyright 2020-2025 The MathWorks Inc.
    
    
    %% Properties
    properties
        Figure
    end
    
    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function createFigure(testCase)

            % Position it off the non-primary monitor if possible
            % This gets it away from the editor when writing tests
            persistent startPos
            if isempty(startPos)
                startPos = findPreferredPosition(testCase);
            end
           
            % Create the figure
            testCase.Figure = uifigure('Position',[startPos 1200 800]);
            testCase.Figure.Name = "Dialog Unit Test - " + class(testCase);

        end %function
        
    end %methods


    %% Test Method Teardown
    methods (TestMethodTeardown)
        
        function removeFigure(testCase)
            
            delete(testCase.Figure);
            
        end %function
        
    end %methods
    
    
    %% Helper Methods
    methods (Access = protected)
        
    end %methods
    
end %classdef