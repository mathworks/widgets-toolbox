classdef ProjectIntegrityChecks < matlab.unittest.TestCase
    % Implements a unit test that runs the Project Integrity Checks

    properties(Access = private)
        DoNotRun = verLessThan("MATLAB", "9.9"); %#ok<VERLESSMATLAB> to support running this in < R2020b
    end

    methods(Test)
        function runProjectChecks(testCase)
            % do not continue if DoNotRun is set
            testCase.assumeFalse(testCase.DoNotRun, "Integrity Checks can only be run on R2020b or newer programmatically.")

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
