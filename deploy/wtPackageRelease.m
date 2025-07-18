% Package a Toolbox Release

% Copyright 2025 The MathWorks, Inc.


%% Increment Version Number?

% Increment the last part of the version number in wtDeployVersion.txt for
% the next release
wt.deploy.incrementVersionNumber();


%% Get paths

% Project root
proj = currentProject;
projectRoot = proj.RootFolder;

docInputPath = fullfile(projectRoot,"widgets","doc");
docOutputPath = fullfile(projectRoot,"widgets","doc");

examplesInputPath = fullfile(projectRoot,"widgets","examples");
examplesOutputPath = fullfile(projectRoot,"widgets","doc");

gettingStartedInputPath = fullfile(projectRoot,"widgets","doc","GettingStarted.mlx");
gettingStartedOutputPath = fullfile(projectRoot,"widgets","doc");


%% Run unit tests
[testSuite, testResult]  = runTestSuite;
if ~all([testResult.Passed])
    error("Unit tests failed. Aborting package release.");
end


%% Publish doc and examples mlx as html

% Find the doc input ".mlx" files
docInputInfo = what(docInputPath);
docInputFiles = docInputInfo.mlx;
docInputFiles = fullfile(docInputPath, docInputFiles);

% Publish these to HTML output
wt.deploy.publishLiveScriptToHtml(docInputFiles, docOutputPath)


%% Publish examples as html

% Find the examples ".mlx" files
examplesInputInfo = what(examplesInputPath);
examplesInputFiles = examplesInputInfo.mlx;
examplesInputFiles = fullfile(examplesInputPath, examplesInputFiles);

% Publish these to HTML output
wt.deploy.publishLiveScriptToHtml(examplesInputFiles, examplesOutputPath)


%% Publish GettingStarted.mlx as html

% Publish to HTML output
wt.deploy.publishLiveScriptToHtml(gettingStartedInputPath, gettingStartedOutputPath)


%% Build search database
% Create v3 for/from R2021a - R2021b
% Create v4 for/from R2022a and later
builddocsearchdb(docOutputPath)


%% Package the Release

% Increment the last part of the version number in version.txt
toolboxVersion = wt.deploy.readVersionNumber();

% Read in the package options
opts = wt.deploy.getPackageOptions(projectRoot, toolboxVersion);
outputFile = opts.OutputFile;

% Perform the packaging
matlab.addons.toolbox.packageToolbox(opts);

% Add the installer to the project
proj.addFile(outputFile)


%% Open the release folder

releaseFolder = fullfile(projectRoot,"release");
winopen(releaseFolder);
