classdef ModelObserver < matlab.uitest.TestCase
    % Implements a unit test for a widget or component

    % Copyright 2025 The MathWorks, Inc.


    %% Properties
    properties
        Figure
        Grid
        Widget
        Model1
        Model2
    end

    properties (SetAccess = protected)

        % Listen for ModelObserver events
        ModelSetListener
        ModelChangedListener

        % Track number of ModelObserver events
        ModelSetCount (1,1) double {mustBeInteger, mustBeNonnegative} = 0
        ModelChangedCount (1,1) double {mustBeInteger, mustBeNonnegative} = 0

        % Eventdata of ModelChanged events
        ModelChangedEvents (:,1) wt.eventdata.ModelChangedData

    end %properties


    %% Class Setup
    methods (TestClassSetup)

        function createFigure(testCase)

            % Create a figure
            testCase.Figure = uifigure('Position',[100 100 900 700]);
            testCase.Figure.Name = "Unit Test - " + class(testCase);

            % Set up a grid layout
            testCase.Grid = uigridlayout(testCase.Figure);
            testCase.Grid.BackgroundColor = [0 .8 0];
            testCase.Grid.Scrollable = true;
            testCase.Grid.RowHeight = {'1x','1x','1x'};
            testCase.Grid.ColumnWidth = {'1x','1x','1x'};

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

            % Clear counters
            testCase.ModelSetCount = 0;
            testCase.ModelChangedCount = 0;
            testCase.ModelChangedEvents(:) = [];

            % Launch the view
            fcn = @()wt.example.view.Animal(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            drawnow

            % Listen to ModelObserver events
            testCase.ModelSetListener = listener(...
                testCase.Widget,"ModelSet",...
                @(~,~)testCase.onModelSetEvent());
            testCase.ModelChangedListener = listener(...
                testCase.Widget,"ModelChanged",...
                @(~,evt)testCase.onModelChangedEvent(evt));

            % Create models to display

            model1 = wt.example.model.Animal;
            model1.Species = "Lion";
            model1.Name = "Simba";
            model1.Sex = "male";
            model1.BirthDate = "March 9, 1994";
            testCase.Model1 = model1;

            model2 = wt.example.model.Animal;
            model2.Species = "Lion";
            model2.Name = "Nala";
            model2.Sex = "female";
            model2.BirthDate = "September 13, 1994";
            testCase.Model2 = model2;

        end %function

    end %methods


    %% Helper Methods
    methods (Access = protected)

        function onModelSetEvent(testCase)
            % Callback when a button is pressed

            testCase.ModelSetCount = testCase.ModelSetCount + 1;

        end %function


        function onModelChangedEvent(testCase, evt)
            % Callback when a button is pressed

            testCase.ModelChangedCount = testCase.ModelChangedCount + 1;
            testCase.ModelChangedEvents(end+1) = evt;

        end %function

    end %methods


    %% Test methods
    methods (Test)

        function testModelSetListeners(testCase)
            % This tests:
            %   Basic ModelSet event functionality

            % Get widget component and models
            comp = testCase.Widget;
            model1 = testCase.Model1;
            model2 = testCase.Model2;

            % Assert no model changes yet
            testCase.fatalAssertEqual(testCase.ModelSetCount, 0)
            testCase.fatalAssertEqual(testCase.ModelChangedCount, 0)
            testCase.fatalAssertNumElements(testCase.ModelChangedEvents, 0)

            % Attach model 1
            comp.Model = model1;

            % Verify one set, no change
            testCase.verifyEqual(testCase.ModelSetCount, 1)
            testCase.verifyEqual(testCase.ModelChangedCount, 0)

            % Attach model 2
            comp.Model = model2;

            % Verify model set happened
            testCase.verifyEqual(testCase.ModelSetCount, 2)
            testCase.verifyEqual(testCase.ModelChangedCount, 0)
            testCase.verifyNumElements(testCase.ModelChangedEvents, 0)

            % Attach the same model 2 again
            comp.Model = model2;

            % Verify attaching the same model would AbortSet and not
            % trigger ModelSet event
            testCase.verifyEqual(testCase.ModelSetCount, 2)
            testCase.verifyEqual(testCase.ModelChangedCount, 0)
            testCase.verifyNumElements(testCase.ModelChangedEvents, 0)

        end %function


        function testModelSetEmpty(testCase)
            % This tests:
            %   Setting the model from a populated to empty one

            % Get widget component and models
            comp = testCase.Widget;
            model1 = testCase.Model1;
            % model2 = testCase.Model2;

            % Assert no model changes yet
            testCase.fatalAssertEqual(testCase.ModelSetCount, 0)
            testCase.fatalAssertEqual(testCase.ModelChangedCount, 0)
            testCase.fatalAssertNumElements(testCase.ModelChangedEvents, 0)

            % Attach model 1
            comp.Model = model1;

            % Verify one set, no changes
            testCase.verifyEqual(testCase.ModelSetCount, 1)
            testCase.verifyEqual(testCase.ModelChangedCount, 0)

            % Detach model
            comp.Model(:) = [];

            % Verify deleting the attached model would trigger ModelSet via
            % the ModelObserver's internal ModelDestroyedListener
            testCase.verifyEqual(testCase.ModelSetCount, 2)
            testCase.verifyEqual(testCase.ModelChangedCount, 0)

            % Verify model existance
            testCase.verifyTrue( isvalid(model1) )

        end %function


        function testModelDeleted(testCase)
            % This tests:
            %   Deleting the model being observed

            % Get widget component and models
            comp = testCase.Widget;
            model1 = testCase.Model1;
            % model2 = testCase.Model2;

            % Assert no model changes yet
            testCase.fatalAssertEqual(testCase.ModelSetCount, 0)
            testCase.fatalAssertEqual(testCase.ModelChangedCount, 0)
            testCase.fatalAssertNumElements(testCase.ModelChangedEvents, 0)

            % Attach model 1
            comp.Model = model1;

            % Verify one set, no changes
            testCase.verifyEqual(testCase.ModelSetCount, 1)
            testCase.verifyEqual(testCase.ModelChangedCount, 0)

            % Delete the attached model
            delete(model1)

            % Verify deleting the attached model would trigger ModelSet via
            % the ModelObserver's internal ModelDestroyedListener
            testCase.verifyEqual(testCase.ModelSetCount, 2)
            testCase.verifyEqual(testCase.ModelChangedCount, 0)

            % Verify the view's model was set to empty as a result of being
            % deleted
            testCase.verifyEmpty(comp.Model)

            % Verify model existance
            testCase.verifyFalse( isvalid(model1) )

        end %function


        function testModelChangeEvent(testCase)
            % This tests:
            %   Model change events upon programmatic and interactive
            %   updates

            % Get widget component and models
            comp = testCase.Widget;
            model1 = testCase.Model1;
            model2 = testCase.Model2;

            % Assert no model changes yet
            testCase.fatalAssertEqual(testCase.ModelSetCount, 0)
            testCase.fatalAssertEqual(testCase.ModelChangedCount, 0)
            testCase.fatalAssertNumElements(testCase.ModelChangedEvents, 0)

            % Attach model 1
            comp.Model = model1;

            % Verify sets and changes
            testCase.verifyEqual(testCase.ModelSetCount, 1)
            testCase.verifyEqual(testCase.ModelChangedCount, 0)


            % Change the model programmatically (update expected)
            newDate = model1.BirthDate + days(1);
            model1.BirthDate = newDate;

            % Verify sets and changes
            testCase.verifyEqual(testCase.ModelSetCount, 1)
            testCase.verifyEqual(testCase.ModelChangedCount, 1)


            % Change the model interactively (update expected)
            drawnow
            bdField = comp.BirthDateField;
            newDate = model1.BirthDate + days(1);
            testCase.type(bdField, newDate)

            % Verify sets and changes
            testCase.verifyEqual(testCase.ModelSetCount, 1)
            testCase.verifyEqual(testCase.ModelChangedCount, 2)
            testCase.fatalAssertNumElements(testCase.ModelChangedEvents, 2)

            % Verify event data matches the change
            lastEvent = testCase.ModelChangedEvents(end);
            testCase.verifyEqual(lastEvent.Property, "BirthDate")
            testCase.verifyEqual(lastEvent.Value, newDate)


            % Attach model 2
            comp.Model = model2;

            % Verify sets and changes
            testCase.verifyEqual(testCase.ModelSetCount, 2)
            testCase.verifyEqual(testCase.ModelChangedCount, 2)
            

            % Change model 1 programmatically 
            % (no update expected since not attached)
            newDate = model1.BirthDate + days(1);
            model1.BirthDate = newDate;

            % Verify sets and changes
            testCase.verifyEqual(testCase.ModelSetCount, 2)
            testCase.verifyEqual(testCase.ModelChangedCount, 2)

        end %function


        function testGetScalarModel(testCase)
            % This tests:
            %   Method functionality

            % Get widget component and models
            comp = testCase.Widget;
            model1 = testCase.Model1;
            % model2 = testCase.Model2;

            % Attach model 1
            comp.Model = model1;

            % Get the scalarModel
            [modelOut, validToDisplay] = comp.getScalarModelToDisplay();
            
            % Verify outputs
            testCase.verifyEqual(modelOut, model1)
            expVal = matlab.lang.OnOffSwitchState.on;
            testCase.verifyEqual(validToDisplay, expVal)

            % Delete the model
            delete(model1)

            % Get the scalarModel
            [modelOut, validToDisplay] = comp.getScalarModelToDisplay();
            
            % Verify outputs
            testCase.verifyNotEqual(modelOut, model1)
            testCase.verifyNumElements(modelOut, 1)
            testCase.verifyInstanceOf(modelOut, "wt.example.model.Animal")
            expVal = matlab.lang.OnOffSwitchState.off;
            testCase.verifyEqual(validToDisplay, expVal)

        end %function


        function testConstructDefaultModel(testCase)
            % This tests:
            %   Method functionality

            % Get widget component and models
            comp = testCase.Widget;
            model1 = testCase.Model1;
            % model2 = testCase.Model2;

            % Attach model 1
            comp.Model = model1;

            % Get the scalarModel
            modelOut = comp.constructDefaultModel();
            
            % Verify outputs
            testCase.verifyNotEqual(modelOut, model1)
            testCase.verifyNumElements(modelOut, 1)
            testCase.verifyInstanceOf(modelOut, "wt.example.model.Animal")

        end %function


        function testFieldEditedMethod(testCase)
            % This tests:
            %   The onFieldEdited callback

            % Get widget component and models
            comp = testCase.Widget;
            model1 = testCase.Model1;
            % model2 = testCase.Model2;

            % Attach model 1
            comp.Model = model1;
            drawnow

            % Update the name in the view
            newName = "Mufasa";
            testCase.type(comp.NameField, newName)
            drawnow

            % Verify callback made the change
            testCase.verifyMatches(model1.Name, newName)
            testCase.verifyMatches(comp.NameField.Value, newName)
            
        end %function

    end %methods

end %classdef