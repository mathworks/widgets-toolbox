%% Create a figure
fig = uifigure;
fig.Position = [100 100 360 300];

% Create a grid layout with a light blue background
gridObj = uigridlayout(fig,[4 3]);
gridObj.BackgroundColor = [.6 .8 1];


%% Toolbar

% Create the widget
toolbarWidget = wt.Toolbar(gridObj);
toolbarWidget.Layout.Column = [1 3];
toolbarWidget.Layout.Row = 1;

% Create a horizontal section
section1 = wt.toolbar.HorizontalSection();
section1.Title = "NORMAL BUTTONS";
section1.addButton("open_24.png", "Open");
section1.addButton("save_24.png", "Save");

% Create a horizontal section with vertical subsection
section2 = wt.toolbar.HorizontalSection();
section2.Title = "PLAYBACK";

% Create the vertical subsection
section2v1 = section2.addVerticalSection();
section2v1.addButton("play_24.png","Play");
section2v1.addButton("stop_24.png","Stop");

% Add a manual component to the  vertical section
sliderObj = uislider("Parent",[]);
section2v1.Component(end+1) = sliderObj;

% Attach a callback to the slider
% This is required for manually adding components
sliderObj.ValueChangedFcn = @(h,e)disp(e);

% Create more horizontal items
section2.addButton("left_24.png","");
section2.addButton("pause_24.png","Pause");
section2.addButton("right_24.png","");
section2.ComponentWidth = [75 35 45 35];

% Attach the horizontal sections to the toolbar
toolbarWidget.Section = [
    section1
    section2
    ];


%% Task Status Table

% Create the widget
taskStatusWidget = wt.TaskStatusTable(gridObj);
taskStatusWidget.Layout.Column = 1;
taskStatusWidget.Layout.Row = [2 3];

% Configure the widget
taskStatusWidget.Items = [
    "Import"
    "Preprocess"
    "Analyze"
    "Plot"
    ];
taskStatusWidget.Status = [
    "complete"
    "warning"
    "running"
    "none"
    ];
taskStatusWidget.SelectedIndex = 3;


%% List Selector (single pane)

% Create the widget
listWidget = wt.ListSelector(gridObj);
listWidget.Layout.Column = 2;
listWidget.Layout.Row = 2;

listWidget.Items = ["California","Massachusetts","Michigan","Texas"];
listWidget.Value = listWidget.Items;
listWidget.HighlightedValue = "Michigan";


%% Slider Checkbox Combination Group

% Create the widget
sliderCheckboxWidget = wt.SliderCheckboxGroup(gridObj);
sliderCheckboxWidget.Layout.Column = 3;
sliderCheckboxWidget.Layout.Row = 2;

% Configure the widget
sliderCheckboxWidget.Name = ["Red", "Green", "Blue"];
sliderCheckboxWidget.Value = [0.8, 0.3, 0];
sliderCheckboxWidget.State = [true, true, false];
sliderCheckboxWidget.CheckboxWidth = 51;
sliderCheckboxWidget.RowHeight = 20;


%% Slider Spinner Combination

% Create the widget
sliderSpinnerWidget = wt.SliderSpinner(gridObj);
sliderSpinnerWidget.Layout.Column = [2 3];
sliderSpinnerWidget.Layout.Row = 3;

% Configure the widget
sliderSpinnerWidget.Limits = [-10 30];
sliderSpinnerWidget.RoundFractionalValues = "off";
sliderSpinnerWidget.Step = 0.5;
sliderSpinnerWidget.Value = 16.5;


%% Progress Bar

% Create the widget
progressWidget = wt.ProgressBar(gridObj);
progressWidget.Layout.Column = [1 3];
progressWidget.Layout.Row = 4;

% Configure the widget
progressWidget.ShowCancel = true;

% Start the progress bar
progressWidget.startProgress("The task is starting...");
progressWidget.setProgress(0.5, "The task is running...");



%% Update Layout
gridObj.RowHeight = {85 '1x' 45 35};
gridObj.ColumnWidth = {105 120 '1x'};


%% Save logo

drawnow
exportapp(fig,'widgets_logo.png')
%   Copyright 2025 The MathWorks Inc.