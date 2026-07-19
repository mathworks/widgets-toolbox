function finalizeRelease(projectRoot)
% Add the packaged toolbox to the project and open the release folder.
%
% Copyright 2026 The MathWorks, Inc.

arguments
    projectRoot (1,1) string {mustBeFolder}
end


% Resolve the packaged output file using the current deploy version.
releaseContext = wt.deploy.getReleaseContext(projectRoot);
toolboxVersion = wt.deploy.readVersionNumber();
opts = wt.deploy.getPackageOptions(projectRoot, toolboxVersion);


% Keep the legacy project update behavior for generated installers.
project = releaseContext.Project;
if isempty(project)
    error("wt:deploy:ProjectRequired", ...
        "Open WidgetsToolbox.prj before finalizing the release.");
end
project.addFile(opts.OutputFile);


% Preserve the legacy UI behavior after packaging completes.
winopen(releaseContext.ReleaseFolder);

end
