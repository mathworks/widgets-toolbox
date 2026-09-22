function buildDocumentationSearchDb(projectRoot)
% Build the documentation search database for the release docs.
%
% Copyright 2026 The MathWorks, Inc.

arguments
    projectRoot (1,1) string {mustBeFolder}
end


% The search database is built in the maintainer MATLAB release.
releaseContext = wt.deploy.getReleaseContext(projectRoot);
builddocsearchdb(releaseContext.DocOutputPath);

end
