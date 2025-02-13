function examplePath = wtExamplesFolder()
% Opens the examples folder

% Copyright 2025 The MathWorks Inc.

% Get the paths
examplePath = fullfile(wt.utility.widgetsRoot, "examples");

% Change to the examples folder
cd(examplePath);