function plan = buildfile
% Define maintainer build, test, and release tasks.

% Copyright 2025-2026 The MathWorks, Inc.


% Maintainers run the build in the latest MATLAB release. The packaged
% toolbox output still declares support for MATLAB R2021a and later.
if isMATLABReleaseOlderThan("R2023b")
    error("R2023b or later is required to run Build Tool tasks.")
end


% Prepare the build plan
plan = buildplan(localfunctions);

% Clean task
% plan("clean") = matlab.buildtool.tasks.CleanTask;

% Code issues task
plan("check") = matlab.buildtool.tasks.CodeIssuesTask;
plan("check").SourceFiles = fullfile(plan.RootFolder,"widgets");
plan("check").WarningThreshold = 0;

% Release workflow
plan("prepareRelease").Dependencies = "test";
plan("publishDocHtml").Dependencies = "prepareRelease";
plan("publishExampleHtml").Dependencies = "prepareRelease";
plan("publishGettingStarted").Dependencies = "prepareRelease";
plan("buildDocSearchDb").Dependencies = ...
    ["publishDocHtml","publishExampleHtml","publishGettingStarted"];
plan("package").Dependencies = ["check","buildDocSearchDb"];
plan("finalizeRelease").Dependencies = "package";

% Top-level release aggregation task
plan("archive").Dependencies = "finalizeRelease";

% Set default tasks
plan.DefaultTasks = ["check","test"];

end


function testTask(context)
% Run the release test gate.

rootFolder = string(context.Plan.RootFolder);
ensureProjectLoaded(rootFolder);
wt.deploy.runReleaseTests();

end


function prepareReleaseTask(context)
% Increment the deploy version for the next packaged release.

rootFolder = string(context.Plan.RootFolder);
ensureProjectLoaded(rootFolder);
wt.deploy.incrementVersionNumber();

end


function publishDocHtmlTask(context)
% Publish widgets/doc live scripts to HTML.

rootFolder = string(context.Plan.RootFolder);
ensureProjectLoaded(rootFolder);
wt.deploy.publishReleaseDocumentation(rootFolder);

end


function publishExampleHtmlTask(context)
% Publish widgets/examples live scripts to HTML.

rootFolder = string(context.Plan.RootFolder);
ensureProjectLoaded(rootFolder);
wt.deploy.publishReleaseExamples(rootFolder);

end


function publishGettingStartedTask(context)
% Publish GettingStarted.mlx to HTML.

rootFolder = string(context.Plan.RootFolder);
ensureProjectLoaded(rootFolder);
wt.deploy.publishGettingStartedHtml(rootFolder);

end


function buildDocSearchDbTask(context)
% Rebuild the documentation search database.

rootFolder = string(context.Plan.RootFolder);
ensureProjectLoaded(rootFolder);
wt.deploy.buildDocumentationSearchDb(rootFolder);

end


function packageTask(context)
% Build the .mltbx release artifact.

rootFolder = string(context.Plan.RootFolder);
ensureProjectLoaded(rootFolder);
wt.deploy.packageRelease(rootFolder);

end


function finalizeReleaseTask(context)
% Perform legacy release finalization side effects.

rootFolder = string(context.Plan.RootFolder);
ensureProjectLoaded(rootFolder);
wt.deploy.finalizeRelease(rootFolder);

end


function archiveTask(context)
% Aggregate the full release workflow under a single entry point.

rootFolder = string(context.Plan.RootFolder);
ensureProjectLoaded(rootFolder);

end


function ensureProjectLoaded(rootFolder)
% Open the MATLAB project so deploy helpers and resources are available.

arguments
    rootFolder (1,1) string
end

projectFile = fullfile(rootFolder, "WidgetsToolbox.prj");

try
    project = currentProject;
catch
    project = [];
end

if isempty(project) || string(project.RootFolder) ~= rootFolder
    openProject(projectFile);
end

end
