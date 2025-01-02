classdef ZooHierarchyApp < matlab.uitest.TestCase
    % Implements unit tests for the zoo hierarchy example app

    %% Properties
    properties
        App wt.example.app.ZooHierarchy
        Figure matlab.ui.Figure
        TempFolder
    end


    %% Test Method Setup
    methods (TestMethodSetup)

        function launchApp(testCase)

            fcn = @()wt.example.app.ZooHierarchy();
            testCase.App = testCase.fatalAssertWarningFree(fcn);
            testCase.Figure = testCase.App.Figure;
            testCase.App.Position(3:4) = [1000 600];

        end %function


        function prepareTempFolder(testCase)

            % Use a temporary folder for sessions
            import matlab.unittest.fixtures.TemporaryFolderFixture
            fixture = testCase.applyFixture(TemporaryFolderFixture);
            testCase.TempFolder = fixture.Folder;

        end %function

    end %methods


    %% Test Method Teardown
    methods (TestMethodTeardown)
        % Teardown for each test

        function deleteApp(testCase)

            delete(testCase.App.Figure)
            delete(testCase.App)

        end %function

    end %methods


    %% Helper Methods
    methods (Access = protected)

        function session = importSampleSession(testCase)
            % Callback when a button is pressed

            % Establish a new session, asserting success
            diag = "Must be able to call newSession without warnings";
            fcn = @()testCase.App.newSession();
            session = testCase.fatalAssertWarningFree(fcn,diag);

            % Assert the session is correct size and type
            className = "wt.example.model.Session";
            diag = "Expected a scalar session object of class " + className;
            testCase.fatalAssertSize(session,[1 1],diag)
            testCase.fatalAssertClass(session,className,diag)

            % Select the session
            diag = "Must be able to call selectSession without warnings";
            fcn = @()testCase.App.selectSession(session);
            testCase.fatalAssertWarningFree(fcn,diag);

            % Define the input file
            dataPath = fullfile(wt.utility.widgetsRoot, "examples", ...
                "data", "ExampleZooManifest.xlsx");

            % Assert the input file exists
            diag = "Input file must exist: " + dataPath;
            cons = matlab.unittest.constraints.IsFile;
            testCase.fatalAssertThat(dataPath, cons, diag)

            % Assert the input file imports successfully
            fcn = @()session.importManifest(dataPath);
            testCase.fatalAssertWarningFree(fcn);

            % Expand some nodes
            % sessionNode = testCase.App.Tree.Children(end);
            % sessionNode.expand();
            % exhibitNodes = sessionNode.Children;
            % exhibitNodes(1).expand();
            %
            % enclosureNodes1 = exhibitNodes(1).Children;
            % enclosureNodes1(1).expand();

        end %function

    end %methods


    %% Test methods
    methods (Test)

        function testInitialStateNoSessions(testCase)
            % Verifies behavior with no sessions loaded

            % Get the app components
            app = testCase.App;
            tree = app.Tree;
            cview = app.ContextualView;

            % Verify app has no sessions
            diag = "Expected app to have no sessions loaded.";
            testCase.verifyEmpty(app.Session, diag)
            diag = "Expected app to have no sessions active.";
            testCase.verifyEmpty(app.SelectedSession, diag)
            testCase.verifyEqual(app.SelectedSessionIndex, [], diag)
            testCase.verifyEqual(app.SelectedSessionName, "", diag)
            testCase.verifyEqual(app.SelectedSessionPath, "", diag)

            % Verify app is clean
            diag = "Expected app to be clean with no sessions loaded.";
            testCase.verifyFalse(app.Dirty, diag)

            % Verify empty tree
            diag = "Expected empty tree with no sessions loaded.";
            testCase.verifyEmpty(tree.Children, diag)

            % Verify empty view
            diag = "Expected empty ContextualView's ActiveView with no sessions loaded.";
            testCase.verifyEmpty(cview.ActiveView, diag)

        end %function


        function testStateAfterAllSessionsClosed(testCase)
            % Verifies behavior with no sessions loaded

            % Get the app components
            app = testCase.App;
            tree = app.Tree;
            cview = app.ContextualView;

            % Import the sample dataset
            session1 = testCase.importSampleSession();

            % Choose an enclosure node
            enclosure1Node = tree.Children(1).Children(1).Children(1);
            testCase.choose(enclosure1Node);

            % Mark the session clean
            session1.Dirty = false;

            % Close the session
            app.closeSession(session1);

            % Verify app has no sessions
            diag = "Expected app to have no sessions loaded.";
            testCase.verifyEmpty(app.Session, diag)
            diag = "Expected app to have no sessions active.";
            testCase.verifyEmpty(app.SelectedSession, diag)
            testCase.verifyEqual(app.SelectedSessionIndex, [], diag)
            testCase.verifyEqual(app.SelectedSessionName, "", diag)
            testCase.verifyEqual(app.SelectedSessionPath, "", diag)

            % Verify app is clean
            diag = "Expected app to be clean with no sessions loaded.";
            testCase.verifyFalse(app.Dirty, diag)

            % Verify empty tree
            diag = "Expected empty tree with no sessions loaded.";
            testCase.verifyEmpty(tree.Children, diag)

            % Verify empty view
            diag = "Expected empty ContextualView's ActiveView with no sessions loaded.";
            testCase.verifyEmpty(cview.ActiveView, diag)

        end %function


        function testSaveLoadSession(testCase)
            % Verifies that we can save a modified session, load it back
            % in, and the changes persist

            % Import the sample dataset
            session1 = testCase.importSampleSession();

            % Get the app components
            app = testCase.App;
            tree = app.Tree;
            cview = app.ContextualView;

            % Choose an animal node
            animal1Node = tree.Children(end).Children(1).Children(1).Children(1);
            testCase.choose(animal1Node);

            % Find the animal view
            view = cview.ActiveView;

            % Find and verify the correct model
            diag = "Expected the view/controller model to be the expected model from the session.";
            actVal = view.Model;
            expVal = session1.Exhibit(1).Enclosure(1).Animal(1);
            testCase.verifyEqual(actVal, expVal, diag)

            % Set the Name
            newName = "Valerie";
            testCase.type(view.NameField, newName);

            % Verify the model was updated
            diag = "Expected the model to match the value that was set in the controller";
            actVal = view.Model.Name;
            testCase.verifyMatches(actVal, newName, diag)

            % Make temp file names for sessions
            tempFile1 = fullfile(testCase.TempFolder, "Session1.mat");

            % Save the session
            % need to do it from session directly to bypass dialogs
            session1.save(tempFile1);

            % Close the current session
            session1.Dirty = false;
            app.closeSession(session1);

            % Load the saved session and select it
            session1 = app.loadSession(tempFile1);
            app.selectSession(session1);

            % Verify name in loaded session matches
            diag = "Expected updated name to persist through save/load session.";
            actVal = session1.Exhibit(1).Enclosure(1).Animal(1).Name;
            testCase.verifyMatches(actVal, newName, diag);

            % Find the same animal node
            animal1Node = tree.Children(end).Children(1).Children(1).Children(1);
            testCase.choose(animal1Node);

            % Find the animal view
            view = cview.ActiveView;

            % Verify name in view matches
            diag = "Expected updated name to display in the view after loading.";
            actVal = view.NameField.Value;
            testCase.verifyMatches(actVal, newName, diag);

        end %function



        function testMultipleSessionsDirtyStates(testCase)
            % Verifies that we can load in multiple sessions

            % Import the sample dataset
            session1 = testCase.importSampleSession();

            % Get the app components
            app = testCase.App;
            tree = app.Tree;
            cview = app.ContextualView;

            % Make another session - this one blank
            diag = "Must be able to call newSession without warnings";
            fcn = @()testCase.App.newSession();
            session2 = testCase.verifyWarningFree(fcn,diag);

            % Import the sample dataset again in 3rd session
            session3 = testCase.importSampleSession();

            % Make temp file names for sessions
            tempFile1 = fullfile(testCase.TempFolder, "Session1.mat");
            tempFile2 = fullfile(testCase.TempFolder, "Session2.mat");
            tempFile3 = fullfile(testCase.TempFolder, "Session3.mat");

            % Verify session dirty states
            diag = "Expected the default created session to return clean state.";
            testCase.verifyFalse(session2.Dirty, diag)
            diag = "Expected the imported sessions to return dirty state.";
            testCase.verifyTrue(session1.Dirty, diag)
            testCase.verifyTrue(session3.Dirty, diag)
            testCase.verifyTrue(app.Dirty, diag)

            % Save all sessions
            % need to do it from session directly to bypass dialogs
            session1.save(tempFile1);
            session2.save(tempFile2);
            session3.save(tempFile3);

            % Verify sessions are clean
            diag = "Expected no sessions to be dirty after save.";
            testCase.verifyFalse(session1.Dirty, diag)
            testCase.verifyFalse(session2.Dirty, diag)
            testCase.verifyFalse(session3.Dirty, diag)
            testCase.verifyFalse(app.Dirty, diag)


            % --- Dirty a session ---

            % Choose an exhibit node
            exhibitEndNode = tree.Children(end).Children(end);
            testCase.choose(exhibitEndNode);

            % Find the view
            view = cview.ActiveView;

            % Find and verify the correct model
            diag = "Expected the view/controller model to be the expected model from the session.";
            actVal = view.Model;
            expVal = session3.Exhibit(end);
            testCase.verifyEqual(actVal, expVal, diag)

            % Set the name
            newName = "The Landing Zone";
            testCase.type(view.NameField, newName);

            % Verify the model was updated
            diag = "Expected the model to match the value that was set in the controller";
            actVal = view.Model.Name;
            testCase.verifyMatches(actVal, newName, diag)

            % Verify the modified session is dirty
            diag = "Expected the third session to be dirty, others clean.";
            testCase.verifyFalse(session1.Dirty, diag)
            testCase.verifyFalse(session2.Dirty, diag)
            testCase.verifyTrue(session3.Dirty, diag)
            testCase.verifyTrue(app.Dirty, diag)

            % Save the dirty session
            session3.save(tempFile3);

            % Verify sessions are clean
            diag = "Expected no sessions to be dirty after save.";
            testCase.verifyFalse(session1.Dirty, diag)
            testCase.verifyFalse(session2.Dirty, diag)
            testCase.verifyFalse(session3.Dirty, diag)
            testCase.verifyFalse(app.Dirty, diag)

        end %function

    end %methods

end %classdef