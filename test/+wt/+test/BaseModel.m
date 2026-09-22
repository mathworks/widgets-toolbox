classdef BaseModel < matlab.unittest.TestCase
    % Tests for wt.model.BaseModel.

    % Copyright 2026 The MathWorks, Inc.

    properties (Access = private)
        PropertyChangedListener event.listener
        ModelChangedListener event.listener
        PropertyChangedCount (1,1) double {mustBeInteger, mustBeNonnegative} = 0
        ModelChangedCount (1,1) double {mustBeInteger, mustBeNonnegative} = 0
        PropertyChangedEvents (1,:) cell = {}
        ModelChangedEvents (1,:) cell = {}
    end

    methods (TestMethodSetup)
        function resetEventTracking(testCase)
            testCase.PropertyChangedCount = 0;
            testCase.ModelChangedCount = 0;
            testCase.PropertyChangedEvents = {};
            testCase.ModelChangedEvents = {};
            testCase.PropertyChangedListener = event.listener.empty(0,1);
            testCase.ModelChangedListener = event.listener.empty(0,1);
        end
    end

    methods (Test)
        function testConstructorAssignsPropertyValues(testCase)

            model = wt.test.model.SimpleBaseModel("Name","Configured", ...
                "Count",7);

            testCase.verifyEqual(model.Name, "Configured")
            testCase.verifyEqual(model.Count, 7)

        end

        function testDefaultNameUsesSubclassFallback(testCase)

            model = wt.test.model.SimpleBaseModel;

            testCase.verifyEqual(model.Name, "Default Test Model")

        end

        function testObservablePropertyChangeNotifies(testCase)

            model = wt.test.model.SimpleBaseModel;
            testCase.listenToModel(model);

            model.Count = 3;

            testCase.verifyEqual(testCase.PropertyChangedCount, 1)
            testCase.verifyEqual(testCase.ModelChangedCount, 1)
            testCase.verifyPropertyChangedEvent("Count", 3)
            testCase.verifyModelChangedEvent(model, "Count", 3)

        end

        function testDisableChangeListenersSuppressesNotifications(testCase)

            model = wt.test.model.SimpleBaseModel;
            testCase.listenToModel(model);

            model.EnableChangeListeners = false;
            model.Count = 4;

            testCase.verifyEqual(testCase.PropertyChangedCount, 0)
            testCase.verifyEqual(testCase.ModelChangedCount, 0)

        end

        function testAggregatedModelChangePropagates(testCase)

            child = wt.test.model.SimpleBaseModel;
            parent = wt.test.model.AggregatingBaseModel("Child",child);
            testCase.listenToModel(parent);

            child.Count = 8;

            testCase.verifyEqual(testCase.PropertyChangedCount, 0)
            testCase.verifyEqual(testCase.ModelChangedCount, 1)
            testCase.verifyModelChangedEvent(child, "Count", 8)
            testCase.verifyEqual(testCase.ModelChangedEvents{1}.Stack, ...
                {parent, child})

        end

        function testAggregatedModelReassignmentUpdatesListeners(testCase)

            child1 = wt.test.model.SimpleBaseModel;
            child2 = wt.test.model.SimpleBaseModel;
            parent = wt.test.model.AggregatingBaseModel("Child",child1);
            testCase.listenToModel(parent);

            parent.Child = child2;
            child1.Count = 1;
            child2.Count = 2;

            testCase.verifyEqual(testCase.PropertyChangedCount, 1)
            testCase.verifyEqual(testCase.ModelChangedCount, 2)
            testCase.verifyModelChangedEvent(child2, "Count", 2)

        end

        function testCopyDeepCopiesAggregatedModelAndListeners(testCase)

            child = wt.test.model.SimpleBaseModel("Count",2);
            parent = wt.test.model.AggregatingBaseModel("Child",child);
            parentCopy = copy(parent);
            testCase.listenToModel(parentCopy);

            parentCopy.Child.Count = 5;

            testCase.verifyNotEqual(parentCopy, parent)
            testCase.verifyNotEqual(parentCopy.Child, child)
            testCase.verifyEqual(parentCopy.Child.Count, 5)
            testCase.verifyEqual(child.Count, 2)
            testCase.verifyEqual(testCase.ModelChangedCount, 1)
            testCase.verifyModelChangedEvent(parentCopy.Child, "Count", 5)

        end
    end

    methods (Access = private)
        function listenToModel(testCase, model)

            testCase.PropertyChangedListener = listener( ...
                model, "PropertyChanged", ...
                @(~,evt)testCase.onPropertyChanged(evt));
            testCase.ModelChangedListener = listener( ...
                model, "ModelChanged", ...
                @(~,evt)testCase.onModelChanged(evt));

        end

        function onPropertyChanged(testCase, evt)

            testCase.PropertyChangedCount = testCase.PropertyChangedCount + 1;
            testCase.PropertyChangedEvents{end+1} = evt;

        end

        function onModelChanged(testCase, evt)

            testCase.ModelChangedCount = testCase.ModelChangedCount + 1;
            testCase.ModelChangedEvents{end+1} = evt;

        end

        function verifyPropertyChangedEvent(testCase, propertyName, value)

            evt = testCase.PropertyChangedEvents{end};

            testCase.verifyEqual(string(evt.Property), propertyName)
            testCase.verifyEqual(evt.Value, value)

        end

        function verifyModelChangedEvent(testCase, model, propertyName, value)

            evt = testCase.ModelChangedEvents{end};

            testCase.verifyEqual(evt.Model, model)
            testCase.verifyEqual(evt.Property, propertyName)
            testCase.verifyEqual(evt.Value, value)

        end
    end

end
