classdef BaseTest < matlab.uitest.TestCase
    % Implements a unit test with some added helper methods
    
    %   Copyright 2020-2025 The MathWorks Inc.
    
    
    %% Protected Helper Methods
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

        
        function verifyEquality(testCase, actualValue, expValue)
            
            if ischar(expValue) || isStringScalar(expValue)
                testCase.verifyTrue( all(strcmp(actualValue, expValue)) );
            elseif isa(actualValue,'matlab.lang.OnOffSwitchState')
                testCase.verifyTrue( all(actualValue == expValue) );
            else
                testCase.verifyEqual(actualValue, expValue);
            end
            
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


        function verifyPixelSize(testCase, component, expSize)
            % Verify the specified component has the specified size

            arguments
                testCase matlab.uitest.TestCase
                component
                expSize (1,2) double
            end

            import matlab.unittest.constraints.Eventually
            import matlab.unittest.constraints.IsEqualTo

            % Verify values
            testCase.verifyThat(...
                @()getPixelSize(component),...
                Eventually(IsEqualTo(expSize), "WithTimeoutOf", 5));
            
            function sz = getPixelSize(comp)

                pos = getpixelposition(comp);
                sz = pos(3:4);

            end

        end %function


        function verifyPropertyValue(testCase, component, property, expValue)
            % Verify the specified component's property eventually is equal
            % to expValue

            arguments
                testCase matlab.uitest.TestCase
                component (1,1) matlab.graphics.Graphics
                property (1,1) string
                expValue
            end

            import matlab.unittest.constraints.*

            % Verify values
            if isStringScalar(expValue)

                constraint = IsEqualTo(expValue,...
                    "Using", StringComparator);

            elseif islogical(expValue)

                constraint = IsEqualTo(expValue,...
                    "Using", LogicalComparator);

            elseif isnumeric(expValue)

                constraint = IsEqualTo(expValue,...
                    "Using", NumericComparator);

            else

                constraint = IsEqualTo(expValue);

            end

            % Perform the verification
            testCase.verifyThat(...
                @()get(component, property),...
                Eventually(constraint, "WithTimeoutOf", 5));
            
        end %function
        
    end %methods
    
end %classdef