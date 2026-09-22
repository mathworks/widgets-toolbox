function publishGettingStartedHtml(projectRoot)
% Publish the getting started live script to HTML.
%
% Copyright 2026 The MathWorks, Inc.

arguments
    projectRoot (1,1) string {mustBeFolder}
end


% Keep the standalone getting started publish step explicit.
releaseContext = wt.deploy.getReleaseContext(projectRoot);
wt.deploy.publishLiveScriptToHtml( ...
    releaseContext.GettingStartedInputPath, ...
    releaseContext.GettingStartedOutputPath);

end
