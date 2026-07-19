function outputFile = packageRelease(projectRoot)
% Package the toolbox release and return the output file path.
%
% Copyright 2026 The MathWorks, Inc.

arguments
    projectRoot (1,1) string {mustBeFolder}
end


% Build the .mltbx using the current deploy version number.
toolboxVersion = wt.deploy.readVersionNumber();
opts = wt.deploy.getPackageOptions(projectRoot, toolboxVersion);
outputFile = opts.OutputFile;
matlab.addons.toolbox.packageToolbox(opts);

end
