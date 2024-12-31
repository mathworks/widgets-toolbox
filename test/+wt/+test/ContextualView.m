classdef ContextualView < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
    % Copyright 2024 The MathWorks, Inc.
   

    %% Class Setup
    methods (TestClassSetup)
        
        function createFigure(testCase)
            
            % Call superclass method
            testCase.createFigure@wt.test.BaseWidgetTest();
            
            % Make the figure wider
            testCase.Figure.Position([3 4]) = [1000 1000];
            
            % Modify the grid row height
            testCase.Grid.RowHeight = {'1x','1x','1x'};
            testCase.Grid.ColumnWidth = {'1x','1x','1x'};
            
        end %function
        
    end %methods
    

    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            fcn = @()wt.ContextualView(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            
        end %function
        
    end %methods
    
    
    %% Test methods
    methods (Test)
        
        function testLaunchViewWithModel(testCase)
            % This tests:
            %   Launching the Animal view
            %   Launching the Animal view with a different model

            % Create a model to display
            model1 = wt.example.model.Animal;
            model1.Species = "Lion";
            model1.Name = "Simba";
            model1.Sex = "male";
            model1.BirthDate = "March 9, 1994";

            % Launch the view
            viewClass = "wt.example.view.Animal";
            fcn = @()testCase.Widget.launchView(viewClass, model1);
            view1 = testCase.verifyWarningFree(fcn);


            % Verify the view's parent
            diag = "View's parent must be the ContextualView's internal content grid";
            actVal = view1.Parent;
            expVal = testCase.Widget.ContentGrid;
            testCase.verifyEqual(actVal, expVal, diag)

            % Verify the active view
            diag = "View must be the ContextualView's active view";
            actVal = testCase.Widget.ActiveView;
            expVal = view1;
            testCase.verifyEqual(actVal, expVal, diag)

            % Verify the view is listed in loaded views
            diag = "View must be listed in the ContextualView's loaded views";
            val = any(view1 == testCase.Widget.LoadedViews);
            testCase.verifyTrue(val, diag)

            % Verify the model is attached to view
            diag = "View's model must match the model used in launchView";
            actVal = view1.Model;
            expVal = model1;
            testCase.verifyEqual(actVal, expVal, diag)


            % Create a second model to display
            model2 = wt.example.model.Animal;
            model2.Species = "Lion";
            model2.Name = "Nala";
            model2.Sex = "female";
            model2.BirthDate = "September 13, 1994";

            % Launch the same view with the different model
            viewClass = "wt.example.view.Animal";
            fcn = @()testCase.Widget.launchView(viewClass, model2);
            view1 = testCase.verifyWarningFree(fcn);


            % Verify the model is attached to view
            diag = "View's model must match the model used in launchView";
            actVal = view1.Model;
            expVal = model2;
            testCase.verifyEqual(actVal, expVal, diag)

        end %function
        

        function testChildrenHierarchy(testCase)
            % Verify the children order of the widget
            % - widget itself
            %   - MainGrid
            %       - ContentGrid (views go here)
            %       - LoadingImage (visible gets toggled to cover view)
            %
            % Verify the loading image is off after setup
            % Verify the loading image file is on path

            % Verify MainGrid's parent the widget
            diag = "MainGrid's parent should be the ContextualView widget";
            actVal = testCase.Widget.MainGrid.Parent;
            expVal = testCase.Widget;
            testCase.verifyEqual(actVal, expVal, diag)

            % Verify MainGrid's children order
            diag = "MainGrid's children should be the ContentGrid and LoadingImage in order";
            actVal = testCase.Widget.MainGrid.Children;
            expVal = [
                testCase.Widget.ContentGrid
                testCase.Widget.LoadingImage
                ];
            testCase.verifyEqual(actVal, expVal, diag)

            % Verify loading image is off after setup
            diag = "LoadingImage should not be visible after setup";
            val = testCase.Widget.LoadingImage.Visible;
            testCase.verifyFalse(val, diag)

            % Verify loading image source file exists on path
            diag = "LoadingImageSource file must exist on path";
            val = exist(testCase.Widget.LoadingImageSource,"file") == 2;
            testCase.verifyTrue(val, diag)

        end %function
        

        function testChangingViews(testCase)
            % This tests:
            %   Launching the Animal view
            %   Launching the Enclosure view
            %   Launching the Animal view again
           

            % Create a model to display
            model1 = wt.example.model.Animal;
            model1.Species = "Lion";
            model1.Name = "Simba";
            model1.Sex = "male";
            model1.BirthDate = "March 9, 1994";

            % Launch the view
            viewClass = "wt.example.view.Animal";
            fcn = @()testCase.Widget.launchView(viewClass, model1);
            view1 = testCase.assumeWarningFree(fcn);

            % Assume the model is attached to view
            diag = "View's model must match the model used in launchView";
            actVal = view1.Model;
            expVal = model1;
            testCase.assumeEqual(actVal, expVal, diag)


            % Create a different model to display
            model3 = wt.example.model.Enclosure;
            model3.Name = "Lions' Den";
            model3.Location = [10 20];

            % Launch a different view with the corresponding model
            viewClass = "wt.example.view.Enclosure";
            fcn = @()testCase.Widget.launchView(viewClass, model3);
            view3 = testCase.verifyWarningFree(fcn);

            % Verify the view's parent
            diag = "View's parent must be the ContextualView's internal content grid";
            actVal = view3.Parent;
            expVal = testCase.Widget.ContentGrid;
            testCase.verifyEqual(actVal, expVal, diag)

            % Verify the active view
            diag = "View must be the ContextualView's active view";
            actVal = testCase.Widget.ActiveView;
            expVal = view3;
            testCase.verifyEqual(actVal, expVal, diag)

            % Verify both views are listed in loaded views
            diag = "Both views must be listed in the ContextualView's loaded views";
            val = any(view1 == testCase.Widget.LoadedViews);
            testCase.verifyTrue(val, diag)
            val = any(view3 == testCase.Widget.LoadedViews);
            testCase.verifyTrue(val, diag)

            % Verify the model is attached to view
            diag = "View's model must match the model used in launchView";
            actVal = view3.Model;
            expVal = model3;
            testCase.verifyEqual(actVal, expVal, diag)


            % Launch the original view again
            viewClass = "wt.example.view.Animal";
            fcn = @()testCase.Widget.launchView(viewClass, model1);
            view1b = testCase.verifyWarningFree(fcn);

            % Verify the original view was reused for this instance
            diag = "ContextualView should reuse the original view that was previously loaded";
            actVal = view1b;
            expVal = view1;
            testCase.verifyEqual(actVal, expVal, diag)

            % Verify the view's parent
            diag = "View's parent must be the ContextualView's internal content grid";
            actVal = view1.Parent;
            expVal = testCase.Widget.ContentGrid;
            testCase.verifyEqual(actVal, expVal, diag)

            % Verify the active view
            diag = "View must be the ContextualView's active view";
            actVal = testCase.Widget.ActiveView;
            expVal = view1;
            testCase.verifyEqual(actVal, expVal, diag)

            % Verify the view is listed in loaded views
            diag = "View must be listed in the ContextualView's loaded views";
            val = any(view1 == testCase.Widget.LoadedViews);
            testCase.verifyTrue(val, diag)

            % Verify the model is attached to view
            diag = "View's model must match the model used in launchView";
            actVal = view1.Model;
            expVal = model1;
            testCase.verifyEqual(actVal, expVal, diag)

        end %function
        

        function testBlockWhileLoadingDuringLaunch(testCase)
            % Verify loading image shows when launching a pane

            % Create models to display
            model1 = wt.example.model.Animal;
            model1.Species = "Lion";
            model1.Name = "Simba";
            model1.Sex = "male";
            model1.BirthDate = "March 9, 1994";


            % Prepare to launch the view (turning on the loading image)
            viewClass = "wt.example.view.Animal";
            fcn = @()testCase.Widget.prepareToLaunchView(viewClass);
            testCase.verifyWarningFree(fcn);


            % Verify loading image is on
            diag = "LoadingImage should be visible after prepareToLaunchView";
            actVal = testCase.Widget.LoadingImage.Visible;
            expVal = matlab.lang.OnOffSwitchState.on;
            testCase.verifyEqual(actVal, expVal, diag)


            % Launch the view
            viewClass = "wt.example.view.Animal";
            fcn = @()testCase.Widget.launchView(viewClass, model1);
            view1 = testCase.verifyWarningFree(fcn);

            % Verify loading image is off after launch
            diag = "LoadingImage should not be visible after launch";
            actVal = testCase.Widget.LoadingImage.Visible;
            expVal = matlab.lang.OnOffSwitchState.off;
            testCase.verifyEqual(actVal, expVal, diag)

            % Verify the view's parent
            diag = "View's parent must be the ContextualView's internal content grid";
            actVal = view1.Parent;
            expVal = testCase.Widget.ContentGrid;
            testCase.verifyEqual(actVal, expVal, diag)

            % Verify the active view
            diag = "View must be the ContextualView's active view";
            actVal = testCase.Widget.ActiveView;
            expVal = view1;
            testCase.verifyEqual(actVal, expVal, diag)

        end %function
        

        function testBlockWhileLoadingOff(testCase)
            % This tests:
            %   Using prepareToLaunchView
            %   Toggling off the BlockWhileLoading option
            %   Customize the loading image source

            % Create models to display
            model1 = wt.example.model.Animal;
            model1.Species = "Lion";
            model1.Name = "Simba";
            model1.Sex = "male";
            model1.BirthDate = "March 9, 1994";

            model3 = wt.example.model.Enclosure;
            model3.Name = "Lions' Den";
            model3.Location = [10 20];
            

            % Toggling off the BlockWhileLoading option
            testCase.Widget.BlockWhileLoading = false;

            % Prepare to launch the view (loading image is OFF)
            viewClass = "wt.example.view.Animal";
            fcn = @()testCase.Widget.prepareToLaunchView(viewClass);
            testCase.verifyWarningFree(fcn);

            % Verify loading image is off
            diag = "LoadingImage should not be visible with BlockWhileLoading = false";
            actVal = testCase.Widget.LoadingImage.Visible;
            expVal = matlab.lang.OnOffSwitchState.off;
            testCase.verifyEqual(actVal, expVal, diag)

            % Launch the view
            viewClass = "wt.example.view.Animal";
            fcn = @()testCase.Widget.launchView(viewClass, model1);
            testCase.verifyWarningFree(fcn);

            % Verify loading image is off after launch
            diag = "LoadingImage should not be visible after launch";
            actVal = testCase.Widget.LoadingImage.Visible;
            expVal = matlab.lang.OnOffSwitchState.off;
            testCase.verifyEqual(actVal, expVal, diag)


            % Toggling on the BlockWhileLoading option
            testCase.Widget.BlockWhileLoading = true;

            % Prepare to launch a different view (turning on the loading image)
            viewClass = "wt.example.view.Enclosure";
            fcn = @()testCase.Widget.prepareToLaunchView(viewClass);
            testCase.verifyWarningFree(fcn);

            % Verify loading image is on
            diag = "LoadingImage should be visible after prepareToLaunchView";
            actVal = testCase.Widget.LoadingImage.Visible;
            expVal = matlab.lang.OnOffSwitchState.on;
            testCase.verifyEqual(actVal, expVal, diag)

            % Launch the view
            viewClass = "wt.example.view.Enclosure";
            fcn = @()testCase.Widget.launchView(viewClass, model3);
            testCase.verifyWarningFree(fcn);

        end %function
        

        function testBlockWhileLoadingSwitching(testCase)
            % This tests:
            %   Switching between views and models
            %   Launching a new view or switching them shows the loading
            %   image
            %   Changing model on the same view does not show the loading
            %   image

            % Create models to display
            model1 = wt.example.model.Animal;
            model1.Species = "Lion";
            model1.Name = "Simba";
            model1.Sex = "male";
            model1.BirthDate = "March 9, 1994";

            model3 = wt.example.model.Enclosure;
            model3.Name = "Lions' Den";
            model3.Location = [10 20];


            % Launch the first view
            viewClass = "wt.example.view.Animal";
            fcn = @()testCase.Widget.launchView(viewClass, model1);
            testCase.verifyWarningFree(fcn);


            % Prepare to launch same view (no loading image)
            viewClass = "wt.example.view.Animal";
            fcn = @()testCase.Widget.prepareToLaunchView(viewClass);
            testCase.verifyWarningFree(fcn);

            % Verify loading image is off
            diag = "LoadingImage should not be visible when preparing to load same active view";
            actVal = testCase.Widget.LoadingImage.Visible;
            expVal = matlab.lang.OnOffSwitchState.off;
            testCase.verifyEqual(actVal, expVal, diag)


            % Prepare to launch different view (expect to have loading image)
            viewClass = "wt.example.view.Enclosure";
            fcn = @()testCase.Widget.prepareToLaunchView(viewClass);
            testCase.verifyWarningFree(fcn);

            % Verify loading image is on
            diag = "LoadingImage should be visible after prepareToLaunchView with launching new pane";
            actVal = testCase.Widget.LoadingImage.Visible;
            expVal = matlab.lang.OnOffSwitchState.on;
            testCase.verifyEqual(actVal, expVal, diag)

            % Launch the view
            viewClass = "wt.example.view.Enclosure";
            fcn = @()testCase.Widget.launchView(viewClass, model3);
            testCase.verifyWarningFree(fcn);

            % Verify loading image is off after launch
            diag = "LoadingImage should not be visible after launch";
            actVal = testCase.Widget.LoadingImage.Visible;
            expVal = matlab.lang.OnOffSwitchState.off;
            testCase.verifyEqual(actVal, expVal, diag)
            
        end %function
        

        function testClearView(testCase)
            % This tests debugging methods:
            %   clearView

            % Put the component in a used state
            diag = "Expected launchMultipleViews helper function to put component in desired state.";
            fcn = @()testCase.launchMultipleViews();
            testCase.assumeWarningFree(fcn, diag)
            
            % Clear the view
            diag = "Expected clearView to run without warnings.";
            fcn = @()testCase.Widget.clearView();
            testCase.verifyWarningFree(fcn, diag);

            % Verify no active view
            diag = "Expected ActiveView to be empty";
            actVal = testCase.Widget.ActiveView;
            testCase.verifyEmpty(actVal, diag)

            % Verify ContentGrid children are empty
            diag = "Expected ContentGrid children to be empty";
            actVal = testCase.Widget.ContentGrid.Children;
            testCase.verifyEmpty(actVal, diag)

            % Verify LoadedViews is NOT empty
            diag = "Expected LoadedViews to NOT be empty";
            actVal = testCase.Widget.LoadedViews;
            testCase.verifyNotEmpty(actVal, diag)

        end %function
        

        function testRelaunchActiveView(testCase)
            % This tests debugging methods:
            %   relaunchActiveView

            % Put the component in a used state
            diag = "Expected launchMultipleViews helper function to put component in desired state.";
            fcn = @()testCase.launchMultipleViews();
            testCase.assumeWarningFree(fcn, diag)

            % Get the active view and model
            view3 = testCase.Widget.ActiveView;
            model3 = view3.Model;
            
            % Relaunch the view
            diag = "Expected relaunchActiveView to run without warnings.";
            fcn = @()testCase.Widget.relaunchActiveView();
            testCase.verifyWarningFree(fcn, diag);

            % Get the new active view
            view3A = testCase.Widget.ActiveView;

            % Verify the active view was recreated
            diag = "New active view should not be the same reference as the prior one";
            actVal = view3A;
            expVal = view3;
            testCase.verifyNotEqual(actVal, expVal, diag)

            % Verify the active view's parent
            diag = "View's parent must be the ContextualView's internal content grid";
            actVal = view3A.Parent;
            expVal = testCase.Widget.ContentGrid;
            testCase.verifyEqual(actVal, expVal, diag)

            % Verify the original model is attached to the active view
            diag = "View's model must match the model used in launchView";
            actVal = view3A.Model;
            expVal = model3;
            testCase.verifyEqual(actVal, expVal, diag)
            
            % Verify the active view is listed in loaded views
            diag = "View must be listed in the ContextualView's loaded views";
            val = any(view3A == testCase.Widget.LoadedViews);
            testCase.verifyTrue(val, diag)

            % Verify the old view is NOT listed in loaded views
            diag = "View must be listed in the ContextualView's loaded views";
            val = any(view3 == testCase.Widget.LoadedViews);
            testCase.verifyFalse(val, diag)

        end %function
        

        function testReset(testCase)
            % This tests debugging methods:
            %   reset

            % Put the component in a used state
            diag = "Expected launchMultipleViews helper function to put component in desired state.";
            fcn = @()testCase.launchMultipleViews();
            testCase.assumeWarningFree(fcn, diag)
            
            % Reset the view
            diag = "Expected reset to run without warnings.";
            fcn = @()testCase.Widget.reset();
            testCase.verifyWarningFree(fcn, diag);

            % Verify no active view
            diag = "Expected ActiveView to be empty";
            actVal = testCase.Widget.ActiveView;
            testCase.verifyEmpty(actVal, diag)

            % Verify ContentGrid children are empty
            diag = "Expected ContentGrid children to be empty";
            actVal = testCase.Widget.ContentGrid.Children;
            testCase.verifyEmpty(actVal, diag)

            % Verify LoadedViews is empty
            diag = "Expected LoadedViews to be empty";
            actVal = testCase.Widget.LoadedViews;
            testCase.verifyEmpty(actVal, diag)

        end %function
         
    end %methods (Test)


    %% Helper methods
    methods (Access = protected)
    
        function launchMultipleViews(testCase)
            % Launches multiple views into the component to have it in a
            % used state

            % Create models to display
            model1 = wt.example.model.Animal;
            model1.Species = "Lion";
            model1.Name = "Simba";
            model1.Sex = "male";
            model1.BirthDate = "March 9, 1994";

            model2 = wt.example.model.Animal;
            model2.Species = "Lion";
            model2.Name = "Nala";
            model2.Sex = "female";
            model2.BirthDate = "September 13, 1994";

            model3 = wt.example.model.Enclosure;
            model3.Name = "Lions' Den";
            model3.Location = [10 20];

            % Launch views
            testCase.Widget.launchView("wt.example.view.Animal", model1);
            testCase.Widget.launchView("wt.example.view.Animal", model2);
            testCase.Widget.launchView("wt.example.view.Enclosure", model3);

        end %function

    end %methods
    
end %classdef