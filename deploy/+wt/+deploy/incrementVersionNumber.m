function versionStr = incrementVersionNumber()
% Increments the build number in the version.txt
%   Copyright 2025 The MathWorks Inc.

% Read in the version info
[~, versionParts, versionFile] = wt.deploy.readVersionNumber();

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
writelines(versionStr, versionFile);