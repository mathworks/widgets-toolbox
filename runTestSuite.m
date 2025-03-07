function [testSuite, result] = runTestSuite()
% Run the test suite

%   Copyright 2019-2025 The MathWorks Inc.


%% Create test suite
testSuite = matlab.unittest.TestSuite.fromPackage('wt.test');


%% Run tests
result = testSuite.run();


%% Display Results
ResultTable = result.table();
disp(ResultTable);


%% Did results all pass?
if all([result.Passed])
    disp("All Tests Passed");
elseif any([result.Failed])
    warning("widgets:runTestSuite:Failed","*** Failed Tests. Check Results. ***");
elseif any([result.Incomplete])
    warning("widgets:runTestSuite:Incomplete","*** Some Tests Incomplete. Check Results. ***");
end