classdef DialogButtonPushedData < event.EventData
    % Event data for dialog button push

    %   Copyright 2020-2025 The MathWorks Inc.

    %% Properties
    properties

        % Action that was performed
        Action (1,1) string

        % Dialog output
        Output

    end %properties

end %classdef