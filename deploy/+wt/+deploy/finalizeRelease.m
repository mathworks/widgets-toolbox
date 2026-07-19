function finalizeRelease(projectRoot, outputFile)
% Add the packaged toolbox to the project and open the release folder.
%
% Copyright 2026 The MathWorks, Inc.

arguments
    projectRoot (1,1) string {mustBeFolder}
    outputFile (1,1) string {mustBeFile}
end


% Resolve the release context for project and folder side effects.
releaseContext = wt.deploy.getReleaseContext(projectRoot);


% Keep the legacy project update behavior for generated installers.
project = releaseContext.Project;
if isempty(project)
    error("wt:deploy:ProjectRequired", ...
        "Open WidgetsToolbox.prj before finalizing the release.");
end
project.addFile(outputFile);


% Preserve the legacy UI behavior after packaging completes.
winopen(releaseContext.ReleaseFolder);

end
