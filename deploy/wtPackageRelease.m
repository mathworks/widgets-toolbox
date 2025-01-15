% Package a Toolbox Release

% Copyright 2025 The MathWorks, Inc.


%% Get paths

% Project root
proj = currentProject;
projectRoot = proj.RootFolder;


%% Run unit tests
[testSuite, testResult]  = runTestSuite;
if ~all([testResult.Passed])
    error("Unit tests failed. Aborting package release.");
end


%% Increment Version Number

% Increment the last part of the version number in wtDeployVersion.txt
% (Other changes require commenting this out and making manual edits)
wt.deploy.incrementVersionNumber();


%% Package the Release

% Increment the last part of the version number in version.txt
toolboxVersion = wt.deploy.readVersionNumber();

% Read in the package options
opts = wt.deploy.getPackageOptions(projectRoot, toolboxVersion);
outputFile = opts.OutputFile;

% Perform the packaging
matlab.addons.toolbox.packageToolbox(opts);


%% Open the release folder

releaseFolder = fullfile(projectRoot,"release");
winopen(releaseFolder);
