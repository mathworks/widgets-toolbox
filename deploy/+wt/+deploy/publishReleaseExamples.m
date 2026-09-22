function publishReleaseExamples(projectRoot)
% Publish example live scripts to the toolbox documentation folder.
%
% Copyright 2026 The MathWorks, Inc.

arguments
    projectRoot (1,1) string {mustBeFolder}
end


% Publish all live scripts from widgets/examples into widgets/doc.
releaseContext = wt.deploy.getReleaseContext(projectRoot);
examplesInputInfo = what(releaseContext.ExamplesInputPath);
examplesInputFiles = reshape(string(examplesInputInfo.mlx), [], 1);
examplesInputFiles = fullfile(releaseContext.ExamplesInputPath, examplesInputFiles);
wt.deploy.publishLiveScriptToHtml(examplesInputFiles, releaseContext.ExamplesOutputPath);

end
