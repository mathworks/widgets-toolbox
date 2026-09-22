classdef ThemeCompatibility < matlab.unittest.TestCase
    % Tests for UI theme compatibility helpers.

    % Copyright 2026 The MathWorks, Inc.

    methods (Test)
        function testSupportsUIThemesReturnsLogicalScalar(testCase)

            isSupported = wt.utility.supportsUIThemes();

            testCase.verifyClass(isSupported, "logical")
            testCase.verifySize(isSupported, [1 1])

        end

        function testGetThemeColorReturnsRgbTriplet(testCase)

            testCase.assumeTrue(wt.utility.supportsUIThemes())

            fig = uifigure("Visible","off");
            testCase.addTeardown(@()delete(fig))

            color = wt.utility.getThemeColor(fig.Theme, "--mw-color-primary");

            testCase.verifyClass(color, "double")
            testCase.verifySize(color, [1 3])
            testCase.verifyGreaterThanOrEqual(color, 0)
            testCase.verifyLessThanOrEqual(color, 1)

        end
    end

end
