function publishReleaseDocumentation(projectRoot)
% Publish widget documentation live scripts to HTML.
%
% Copyright 2026 The MathWorks, Inc.

arguments
    projectRoot (1,1) string {mustBeFolder}
end


% Publish all live scripts from widgets/doc back into widgets/doc.
releaseContext = wt.deploy.getReleaseContext(projectRoot);
docInputInfo = what(releaseContext.DocInputPath);
docInputFiles = reshape(string(docInputInfo.mlx), [], 1);
docInputFiles = fullfile(releaseContext.DocInputPath, docInputFiles);
wt.deploy.publishLiveScriptToHtml(docInputFiles, releaseContext.DocOutputPath);

end
