function [testSuite, testResult] = runReleaseTests()
% Run the release test gate using the legacy test suite entry point.
%
% Copyright 2026 The MathWorks, Inc.


% Keep the legacy release test selection and reporting behavior.
[testSuite, testResult] = runTestSuite();


% Abort the release if any test did not pass.
if ~all([testResult.Passed])
    error("wt:deploy:ReleaseTestsFailed", ...
        "Unit tests failed. Aborting package release.");
end

end
