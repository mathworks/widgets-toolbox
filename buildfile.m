function plan = buildfile
% Perform build, test, and package actions

% Copyright 2025 The MathWorks, Inc.


% These tasks require R2023b or later
if isMATLABReleaseOlderThan("R2023b")
    error("R2023b or later is required for build tools.")
end


% Prepare the build plan
plan = buildplan(localfunctions);

% Clean task
% plan("clean") = matlab.buildtool.tasks.CleanTask;

% Code issues task
plan("check") = matlab.buildtool.tasks.CodeIssuesTask;
plan("check").SourceFiles = fullfile(plan.RootFolder,"widgets");
plan("check").WarningThreshold = 0;

% Test task
plan("test") = matlab.buildtool.tasks.TestTask;
plan("test").SourceFiles = fullfile(plan.RootFolder,"test");

% Package task
plan("archive").Dependencies = ["check","test"];

% Set default tasks
plan.DefaultTasks = ["check","test"];

end %function


function archiveTask(context)
% Package the mltbx file

% Get root
rootFolder = context.Plan.RootFolder;

% Increment the last part of the version number in wtDeployVersion.txt
% (Other changes require commenting this out and making manual edits)
wt.deploy.incrementVersionNumber();

% Increment the last part of the version number in version.txt
toolboxVersion = wt.deploy.readVersionNumber();

% Read in the package options
opts = wt.deploy.getPackageOptions(rootFolder, toolboxVersion);

% Perform the packaging
matlab.addons.toolbox.packageToolbox(opts);

% Open the release folder
releaseFolder = fullfile(rootFolder,"release");
winopen(releaseFolder);

end %function