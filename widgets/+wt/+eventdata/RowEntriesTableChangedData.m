classdef RowEntriesTableChangedData < event.EventData
    % Event data for table changed events

    % Copyright 2024 The MathWorks, Inc.

    %% Properties
    properties
        Action (1,1) string
        Row double
        Column double
        EditValue string {mustBeScalarOrEmpty}
        Value
        PreviousValue
        TableData
        PreviousTableData
        Error
    end %properties
    
end % classdef