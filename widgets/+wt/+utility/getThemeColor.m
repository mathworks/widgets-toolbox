function color = getThemeColor(theme, semanticColorId)
% Get an RGB color from a uifigure theme semantic color identifier.

% Copyright 2026 The MathWorks, Inc.

arguments
    theme
    semanticColorId (1,1) string
end

msg = "MATLAB R2025a or later is needed to call wt.utility.getThemeColor().";
assert(wt.utility.supportsUIThemes(), msg)

% Keep the internal theme API isolated to this compatibility helper.
color = matlab.graphics.internal.themes.getAttributeValue(theme, semanticColorId);

end
