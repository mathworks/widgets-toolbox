classdef BaseViewController < matlab.uitest.TestCase
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
            testCase.Figure = uifigure('Position',[100 100 600 450]);
            testCase.Figure.Name = "Unit Test - " + class(testCase);

            % Set up a grid layout
            testCase.Grid = uigridlayout(testCase.Figure);
            testCase.Grid.BackgroundColor = [0 .8 0];
            testCase.Grid.Scrollable = true;
            testCase.Grid.RowHeight = {'1x','1x'};
            testCase.Grid.ColumnWidth = {'1x','1x'};

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
            fcn = @()zooexample.view.Animal(testCase.Grid);
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

            model1 = zooexample.model.Animal;
            model1.Species = "Lion";
            model1.Name = "Simba";
            model1.Sex = "male";
            model1.BirthDate = "March 9, 1994";
            testCase.Model1 = model1;

            model2 = zooexample.model.Animal;
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

        function testPanelContainer(testCase)
            % This tests:
            %   containing OuterPanel functionality

            % Get widget component and models
            comp = testCase.Widget;
            model1 = testCase.Model1;
            % model2 = testCase.Model2;

            % Attach model 1
            comp.Model = model1;
            drawnow
            
            % Verify panel name
            actVal = comp.OuterPanel.Title;
            expVal = 'Animal: Simba';
            testCase.verifyEqual(actVal, expVal)

        end %function


        function testUpdateMethod(testCase)
            % This tests:
            %   The onFieldEdited callback

            % Get widget component and models
            comp = testCase.Widget;
            model1 = testCase.Model1;
            % model2 = testCase.Model2;

            % Attach model 1
            comp.Model = model1;
            drawnow

            % Update the name in the model directly
            newName = "Skar";
            model1.Name = newName;
            drawnow
            
            % Verify callback made the change
            testCase.verifyMatches(model1.Name, newName)
            testCase.verifyMatches(comp.NameField.Value, newName)

        end %function

    end %methods

end %classdef