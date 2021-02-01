function [testSuite, result] = runTestSuite()
% Run the test suite

% Copyright 2019-2021 The MathWorks, Inc.


%% Create test suite
testSuite = matlab.unittest.TestSuite.fromProject(currentProject);


%% Run tests
result = testSuite.run();


%% Display Results
ResultTable = result.table();
disp(ResultTable);


%% Did results all pass?
if all([result.Passed])
    disp("All Tests Passed");
else
    warning("widgets:runTestSuite","Not all tests passed. Check results.");
end