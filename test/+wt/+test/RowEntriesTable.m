classdef RowEntriesTable < wt.test.BaseWidgetTest
    % Implements a unit test for a widget or component

    % Copyright 2025 The MathWorks, Inc.

    %% Properties
    properties
        InitialData
    end


    %% Class Setup
    methods (TestClassSetup)

        function createFigure(testCase)

            % Call superclass method
            testCase.createFigure@wt.test.BaseWidgetTest();

            % Update the figure size
            testCase.Figure.Position(3:4) = [715, 640];

            % Set up a grid layout
            numRows = 3;
            rowHeight = 200;
            testCase.Grid.RowHeight = repmat({rowHeight},1,numRows);
            numCols = 3;
            colWidth = 225;
            testCase.Grid.ColumnWidth = repmat({colWidth},1,numCols);

        end %function


        function populateInitialData(testCase)

            % Prepare a data table
            testCase.InitialData = cell2table({
                "Apple", 195
                "Banana", 120
                "Lemon", 100
                "Lime", 50
                "Orange", 130
                "Pear", 180
                }, "VariableNames", ["Name","Mass (g)"]);
            
        end %function

    end %methods


    %% Test Method Setup
    methods (TestMethodSetup)

        function setup(testCase)

            isUnsupported = isMATLABReleaseOlderThan("R2022a");
            diag = "Release not supported.";
            testCase.assumeFalse(isUnsupported, diag)

            fcn = @()wt.RowEntriesTable(testCase.Grid);
            testCase.Widget = verifyWarningFree(testCase,fcn);

            % Configure the widget
            testCase.Widget.Tooltip = "Specify the available fruit and average mass of each.";
            testCase.Widget.Orderable = true; % Enables the up/down buttons to reorder items

            % Set callback
            testCase.Widget.ValueChangedFcn = @(s,e)onCallbackTriggered(testCase,e);

            % When the user pushes "add", insert this row
            testCase.Widget.NewRowFormat = {"New Fruit",0};

            % Attach data
            testCase.Widget.Data = testCase.InitialData;

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(0)

            % Ensure it renders
            drawnow

        end %function

    end %methods


    %% Protected methods
    methods (Access = protected)

        function chooseRow(testCase, comp, varargin)
            % Make a custom choose capability to handle older releases

            % If an older release and table, special treatment needed
            if isMATLABReleaseOlderThan("R2022b") && isa(comp, "matlab.ui.control.Table") && isscalar(varargin)
                cell = varargin{1};
                varargin = {[cell; cell(1) 2],"SelectionMode","contiguous"};
            end

            % Call superclass method
            testCase.choose(comp, varargin{:})
            
        end %function

    end %methods


    %% Helper methods
    methods (Access = private)

        function verifyControlData(testCase, expValue)
            % Verifies the dropdown field has the specified value

            import matlab.unittest.constraints.Eventually
            import matlab.unittest.constraints.IsEqualTo

            % Verify values
            testCase.verifyThat(...
                @()testCase.Widget.Table.Data,...
                Eventually(IsEqualTo(expValue), "WithTimeoutOf", 5));

        end %function


        % function verifyControlIndex(testCase, expValue)
        %     % Verifies the dropdown field has the specified value
        % 
        %     import matlab.unittest.constraints.Eventually
        %     import matlab.unittest.constraints.IsEqualTo
        % 
        %     % Verify values
        %     testCase.verifyThat(...
        %         @()testCase.Widget.Index,...
        %         Eventually(IsEqualTo(expValue), "WithTimeoutOf", 5));
        % 
        % end %function


        function verifyDataProperty(testCase, expValue)
            % Verifies the Value property has the specified value

            import matlab.unittest.constraints.Eventually
            import matlab.unittest.constraints.IsEqualTo

            % Verify values
            testCase.verifyThat(...
                @()testCase.Widget.Data,...
                Eventually(IsEqualTo(expValue), "WithTimeoutOf", 5));

        end %function

    end % methods


    %% Unit Tests
    methods (Test)


        function testAddStyle(testCase)

            % Get the controls
            reTable = testCase.Widget.Table;

            % Get initial data
            initData = testCase.InitialData;

            % Prepare a top row showing the mean
            meanMass = mean(initData.("Mass (g)"));
            newData = [
                {"Overall Average", meanMass}
                initData
                ];

            % Update the data
            testCase.verifySetProperty("Data", newData);

            % Prepare the style
            firstRowStyle = uistyle("BackgroundColor",[.8 .9 .8],"FontWeight","bold","FontColor",[.5 0 1]);

            % Call the addStyle method
            fcn = @()addStyle(reTable,firstRowStyle,"row",1);
            testCase.verifyWarningFree(fcn);

            % Verify style applied
            diag = "Expected to see one style configuration applied.";
            sConfig = testCase.Widget.StyleConfigurations;
            testCase.verifySize(sConfig, [1 3], diag);
           

        end %function


        function testDataProperty(testCase)

            % Get initial data
            initData = testCase.InitialData;

            % Verify the data match
            testCase.verifyDataProperty(initData);

            % Set Data and verify
            newData = initData;
            newData(end,:) = {"Pineapple",1234};
            testCase.verifySetProperty("Data", newData);
            testCase.verifyDataProperty(newData);
            testCase.verifyControlData(newData);

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(0)

        end %function


        function testEdits(testCase)

            % Get the controls
            reTable = testCase.Widget.Table;

            % Get initial data
            initData = testCase.InitialData;

            % Verify the data match
            testCase.verifyDataProperty(initData);

            % Type new values
            testCase.type(reTable,[6 1],"Pineapple")
            testCase.type(reTable,[6 2],"1234")

            % Verify the data
            newData = initData;
            newData(end,:) = {"Pineapple",1234};
            testCase.verifyDataProperty(newData);
            testCase.verifyControlData(newData);

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(2)

        end %function


        function testAdd(testCase)

            % Get the controls
            reTable = testCase.Widget.Table;
            addButton = testCase.Widget.AddButton;

            % Get initial data
            initData = testCase.InitialData;

            % Select "Banana"
            testCase.chooseRow(reTable,[2 1])

            % Press add button
            testCase.press(addButton)

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(1)

            % Verify the data match
            newData = [
                initData(1:2,:)
                {"New Fruit", 0}
                initData(3:end,:)
                ];
            testCase.verifyDataProperty(newData);

            % Edit the "New Fruit"
            testCase.type(reTable,[3 1],"Canteloupe")
            testCase.type(reTable,[3 2],"1500")

            % Verify the data match
            newData = [
                initData(1:2,:)
                {"Canteloupe", 1500}
                initData(3:end,:)
                ];
            testCase.verifyDataProperty(newData);

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(3)

        end %function


        function testRemove(testCase)

            % Get the controls
            reTable = testCase.Widget.Table;
            removeButton = testCase.Widget.RemoveButton;

            % Get initial data
            initData = testCase.InitialData;

            % Remove "Banana"
            testCase.chooseRow(reTable,[2 1])
            testCase.press(removeButton)

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(1)

            % Verify the data match
            newData = initData([1 3:end],:);
            testCase.verifyDataProperty(newData);

            % Remove "Lime" and "Orange
            testCase.choose(reTable,[3 1; 4 2])
            testCase.press(removeButton)

            % Verify the data match
            newData = initData([1 3 6],:);
            testCase.verifyDataProperty(newData);

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(2)

        end %function


        function testOrdering(testCase)

            % Get the controls
            reTable = testCase.Widget.Table;
            upButton = testCase.Widget.UpButton;
            downButton = testCase.Widget.DownButton;

            % Get initial data
            initData = testCase.InitialData;

            % Move "Banana" up
            testCase.chooseRow(reTable,[2 1])
            testCase.press(upButton)

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(1)

            % Verify the data match
            newData = initData([2 1 3:end],:);
            testCase.verifyDataProperty(newData);

            % Move "Lemon" to the bottom
            testCase.chooseRow(reTable,[3 1])
            testCase.press(downButton)
            testCase.press(downButton)
            testCase.press(downButton)

            % Verify the data match
            newData = initData([2 1 4 5 6 3],:);
            testCase.verifyDataProperty(newData);

            % Verify number of callbacks so far
            testCase.verifyCallbackCount(4)

        end %function


        function testButtonEnables(testCase)

            % Get the controls
            reTable = testCase.Widget.Table;
            addButton = testCase.Widget.AddButton;
            removeButton = testCase.Widget.RemoveButton;
            upButton = testCase.Widget.UpButton;
            downButton = testCase.Widget.DownButton;

            % Check initial state of button enables
            testCase.verifyEnabled(addButton)
            testCase.verifyNotEnabled(removeButton)
            testCase.verifyNotEnabled(upButton)
            testCase.verifyNotEnabled(downButton)

            % Select first row
            testCase.chooseRow(reTable,[1 1])

            % Check button enables
            testCase.verifyEnabled(addButton)
            testCase.verifyEnabled(removeButton)
            testCase.verifyNotEnabled(upButton)
            testCase.verifyEnabled(downButton)

            % Select a different row
            testCase.chooseRow(reTable,[2 1])

            % Check button enables
            testCase.verifyEnabled(addButton)
            testCase.verifyEnabled(removeButton)
            testCase.verifyEnabled(upButton)
            testCase.verifyEnabled(downButton)

            % Select last row
            testCase.chooseRow(reTable,[6 1])

            % Check button enables
            testCase.verifyEnabled(addButton)
            testCase.verifyEnabled(removeButton)
            testCase.verifyEnabled(upButton)
            testCase.verifyNotEnabled(downButton)

            % Disable ordering of 3 - "Apple"
            testCase.Widget.AllowItemOrdering(1) = false;

            % Select row
            testCase.chooseRow(reTable,[1 1])

            % Check button enables
            testCase.verifyEnabled(addButton)
            testCase.verifyEnabled(removeButton)
            testCase.verifyNotEnabled(upButton)
            testCase.verifyNotEnabled(downButton)


            % Disable remove of 2 - "Banana"
            testCase.Widget.AllowItemRemove(2) = false;

            % Select row
            testCase.chooseRow(reTable,[2 1])

            % Check button enables
            testCase.verifyEnabled(addButton)
            testCase.verifyNotEnabled(removeButton)
            testCase.verifyNotEnabled(upButton) %because Apple can't be ordered
            testCase.verifyEnabled(downButton)

        end %function


        function testOrderableOff(testCase)

            % Get the controls
            reTable = testCase.Widget.Table;
            addButton = testCase.Widget.AddButton;
            removeButton = testCase.Widget.RemoveButton;
            upButton = testCase.Widget.UpButton;
            downButton = testCase.Widget.DownButton;

            % Select second row
            testCase.chooseRow(reTable,[2 1])

            % Check button visibilities
            testCase.verifyVisible(addButton)
            testCase.verifyVisible(removeButton)
            testCase.verifyVisible(upButton)
            testCase.verifyVisible(downButton)

            % Toggle off Orderable
            testCase.verifySetProperty("Orderable",false)

            % Check button enables
            testCase.verifyVisible(addButton)
            testCase.verifyVisible(removeButton)
            testCase.verifyNotVisible(upButton)
            testCase.verifyNotVisible(downButton)

        end %function

    end %methods (Test)

end %classdef

