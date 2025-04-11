classdef ButtonGrid < wt.abstract.BaseWidget & ...
        wt.mixin.ButtonColorable & ...
        wt.mixin.FontStyled & ...
        wt.mixin.Enableable

    % Array of buttons with a single callback/event

    % Copyright 2020-2025 The MathWorks Inc.


    %% Events
    events (HasCallbackProperty, NotifyAccess = protected)

        % Triggered when a button is pushed
        ButtonPushed

    end %events


    %% Properties

    properties (AbortSet)

        % Icons
        Icon (1,:) string = ["up_24.png", "down_24.png"]

        % Text
        Text (1,:) string

        % Tooltip
        Tooltip (1,:) string

        % Tag
        ButtonTag (1,:) string

        % Enable of each button (scalar or array)
        ButtonEnable (1,:) matlab.lang.OnOffSwitchState {mustBeNonempty} = true

        % Orientation of the buttons
        Orientation (1,1) wt.enum.HorizontalVerticalState = wt.enum.HorizontalVerticalState.horizontal

        % Alignment of the icon
        IconAlignment (1,1) wt.enum.AlignmentState = wt.enum.AlignmentState.top

        % Default size of new buttons ('1x', 'fit' or a number)
        DefaultSize (1,1) string {mustBeValidGridSize(DefaultSize)} = "1x"

    end %properties


    properties (AbortSet, Dependent, UsedInUpdate = false)

        % Width of the buttons
        ButtonWidth

        % Height of the buttons
        ButtonHeight

    end %properties



    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = protected)
        
        % Buttons (other widgets like ListSelector also access this)
        Button (1,:) matlab.ui.control.Button

    end %properties



    %% Protected methods
    methods (Access = protected)

        function setup(obj)

            % Call superclass method
            obj.setup@wt.abstract.BaseWidget()

            % Set default size
            obj.Position(3:4) = [100 30];

            % Configure Main Grid
            obj.Grid.Padding = 2;
            
            % Update the internal component lists
            obj.BackgroundColorableComponents = obj.Grid;

        end %function


        function update(obj)

            % How many tasks?
            numOld = numel(obj.Button);
            numNew = max( numel(obj.Icon), numel(obj.Text) );

            % Update number of rows
            if numNew > numOld

                % Add rows
                for idx = (numOld+1):numNew
                    obj.Button(idx) = uibutton(obj.Grid,...
                        "ButtonPushedFcn", @(h,e)obj.onButtonPushed(e) );
                end

                % Update the internal component lists
                obj.FontStyledComponents = obj.Button;
                obj.EnableableComponents = obj.Button;
                obj.ButtonColorableComponents = obj.Button;

            elseif numOld > numNew

                % Remove rows
                delete(obj.Button((numNew+1):end));
                obj.Button((numNew+1):end) = [];

            end %if numNew > numOld

            % Expand the lists of icons and text to the number of buttons
            icons = obj.Icon;
            icons(1, end+1:numNew) = "";

            text = obj.Text;
            text(1, end+1:numNew) = "";

            tooltip = obj.Tooltip;
            tooltip(1, end+1:numNew) = "";

            tag = obj.ButtonTag;
            tag(1, end+1:numNew) = "";

            enable = obj.ButtonEnable;
            enable(1, end+1:numNew) = enable(1);
            if ~obj.Enable
                enable(:) = false;
            end

            % Update the names and icons
            for idx = 1:numNew

                % Update button content
                obj.Button(idx).Icon = icons(idx);
                obj.Button(idx).Text = text(idx);
                obj.Button(idx).Tooltip = tooltip(idx);
                obj.Button(idx).Tag = tag(idx);
                obj.Button(idx).IconAlignment = char(obj.IconAlignment);
                obj.Button(idx).Enable = enable(idx);

                % Update layout
                if obj.Orientation == "vertical"
                    obj.Button(idx).Layout.Column = 1;
                    obj.Button(idx).Layout.Row = idx;
                else
                    obj.Button(idx).Layout.Column = idx;
                    obj.Button(idx).Layout.Row = 1;
                end %if obj.Orientation == "vertical"

            end %for idx = 1:numNew

            % Update layout

            % What is the default size?
            defaultSize = obj.DefaultSize;
            if ~isnan(str2double(defaultSize))
                defaultSize = str2double(defaultSize);
            end

            % Set button grids
            if obj.Orientation == "vertical"
                obj.Grid.RowHeight(numOld+1:numNew) = {defaultSize};
                obj.Grid.ColumnWidth = obj.Grid.ColumnWidth(1);
            else
                obj.Grid.ColumnWidth(numOld+1:numNew) = {defaultSize};
                obj.Grid.RowHeight = obj.Grid.RowHeight(1);
            end

        end %function


        function onButtonPushed(obj,evt)
            % Triggered on button pushed

            % Trigger event
            evtOut = wt.eventdata.ButtonPushedData(evt);
            notify(obj,"ButtonPushed",evtOut);

        end %function

        function updateGridForButton(obj, prop, value)
            % Update main grid properties to value

            % Convert any text array or numeric array into a cell array
            value = convertCharsToStrings(value);
            if ~iscell(value)
                value = num2cell(value);
            end

            % If cell is scalar, repeat value for every button
            if isscalar(value)
                value = repmat(value, 1, numel(obj.Grid.(prop)));
            end

            % Update button size
            nElements = min(numel(value), numel(obj.Grid.(prop)));
            obj.Grid.(prop)(1:nElements) = value(1:nElements);
            
        end %function

    end %methods



    %% Accessors
    methods

        function value = get.ButtonWidth(obj)
            value = obj.Grid.ColumnWidth;
        end
        function set.ButtonWidth(obj,value)
            obj.updateGridForButton("ColumnWidth", value);
        end

        function value = get.ButtonHeight(obj)
            value = obj.Grid.RowHeight;
        end
        function set.ButtonHeight(obj,value)
            obj.updateGridForButton("RowHeight", value);
        end

    end %methods


end % classdef


function mustBeValidGridSize(val)
% Validate value is valid size for grid layout

% Value must be either 'fit' or '1x', or convertable to a number.
numVal = str2double(val);

% Is value convertable to a number?
if ~isnan(numVal)
    return
end

% Is value "fit"?
if strcmpi(val, "fit")
    return
end

% Is value a 1x, 2x, etc?
valStripped = strip(val, "x");
numStripped = str2double(valStripped);
if ~isnan(numStripped)
    return
end

% Value was not valid. Throw a validation error
ME = MException('ButtonGrid:InvalidSize', ...
    'Value must be a text scalar specifying the keyword ''fit'', numbers, or numbers paired with ''x'' characters.');
throwAsCaller(ME);

end