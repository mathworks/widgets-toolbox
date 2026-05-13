function [versionStr, versionParts] = readVersionNumber(filePath)
% Retrieves the version number
%
% Version file should be .txt and only contain a multi-part version with at
% least 2 parts.
% Valid version.txt Examples: 
%   2.4
%   1.0.3
%   1.3.9.2019

%   Copyright 2026 The MathWorks Inc.

arguments (Input)
    filePath (1,1) string {mustBeFile}
end

arguments (Output)
    versionStr (1,1) string
    versionParts (1,:) uint32 {mustBeNonempty}
end

% Read in the version parts
versionParts = readmatrix(filePath,...
    "Delimiter",".",...
    "OutputType","uint32");

% Format as string
versionStr = join(string(versionParts),".");