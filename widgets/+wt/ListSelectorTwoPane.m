classdef ListSelectorTwoPane < wt.ListSelector
    % Select from an array of items and add them to a list
    
    % Copyright 2020-2021 The MathWorks Inc.
    
    
    
    %% Internal Properties
    properties ( Transient, NonCopyable, ...
            Access = {?wt.abstract.BaseWidget, ?wt.test.BaseWidgetTest} )
        
        % The ListBox control
        AllItemsListBox (1,1) matlab.ui.control.ListBox
        
    end %properties
    
    
    
    %% Protected methods
    methods (Access = protected)
        
        function setup(obj)
            
            % Call superclass method
            obj.setup@wt.ListSelector();
            
            % Set default size
            obj.Position(3:4) = [200 120];
            
            % Configure grid
            obj.Grid.ColumnWidth = {'1x',25,'1x'};
            
            % Move the selection listbox to the rightmost column
            obj.ListBox.Layout.Column = 3;
            obj.ListBox.Layout.Row = [1 2];
            
            % Create the Listbox for the list of items to pick from
            obj.AllItemsListBox = uilistbox(obj.Grid);
            obj.AllItemsListBox.Multiselect = true;
            obj.ListBox.ValueChangedFcn = @(h,e)obj.onLeftSelectionChanged(e);
            obj.AllItemsListBox.Layout.Column = 1;
            obj.AllItemsListBox.Layout.Row = [1 2];
            
            % Update the button icons
            obj.ListButtons.Icon(1) = "right_24.png"; %Add button
            obj.ListButtons.Icon(2) = "left_24.png"; %Remove button
            
            % Update the internal component lists
            obj.FontStyledComponents(end+1) = obj.AllItemsListBox;
            obj.EnableableComponents(end+1) = obj.AllItemsListBox;
            obj.FieldColorableComponents(end+1) = obj.AllItemsListBox;
            
        end %function
        
        
        function update(obj)
            
            % Call superclass method
            obj.update@wt.ListSelector();
            
            % Update the list of choices
            itemIds = 1:numel(obj.Items);
            if obj.AllowDuplicates
                obj.AllItemsListBox.Items = obj.Items;
                obj.AllItemsListBox.ItemsData = itemIds;
            else
                isNotSelected = ~ismember(itemIds, obj.SelectedIndex);
                obj.AllItemsListBox.Items = obj.Items(isNotSelected);
                obj.AllItemsListBox.ItemsData = itemIds(isNotSelected);
            end
            
            % Button enables
            if obj.Enable
                obj.ListButtons.ButtonEnable(1) = ...
                    obj.ListButtons.ButtonEnable(1) && ...
                    ~isempty(obj.AllItemsListBox.Value);
            end %if obj.Enable
            
        end %function
        
        
        function onButtonPushed(obj,evt)
            
            % Which button?
            switch evt.Tag
                
                case 'Add'
                    % Override the single list behavior
                    newSelIdx = obj.AllItemsListBox.Value;
                    obj.SelectedIndex = [obj.SelectedIndex newSelIdx];
                    
                    % Force update
                    obj.update();
                    
                otherwise
                    % Call superclass method
                    obj.onButtonPushed@wt.ListSelector(evt);
                    
            end %switch
            
        end %function
        
        
        function onLeftSelectionChanged(obj,~)
            
            % Force update
            obj.update();
            
        end %function
        
    end %methods
        
        
end % classdef

