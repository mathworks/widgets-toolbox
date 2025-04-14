function varargout = WidgetsZooAppLauncher(varargin)
% Launches the Zoo Hierarchy app

% Copyright 2025 The MathWorks, Inc.


%% Check dependencies
if ~exist("wt.apps.BaseApp","class")
    error("Widgets Toolbox is required to run this app. " + ...
        "Install from Add-Ons browser.");
end


%% Instantiate the application
app = zooexample.app.ZooHierarchy(varargin{:});


%% Import a dataset

% Create a new session
app.newSession();

% Import the sample dataset
dataPath = fullfile(wt.utility.widgetsRoot, "examples", "data", ...
    "ExampleZooManifest.xlsx");
app.Session.importManifest(dataPath)


%% Configure optional output
if nargout
    varargout = {app};
else
    varargout = {};
end
