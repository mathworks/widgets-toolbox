classdef ProjectIntegrityChecks < matlab.unittest.TestCase
    % Implements a unit test that runs the Project Integrity Checks


    methods(Test)
        function runProjectChecks(testCase)

            % find project root folder based on this file (3 folders up)
            prjFolder = fileparts(fileparts(fileparts(fileparts(mfilename("fullpath")))));
            testCase.applyFixture(matlab.unittest.fixtures.ProjectFixture(prjFolder))

            proj = currentProject();

            updateDependencies(proj);
            checkResults = runChecks(proj);

            % Verify checks with useful diagnostic
            for idx = 1:length(checkResults)
                diagnostic = "Failed Integrity Test: '" + checkResults(idx).Description + "'";
                if ~isempty(checkResults(idx).ProblemFiles)
                    diagnostic = diagnostic + newline + "Problem file(s):" + newline + sprintf("- %s\n", checkResults(idx).ProblemFiles);
                end
                testCase.verifyTrue(checkResults(idx).Passed, diagnostic);
            end

        end
    end

end
