classdef ModelSetData < event.EventData
    % Event data for model set

    % Copyright 2024 The MathWorks, Inc.

    %% Properties
    properties (SetAccess = ?wt.abstract.BaseViewController)
        Model
        Controller
    end %properties

end % classdef