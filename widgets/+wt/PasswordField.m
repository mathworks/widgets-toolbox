classdef PasswordField <  wt.abstract.BaseWidget
    % A password entry field

    % Copyright 2020-2025 The MathWorks Inc.


    %% Public properties
    properties (AbortSet)

        % The current value shown
        Value (1,1) string

    end %properties


    %% Events
    events (HasCallbackProperty, NotifyAccess = protected)

        % Triggered on enter key pressed, has companion callback
        ValueChanged

        % Triggered on value changing during typing, has companion callback
        ValueChanging

    end %events



    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = protected)

        % Password control
        PasswordControl (1,1) matlab.ui.control.HTML

        % Previous value for callback
        PrevValue (1,1) string

    end %properties


    %% Protected methods
    methods (Access = protected)

        function setup(obj)

            % Call superclass method
            obj.setup@wt.abstract.BaseWidget()

            % Set default size
            obj.Position(3:4) = [100 25];

            % Define the HTML source
            html = HTMLComponentForPasswordField();

            % Create a html password input
            obj.PasswordControl = uihtml(...
                'Parent',obj.Grid,...
                'Data', struct('Value', "", 'DoFocus', false), ...
                'HTMLSource',html,...
                'DataChangedFcn',@(h,e)obj.onPasswordChanged(e) );

            % Establish Background Color Listener
            obj.BackgroundColorableComponents = obj.Grid;

        end %function


        function update(obj)

            % Update the edit control text
            obj.PasswordControl.Data.Value = obj.Value;

        end %function

    end %methods



    %% Private methods
    methods (Access = private)

        function onPasswordChanged(obj,evt)
            % Triggered on interaction

            % Grab the data in string format
            newValue = string(evt.Data.Value);
            oldValue = obj.Value;
            previousData = evt.PreviousData.Value;

            % Look at the states
            if endsWith(newValue, newline)
                % Enter key was pressed in the uihtml component

                % Clear the newline from the new value
                newValue = erase(newValue, newline);
                
                % Store value
                obj.Value = newValue;

                % Trigger event
                evtOut = wt.eventdata.PropertyChangedData('Value', newValue);
                notify(obj,"ValueChanged",evtOut);

            elseif endsWith(previousData, newline)
                % This is needed to ignore double events

                % Clear the newline from the uihtml data
                newValue = erase(newValue, newline);

                % Store value
                obj.Value = newValue;
                
                % Trigger event
                evtOut = wt.eventdata.PropertyChangedData('Value', ...
                    newValue, oldValue);
                notify(obj,"ValueChanging",evtOut);

            elseif newValue ~= oldValue

                % Store value
                obj.Value = newValue;

                % Trigger event
                evtOut = wt.eventdata.PropertyChangedData('Value', ...
                    newValue, oldValue);
                notify(obj,"ValueChanging",evtOut);

            end

        end %function

    end %methods

    %% Public methods
    methods

        function focus(obj)

            % Brings parent figure to front
            focus(obj.PasswordControl)

            % What MATLAB version?
            if ~isMATLABReleaseOlderThan("R2023a")
                % Fire event 'FocusOnInputField' that will trigger the HTML
                % component to select the Input Field directly.
                sendEventToHTMLSource(obj.PasswordControl, 'FocusOnInputField', '')
            else
                % Setting 'DoFocus' to TRUE will trigger DataChanged event in HTML
                % component, selecting the Input Field. 
                % The HTML component reverts 'DoFocus' back to FALSE.
                obj.PasswordControl.Data.DoFocus = true;
            end

        end %function

    end %methods

end % classdef

function T = HTMLComponentForPasswordField()
% Return HTML component for password field in text

t = {
    '<input type="password" id="value" style="width:100%;height:100%">                  '
    '<script type="text/javascript">                                                '
    '                                                                               '
    '    function setup(htmlComponent) {                                            '
    '                                                                               '
    '        // Code response to data changes in MATLAB                             '
    '        htmlComponent.addEventListener("DataChanged", dataFromMATLABToHTML);   '
    '                                                                               '
    '        // Code response to FocusOnInputField event in MATLAB                  '
    '        htmlComponent.addEventListener("FocusOnInputField", focusInputField);  '
    '                                                                               '
    '        // Update the Data property of the htmlComponent object                '
    '        // This action also updates the Data property of the MATLAB HTML object'
    '        // and triggers the DataChangedFcn callback function                   '
    '        let dataInput = document.getElementById("value")                       '
    '        dataInput.addEventListener("change", dataFromHTMLToMATLAB);            '
    '                                                                               '
    '        // Trigger a DataChangedFcn callback when enter is pressed.            '
    '        document.addEventListener("keyup", onKeyPressed);                      '
    '                                                                               '
    '        function dataFromMATLABToHTML(event) {                                 '
    '            let changedData = htmlComponent.Data;                              '
    '            console.log("New data from MATLAB:", changedData);                 '
    '                                                                               '
    '            // Update your HTML or JavaScript with the new data                '
    '            let domValue = document.getElementById("value");                   '
    '            domValue.value = changedData.Value;                                '
    '                                                                               '
    '            // Focus on the input element                                      '
    '            if (changedData.DoFocus){                                          '
    '                                                                               '
    '                // Focus on input field                                        '
    '                domValue.focus();                                              '
    '                domValue.select();                                             '
    '                                                                               '
    '                // Revert value for focus event                                '
    '                changedData.DoFocus = false;                                   '
    '                htmlComponent.Data = changedData;                              '
    '            }                                                                  '
    '        }                                                                      '
    '                                                                               '
    '        function focusInputField(event) {                                      '
    '            let domValue = document.getElementById("value");                   '
    '                                                                               '
    '            // Focus on the input element                                      '
    '            if (domValue) {                                                    '
    '               domValue.focus();                                               '
    '               domValue.select();                                              '
    '            }                                                                  '
    '        }                                                                      '
    '                                                                               '
    '        function dataFromHTMLToMATLAB(event) {                                 '
    '            let newValue = event.target.value;                                 '
    '            let newData = htmlComponent.Data;                                  '
    '                                                                               '
    '            newData.Value = newValue;                                          '
    '                                                                               '
    '            htmlComponent.Data = newData;                                      '
    '        }                                                                      '
    '                                                                               '
    '        function onKeyPressed(event) {                                         '
    '                                                                               '
    '            // Get data to change                                              '
    '            let newData = htmlComponent.Data;                                  '
    '            let domValue = document.getElementById("value");                   '
    '                                                                               '
    '            // ENTER key?                                                      '
    '            if (event.keyCode === 13) {                                        '
    '                newData.Value = domValue.value + "\n";                         '
    '                htmlComponent.Data = newData;                                  '
    '            }                                                                  '
    '        }                                                                      '
    '    }                                                                          '
    '</script>                                                                      '
};

% Join cellstr to text scalar
t = convertCharsToStrings(t);
T = join(t, newline);
end