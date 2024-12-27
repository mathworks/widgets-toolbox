classdef ContextualView < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component
    
    % Copyright 2024 The MathWorks, Inc.
   

    %% Class Setup
    methods (TestClassSetup)
        
        function createFigure(testCase)
            
            % Call superclass method
            testCase.createFigure@wt.test.BaseWidgetTest();
            
            % Make the figure wider
            testCase.Figure.Position([3 4]) = [900 900];
            
            % Modify the grid row height
            testCase.Grid.RowHeight = {'1x','1x'};
            testCase.Grid.ColumnWidth = {'1x','1x'};
            
        end %function
        
    end %methods
    

    %% Test Method Setup
    methods (TestMethodSetup)
        
        function setup(testCase)
            
            fcn = @()wt.ContextualView(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);
            
        end %function
        
    end %methods
    
    
    %% Unit Tests
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
        

        function testBlockWhileLoading(testCase)
            % This tests:
            %   Using prepareToLaunchView
            %   Toggling off the BlockWhileLoading option
            %   Customize the loading image source

            % Verify loading image is off after setup
            diag = "LoadingImage should not be visible after setup";
            val = testCase.Widget.LoadingImage.Visible;
            testCase.verifyFalse(val, diag)

            % Verify loading image source file exists on path
            diag = "LoadingImageSource file must exist on path";
            val = exist(testCase.Widget.LoadingImageSource,"file") == 2;
            testCase.verifyTrue(val, diag)


            % Create a model to display
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

            % Verify loading image is off after setup
            diag = "LoadingImage should not be visible after setup";
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

            

            %   Toggling off the BlockWhileLoading option
            %   Customize the loading image source
            
        end %function
        

        function testDebuggingMethods(testCase)
            % This tests debugging methods:
            %   clearView
            %   relaunchActiveView
            %   reset

            

        end %function
         
    end %methods (Test)

    
end %classdef