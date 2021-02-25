classdef DateTimeSelector < wt.abstract.BaseWidget &...
        wt.mixin.Enableable & wt.mixin.FontStyled & wt.mixin.FieldColorable
    % A date time selection control
    
    % Copyright 2021 The MathWorks Inc.
    
    
    %% Public properties
    properties (AbortSet)
        
        % The current value shown
        Value (1,1) datetime
        
%     end %properties
    
    
%     properties (AbortSet, UsedInUpdate = false)
        
        % The time format
        ShowAMPM(1,1) logical = false
        
        % Show seconds or not
        ShowSeconds (1,1) logical = false
        
    end %properties
    
    
    
    %% Events
    events (HasCallbackProperty, NotifyAccess = protected)
        
        % Triggered on value changed, has companion callback
        ValueChanged
        
    end %events
    
    
    
    %% Internal Properties
    properties %( Transient, NonCopyable, ...
            %Access = {?wt.abstract.BaseWidget, ?wt.test.BaseWidgetTest} )
        
        % Date
        DatePicker (1,1) matlab.ui.control.DatePicker
        
        % Hour
        HourSpinner (1,1) matlab.ui.control.Spinner
        
        % Minute
        MinuteSpinner (1,1) matlab.ui.control.Spinner
        
        % Second
        SecondSpinner (1,1) matlab.ui.control.Spinner
        
        % AM/PM
        AMPMDropdown (1,1) matlab.ui.control.DropDown
        
    end %properties
    
    
    
    %% Protected methods
    methods (Access = protected)
        
        function setup(obj)
            
            % Adjust default size
            obj.Position(3:4) = [250 25];
            
            % Call superclass setup first to establish the grid
            obj.setup@wt.abstract.BaseWidget();
            
            % Configure Grid
            obj.Grid.ColumnWidth = {'9x',5,'4x','4x',0,0};
            obj.Grid.RowHeight = {'1x'};
            obj.Grid.ColumnSpacing = 0;
            
            % Create the controls
            
            obj.DatePicker = uidatepicker(...
                "Parent",obj.Grid,...
                "ValueChangedFcn",@(h,e)obj.onDateChanged(e));
            
            uicontainer(obj.Grid,'Visible','off'); %Spacer
            
            obj.HourSpinner = uispinner(...
                "Parent",obj.Grid,...
                "ValueChangedFcn",@(h,e)obj.onDateChanged(e));
            
            obj.MinuteSpinner = uispinner(...
                "Parent",obj.Grid,...
                "ValueChangedFcn",@(h,e)obj.onDateChanged(e));
            
            obj.SecondSpinner = uispinner(...
                "Parent",obj.Grid,...
                "ValueChangedFcn",@(h,e)obj.onDateChanged(e));
            
            obj.AMPMDropdown = matlab.ui.control.DropDown(...
                "Parent",obj.Grid,...
                "Items",["AM","PM"],...
                "ValueChangedFcn",@(h,e)obj.onDateChanged(e));
            
            % Update the internal component lists
            allFields = [
                obj.DatePicker
                obj.HourSpinner
                obj.MinuteSpinner
                obj.SecondSpinner
                obj.AMPMDropdown
                ];
            obj.FontStyledComponents = allFields;
            obj.FieldColorableComponents = allFields;
            obj.EnableableComponents = allFields;
            
        end %function
        
        
        function update(obj)
            
            % Toggle visibilities
            obj.SecondSpinner.Visible = obj.ShowSeconds;
            obj.AMPMDropdown.Visible = obj.ShowAMPM;
            if obj.ShowSeconds
                obj.Grid.ColumnWidth{5} = '4x';
            else
                obj.Grid.ColumnWidth{5} = 0;
            end
            if obj.ShowAMPM
                obj.Grid.ColumnWidth{6} = '5x';
            else
                obj.Grid.ColumnWidth{6} = 0;
            end
            
            % Update date
            obj.DatePicker.Value = obj.Value;
            
            % Update Hour
            if obj.ShowAMPM && obj.Value.Hour == 0
                obj.HourSpinner.Value = 12;
                obj.AMPMDropdown.Value = "AM";
            elseif obj.ShowAMPM && obj.Value.Hour > 12
                obj.HourSpinner.Value = obj.Value.Hour - 12;
                obj.AMPMDropdown.Value = "PM";
            else
                obj.HourSpinner.Value = obj.Value.Hour;
                obj.AMPMDropdown.Value = "AM";
            end
            
            % Update minutes and seconds
            obj.MinuteSpinner.Value = obj.Value.Minute;
            
            % Update seconds
            if obj.ShowSeconds
                obj.SecondSpinner = obj.Value.Second;
            end
            
        end %function
        
        
        function onDateChanged(obj,evt)
            % Triggered on text interaction
            
            % Get the new value
            valueIn = evt.Value;
            
            % Grab the current full date time
            value = obj.Value;
            
            % What was changed
            switch evt.Source
                
                case obj.DatePicker
                    
                    value.Year = valueIn.Year;
                    value.Month = valueIn.Month;
                    value.Day = valueIn.Day;

                case obj.HourSpinner
                    
                    value.Hour = valueIn.Hour;
                    
                case obj.MinuteSpinner
                    
                    value.Minute = valueIn.Minute;
                    
                case obj.SecondSpinner
                    
                    value.Second = valueIn.Second;
                    
                case obj.AMPMDropdown
                    
                    if valueIn == "AM"
                        
                    end
                
            end %switch
            
            % Prepare event data
            evtOut = wt.eventdata.PropertyChangedData('Value', value, obj.Value);
            
            % Store new result
            obj.Value = evt.Value;
            
            % Trigger event
            notify(obj,"ValueChanged",evtOut);
            
        end %function
        
    end % methods
    
end % classdef