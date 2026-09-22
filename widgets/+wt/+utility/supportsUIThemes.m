function tf = supportsUIThemes()
% True when MATLAB supports uifigure themes.

% Copyright 2026 The MathWorks, Inc.

tf = ~isMATLABReleaseOlderThan("R2025a");

end
