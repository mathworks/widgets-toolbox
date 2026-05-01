function versionStr = incrementVersionNumber(filePath)
% Increments the last decimal of the version number
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
end

% Read in the version info
[~, versionParts] = wt.utility.readVersionNumber(filePath);

% Increment the build index in the version number
numVersionParts = numel(versionParts);
if numVersionParts < 2
    versionParts(2) = uint32(1);
else
    versionParts(end) = versionParts(end) + uint32(1);
end

% Format as string
versionStr = join(string(versionParts),".");

% Update the version file
writelines(versionStr, filePath);