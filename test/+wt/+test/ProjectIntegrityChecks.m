classdef ProjectIntegrityChecks < matlab.unittest.TestCase
    % Implements a unit test that runs the Project Integrity Checks

    %   Copyright 2025-2026 The MathWorks Inc.


    methods(Test)
        function runProjectChecks(testCase)

            % find project root folder based on this file (3 folders up)
            prjFolder = fileparts(fileparts(fileparts(fileparts(mfilename("fullpath")))));
            testCase.applyFixture(matlab.unittest.fixtures.ProjectFixture(prjFolder))

            proj = currentProject();

            updateDependencies(proj);
            checkResults = runChecks(proj);

            % R2026b reports all files as untracked without a JVM. Replace
            % only that check with a query of the real Git index; retain
            % the other checks, including tracked files missing membership.
            replacedCheck = string({checkResults.Description}) == ...
                "All project files are under source control";
            % The available check set varies by release and integration.
            % The Git-based tracking check below always runs.
            checkResults(replacedCheck) = [];

            % Verify checks with useful diagnostic
            for idx = 1:length(checkResults)
                diagnostic = "Failed Integrity Test: '" + checkResults(idx).Description + "'";
                if ~isempty(checkResults(idx).ProblemFiles)
                    diagnostic = diagnostic + newline + "Problem file(s):" + newline + sprintf("- %s\n", checkResults(idx).ProblemFiles);
                end
                testCase.verifyTrue(checkResults(idx).Passed, diagnostic);
            end

            projectFiles = string({proj.Files.Path});
            untrackedFiles = findUntrackedProjectFiles(proj.RootFolder, projectFiles);
            diagnostic = "All project files must be tracked by Git." + ...
                newline + join(untrackedFiles, newline);
            testCase.verifyEmpty(untrackedFiles, diagnostic);

        end


        function testTrackedFileWithSpaces(testCase)

            [rootFolder, files] = createGitFixture(testCase);

            actual = findUntrackedProjectFiles(rootFolder, ...
                [files.Tracked, files.OtherTracked]);

            testCase.verifyEmpty(actual);

        end


        function testUntrackedProjectFile(testCase)

            [rootFolder, files] = createGitFixture(testCase);

            actual = findUntrackedProjectFiles(rootFolder, ...
                [files.Tracked, files.Untracked]);

            testCase.verifyEqual(actual, files.Untracked);

        end


        function testIgnoredProjectFile(testCase)

            [rootFolder, files] = createGitFixture(testCase);

            actual = findUntrackedProjectFiles(rootFolder, files.Ignored);

            testCase.verifyEqual(actual, files.Ignored);

        end


        function testProjectFolderIsNotAFile(testCase)

            [rootFolder, files] = createGitFixture(testCase);

            actual = findUntrackedProjectFiles(rootFolder, ...
                [files.Tracked, files.Folder]);

            testCase.verifyEmpty(actual);

        end


        function testMissingProjectFile(testCase)

            [rootFolder, files] = createGitFixture(testCase);

            actual = findUntrackedProjectFiles(rootFolder, files.Missing);

            testCase.verifyEqual(actual, files.Missing);

        end


        function testGitFailureIsNotSkipped(testCase)

            fixture = testCase.applyFixture( ...
                matlab.unittest.fixtures.TemporaryFolderFixture);
            originalFolder = pwd;

            testCase.verifyError(@()findUntrackedProjectFiles( ...
                fixture.Folder, strings(1,0)), ...
                "wt:test:ProjectIntegrityChecks:GitFailed");
            testCase.verifyEqual(pwd, originalFolder);
            remainingFiles = dir(fixture.Folder);
            testCase.verifyEmpty(remainingFiles(~[remainingFiles.isdir]));

        end


    end

end


function untrackedFiles = findUntrackedProjectFiles(rootFolder, projectFiles)
% Compare project files with the Git index without Java-based status queries.

% Changing folder avoids interpolating paths into a shell command.
originalFolder = pwd;
folderCleanup = onCleanup(@()cd(originalFolder));
cd(rootFolder);

% system's captured output truncates at NUL, so read the Git index as bytes.
indexPath = tempname(rootFolder);
[~, indexName] = fileparts(indexPath);
indexCleanup = onCleanup(@()delete(indexPath));
command = sprintf('git ls-files --cached -z > "%s"', indexName);
[status, output] = system(command);
if status ~= 0
    error("wt:test:ProjectIntegrityChecks:GitFailed", ...
        "Unable to read the Git index (exit code %d): %s", status, output);
end

% NUL-delimited paths preserve whitespace and avoid Git's quoted-path syntax.
indexText = readGitIndex(indexPath);
relativePaths = string(strsplit(indexText, char(0)));
relativePaths(strlength(relativePaths) == 0) = [];
trackedFiles = fullfile(rootFolder, relativePaths);

% Git tracks files, not directories. Missing files still need to be reported.
projectFiles = string(projectFiles);
projectFiles(isfolder(projectFiles)) = [];
projectKeys = projectFiles;
trackedKeys = trackedFiles;
if ispc
    projectKeys = lower(replace(projectKeys, "\", "/"));
    trackedKeys = lower(replace(trackedKeys, "\", "/"));
end
untrackedFiles = projectFiles(~ismember(projectKeys, trackedKeys));


end


function indexText = readGitIndex(indexPath)
% Close the binary file before its caller removes the temporary output.

fileId = fopen(indexPath, 'rb');
assert(fileId ~= -1, "Unable to read the Git index output: %s", indexPath);
fileCleanup = onCleanup(@()fclose(fileId));
indexBytes = fread(fileId, '*uint8');
indexText = native2unicode(indexBytes', 'UTF-8');

end


function [rootFolder, files] = createGitFixture(testCase)
% Create an isolated real Git index for tracking regressions.

fixture = testCase.applyFixture( ...
    matlab.unittest.fixtures.TemporaryFolderFixture);
rootFolder = string(fixture.Folder);
testCase.applyFixture(matlab.unittest.fixtures.CurrentFolderFixture(rootFolder));
[status, output] = system('git init --quiet');
testCase.assertEqual(status, 0, output);

files.Tracked = fullfile(rootFolder, "tracked file with spaces.txt");
files.OtherTracked = fullfile(rootFolder, "another tracked file.txt");
files.Untracked = fullfile(rootFolder, "untracked.txt");
files.Ignored = fullfile(rootFolder, "ignored.txt");
files.Folder = fullfile(rootFolder, "empty folder");
files.Missing = fullfile(rootFolder, "missing.txt");
writeFixtureFile(files.Tracked, "tracked");
writeFixtureFile(files.OtherTracked, "also tracked");
writeFixtureFile(files.Untracked, "untracked");
writeFixtureFile(files.Ignored, "ignored");
writeFixtureFile(fullfile(rootFolder, ".gitignore"), "ignored.txt");
mkdir(files.Folder);
[status, output] = system( ...
    'git add -- "tracked file with spaces.txt" "another tracked file.txt"');
testCase.assertEqual(status, 0, output);

end


function writeFixtureFile(filePath, contents)
% Write neutral fixture data and release its file handle.

fileId = fopen(filePath, 'w');
assert(fileId ~= -1, "Unable to create fixture file: %s", filePath);
fileCleanup = onCleanup(@()fclose(fileId));
fprintf(fileId, '%s\n', contents);

end
