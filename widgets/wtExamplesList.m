function wtExamplesList()
% Opens the examples list

% Copyright 2025 The MathWorks Inc.

% Get the path
listPath = fullfile(wt.utility.widgetsRoot, "doc", "WidgetsList");

% Open the editor file
edit(listPath)