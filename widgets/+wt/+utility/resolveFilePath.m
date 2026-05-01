function filePath = resolveFilePath(fileName)
% Searches for a valid path to the specified file name
%
% Order of priority:
%   1. Full path provided
%   2. If deployed, installation folder of the application
%      (e.g. C:\Program Files\...)
%   3. Folder of the calling function, or the first non-namespace folder
%      (@/+) up from the calling function's folder.
%   4. MATLAB path (via "which" command)

%   Copyright 2026 The MathWorks Inc.

arguments
    fileName (1,1) string
end

% Default output
filePath = ""; %#ok<NASGU>


%% Check if a full path was provided already
if strlength( fileparts(fileName) ) > 0

    % If a full path was provided, and it is valid, just use it
    if isfile(fileName)

        filePath = fileName;
        return

    else

        % Throw a warning
        id = "resolvePathFromFileName:BadPath";
        msg = "File was provided with a path that does not exist: %s";
        warning(id, msg, fileName);

        % Return the input as-is
        filePath = fileName;

        return
    end

end %if


%% If deployed, next look in the installation folder
if isdeployed

    % The install folder will be where the executable runs from
    [~, systemPath] = system('set PATH');
    installPath = extractBetween(string(systemPath), "Path=", ";");

    % Check for the file there
    testPath = fullfile(installPath, fileName);
    if isfile(testPath)
        filePath = testPath;
        return
    end

end %if


%% Next, look at the folder containing the calling function

% Get the calling function
stackInfo = dbstack(1,"-completenames");
if ~isempty(stackInfo)

    callingFcn = stackInfo(1).file;
    folderPath = fileparts(callingFcn);

    % Check for the file in the same folder with calling fcn
    testPath = fullfile(folderPath, fileName);
    if isfile(testPath)
        filePath = testPath;
        return
    end

    % If not found, walk up the folder hierarchy for a normal folder
    % (not a + or @ folder)
    % Walk up the folder hierarchy
    [~, leafFolder] = fileparts(folderPath);
    while strlength(leafFolder) && startsWith(leafFolder, {'+', '@'})
        [folderPath, ~] = fileparts(folderPath);
        [~, leafFolder] = fileparts(folderPath);
    end

    % Check for the file in the top folder found
    testPath = fullfile(folderPath, fileName);
    if isfile(testPath)
        filePath = testPath;
        return
    end

end %if


%% Finally, check the MATLAB path
if isfile(fileName)

    % Use WHICH to locate the file
    filePath = which(fileName);
    return

else

    % Unable to find the file. Throw a warning.
    id = "resolvePathFromFileName:NotFound";
    msg = "File not found or does not exist: %s";
    warning(id, msg, fileName);

    % Return the original path
    filePath = fileName;
    return

end %if
