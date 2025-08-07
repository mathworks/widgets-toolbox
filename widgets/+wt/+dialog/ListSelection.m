classdef ListSelection < wt.abstract.BaseInternalDialog & ...
        wt.mixin.FieldColorable & ...
        wt.mixin.FontStyled
    % Implements a simple selection from a list dialog (similar to listdlg)

    %   Copyright 2025 The MathWorks Inc.


    %% Public properties
    properties (AbortSet)

    end %properties


    %% Public dependent properties
    properties (Dependent)

        % Prompt text
        Prompt (1,1) string

        % List of items to add to the list
        Items (1,:) string

        % Data associated with  items (optional)
        ItemsData (1,:)

        % Allow multi-select?
        Multiselect

        % The current selection
        Value (1,:)

    end %properties


    properties (Dependent, SetAccess = immutable)

        % Indices of displayed items that are currently added to the list
        ValueIndex (1,:)

    end %properties


    methods

        function value = get.Prompt(obj)
            value = string( obj.PromptLabel.Text );
        end

        function set.Prompt(obj,value)
            obj.PromptLabel.Text = value;
        end

        function value = get.Items(obj)
            value = string( obj.ListBox.Items );
        end

        function set.Items(obj,value)
            obj.ListBox.Items = value;
        end

        function value = get.ItemsData(obj)
            value = obj.ListBox.ItemsData;
        end

        function set.ItemsData(obj,value)
            obj.ListBox.ItemsData = value;
        end

        function value = get.Value(obj)
            value = obj.ListBox.Value;
            if isempty(obj.ListBox.ItemsData)
                value = string(value);
            end
        end

        function set.Value(obj,value)
            obj.ListBox.Value = value;
        end

        function value = get.ValueIndex(obj)
            value = obj.getListBoxSelectedIndex();
        end

        function value = get.Multiselect(obj)
            value = obj.ListBox.Multiselect;
        end

        function set.Multiselect(obj,value)
            obj.ListBox.Multiselect = value;
        end

    end %methods


    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = private)

        PromptLabel matlab.ui.control.Label

        ListBox matlab.ui.control.ListBox

    end %properties


    %% Protected methods
    methods (Access = protected)

        function setup(obj)
            % Configure the widget

            % Defaults
            obj.Size = [300,300];

            % This is normally a modal dialog
            obj.Modal = true;

            % Configure which actions close the dialog
            obj.DeleteActions = ["close","ok","cancel"];

            % Call superclass method
            obj.setup@wt.abstract.BaseInternalDialog();

            % Add buttons
            obj.DialogButtonText = ["OK","Cancel"];
            obj.DialogButtonTag = ["ok","cancel"];
            obj.DialogButtonEnable = [true, true];

            % Configure grid
            obj.Grid.RowHeight = {'fit','1x'};
            obj.Grid.ColumnWidth = {'1x'};

            % Set title
            obj.Title = " ";

            % Add controls
            obj.PromptLabel = uilabel(obj.Grid);
            obj.PromptLabel.Text = "";

            obj.ListBox = uilistbox(obj.Grid);
            obj.ListBox.ValueChangedFcn = @(~,~)onValueChanged(obj);

            % Update component lists
            % obj.BackgroundColorableComponents = [obj.Grid]
            obj.FieldColorableComponents = [obj.ListBox];
            obj.FontStyledComponents = [obj.PromptLabel, obj.ListBox];

        end %function


        function update(obj)

            % Configure list
            obj.ListBox.Items = obj.Items;
            obj.ListBox.ItemsData = obj.ItemsData;

            % Check if OK button can be enabled
            obj.updateButtonEnables();

        end %function


        function updateButtonEnables(obj)

            % enable OK button if a value is selected
            hasSelection = ~isempty(obj.Value);
            % hasPass = strlength(obj.PasswordField.Value) > 0;
            obj.DialogButtonEnable(1) = hasSelection;

        end %function


        function onValueChanged(obj)

            % Check if Login button can be enabled
            obj.updateButtonEnables();

        end %function


        function assignOutput(obj)

            % Assign output
            if obj.LastAction == "ok"
                output.Value = obj.Value;
                output.ValueIndex = obj.ValueIndex;
            else
                output.Value = [];
                output.ValueIndex = [];
            end

            obj.Output = output;

        end %function


        function selIdx = getListBoxSelectedIndex(obj)
            % Get the current selected row indices in the listbox

            if isMATLABReleaseOlderThan("R2023b")
                warnState = warning('off','MATLAB:structOnObject');
                s = struct(obj.ListBox);
                warning(warnState);
                selIdx = s.SelectedIndex;
                if isequal(selIdx, -1)
                    selIdx = [];
                end
            else
                selIdx = obj.ListBox.ValueIndex;
            end

        end %function

    end %methods

end %classdef