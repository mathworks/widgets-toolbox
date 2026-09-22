% Package a Toolbox Release
%
% Preferred maintainer entry point: buildtool archive

% Copyright 2025-2026 The MathWorks, Inc.


%% Open project and run the Build Tool release workflow

projectRoot = fileparts(fileparts(mfilename("fullpath")));
openProject(fullfile(projectRoot,"WidgetsToolbox.prj"));
buildtool("archive");
