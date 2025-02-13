function rootPath = widgetsRoot()
% Returns path to the widgets root folder

% Copyright 2024 The MathWorks Inc.

thisFile = mfilename('fullpath');
removePart = filesep + "+wt" + filesep + wildcardPattern + textBoundary;
rootPath = erase(thisFile, removePart);