classdef BaseApp < matlab.uitest.TestCase
    % Implements unit tests for the app class
    
    %% Properties
    properties
        App
        Figure matlab.ui.Figure
        % TempFolder
    end


    %% Test Method Setup
    methods (TestMethodSetup)

        % function prepareTempFolder(testCase)
        %
        %     % Use a temporary folder for sessions
        %     import matlab.unittest.fixtures.TemporaryFolderFixture
        %     fixture = testCase.applyFixture(TemporaryFolderFixture);
        %     testCase.TempFolder = fixture.Folder;
        %
        % end %function

    end %methods


    %% Test Method Teardown
    methods (TestMethodTeardown)
        % Teardown for each test

        function deleteApp(testCase)

            if isscalar(testCase.App) && isvalid(testCase.App)
                if isscalar(testCase.App.Figure)
                    delete(testCase.App.Figure)
                end
                delete(testCase.App)
            end

        end %function

    end %methods


    %% Test methods
    methods (Test)

        function testBaseAppBasicCase(testCase)
            % Verifies behavior of the most basic BaseApp class

            % Launch the app
            diag = "Expected BasicBaseAppSubclass to launch without warnings.";
            fcn = @()wt.test.apps.BasicBaseAppSubclass();
            testCase.App = testCase.verifyWarningFree(fcn, diag);

            % Verify app and component creation
            diag = "Expected BasicBaseAppSubclass figure to be populated.";
            testCase.verifyNotEmpty(testCase.App.Figure, diag)

            diag = "Expected BasicBaseAppSubclass intenral Label to be populated.";
            testCase.verifyNotEmpty(testCase.App.Label, diag)

            % Verify update was run
            diag = "Expected app's label to have changed in the update method.";
            expVal = "Text App - update";
            actVal = testCase.App.Label.Text;
            testCase.verifyMatches(actVal, expVal, diag);

            % Verify app closes
            diag = "Expected app to close without warnings.";
            fcn = @()close(testCase.App);
            testCase.verifyWarningFree(fcn, diag);

            diag = "Expected app to be deleted.";
            testCase.verifyFalse(isvalid(testCase.App), diag)

        end %function

    end %methods

end %classdef