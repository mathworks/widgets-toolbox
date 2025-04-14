function [versionStr, versionParts, versionFile] = readVersionNumber()
% Retrieves the version number
%   Copyright 2025 The MathWorks Inc.

% Version file path
thisPath = mfilename("fullpath");
sourceFolder = fileparts(fileparts(fileparts(thisPath)));
versionFile = fullfile(sourceFolder,"wtDeployVersion.txt");

% Read in the version parts
if isfile(versionFile)
    versionParts = readmatrix(versionFile,...
        "Delimiter",".",...
        "OutputType","uint32");
else
    % Unknown Version
    versionParts = [0 0 0];
end

% Format as string
versionStr = join(string(versionParts),".");