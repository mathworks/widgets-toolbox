classdef CustomPreferenceForTest < wt.model.Preferences
    % Example subclassed preferences for unit testing

    %   Copyright 2025 The MathWorks Inc.


    %% Preference Properties
    properties (AbortSet)

        % Starting window position
        TestPreferenceA (1,1) double = 17

    end %properties

end %classdef