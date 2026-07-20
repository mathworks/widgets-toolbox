function releaseContext = getReleaseContext(projectRoot)
% Return shared paths and project data for release tasks.
%
% Copyright 2026 The MathWorks, Inc.

arguments
    projectRoot (1,1) string = ""
end


% Resolve the active project when the caller does not provide a root.
project = [];
try
    project = currentProject;
catch
end

if strlength(projectRoot) == 0
    if isempty(project)
        error("wt:deploy:ProjectRequired", ...
            "Open WidgetsToolbox.prj before running release tasks.");
    end
    projectRoot = string(project.RootFolder);
end


% Capture the shared paths used by the release workflow.
releaseContext = struct( ...
    "Project", project, ...
    "ProjectRoot", projectRoot, ...
    "ProjectFile", fullfile(projectRoot, "WidgetsToolbox.prj"), ...
    "DocInputPath", fullfile(projectRoot, "widgets", "doc"), ...
    "DocOutputPath", fullfile(projectRoot, "widgets", "doc"), ...
    "ExamplesInputPath", fullfile(projectRoot, "widgets", "examples"), ...
    "ExamplesOutputPath", fullfile(projectRoot, "widgets", "doc"), ...
    "GettingStartedInputPath", fullfile(projectRoot, "widgets", "doc", "GettingStarted.mlx"), ...
    "GettingStartedOutputPath", fullfile(projectRoot, "widgets", "doc"), ...
    "ReleaseFolder", fullfile(projectRoot, "release"));

end
