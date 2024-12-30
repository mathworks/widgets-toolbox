function varargout = WidgetsZooAppLauncher(varargin)
% Launches the Zoo Hierarchy app

% Copyright 2025 The MathWorks, Inc.


%% Check dependencies
if ~exist("wt.apps.BaseApp","class")
    error("Widgets Toolbox is required to run this app. " + ...
        "Install from Add-Ons browser.");
end


%% Bugfixes



%% Instantiate the application
app = wt.example.app.ZooHierarchy(varargin{:});


%% Import a dataset

% Create a new session
app.newSession();

% Import a data file
dataPath = fullfile(wt.utility.widgetsRoot, "examples", "data", ...
    "ExampleZooManifest.xlsx");


%RJ - this should be a public app method instead! If possible expand the
%tree also!
app.Session.importManifest(dataPath)


%% Configure optional output
if nargout
    varargout = {app};
else
    varargout = {};
end
