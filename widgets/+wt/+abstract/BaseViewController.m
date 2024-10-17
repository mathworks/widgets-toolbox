classdef BaseViewController < wt.mixin.ModelObserver & ...
        matlab.ui.componentcontainer.ComponentContainer
    % Base class for views/controllers referencing a BaseModel class

    % Copyright 2024 The MathWorks Inc.


    %% Public Properties
    properties (AbortSet)

        % The default panel name prefix to display
        PanelNamePrefix (1,1) string

    end %properties


    %% Internal Properties
    properties (Hidden, SetAccess = protected)

        % Internal grid to place outer panel contents
        OuterGrid matlab.ui.container.GridLayout

        % Outer panel with optional title
        OuterPanel matlab.ui.container.Panel

        % The internal grid to manage contents
        Grid matlab.ui.container.GridLayout

    end %properties


    properties (Transient, NonCopyable, UsedInUpdate = true, ...
            GetAccess = private, SetAccess = protected)

        % Internal flag to trigger an update call
        TriggerUpdate_BVC (1,1) logical = false

    end %properties


    %% Constructor
    methods
        function obj = BaseViewController(varargin)
            % Constructor

            % Call superclass constructors
            obj = obj@matlab.ui.componentcontainer.ComponentContainer(varargin{:});
            obj@wt.mixin.ModelObserver();

        end %function
    end %methods

    
    %% Debugging Methods
    methods
        
        function forceUpdate(obj)
            % Forces update to run (For debugging only!)

            obj.update();

        end %function
        
    end %methods


    %% Protected Methods
    methods (Access = protected)

        function setup(obj)
            % Configure the widget

            % Set default positioning
            warnState = warning('off','MATLAB:ui:components:noPositionSetWhenInLayoutContainer');
            obj.Units = "normalized";
            obj.Position = [0 0 1 1];
            warning(warnState);

            % Outer grid to place the outer panel
            obj.OuterGrid = uigridlayout(obj, [1 1]);
            obj.OuterGrid.Padding = [0 0 0 0];

            % Make an outer panel
            obj.OuterPanel = uipanel(obj.OuterGrid);

            % Name the panel with the view's class name by default
            obj.PanelNamePrefix = extract(string(class(obj)), ...
                alphanumericsPattern + textBoundary);
            obj.OuterPanel.Title = obj.PanelNamePrefix;

            % Grid Layout to manage contents
            obj.Grid = uigridlayout(obj.OuterPanel,[5 2]);
            obj.Grid.Padding = 10;
            obj.Grid.ColumnWidth = {'fit','1x'};
            obj.Grid.RowHeight = {'fit','fit','fit','fit','fit'};
            obj.Grid.ColumnSpacing = 5;
            obj.Grid.RowSpacing = 10;
            obj.Grid.Scrollable = true;

        end %function


        function update(obj)

            % Get the model to display
            [model, validToDisplay] = obj.getScalarModelToDisplay();

            % Prepare default name of the panel
            if validToDisplay && strlength(model.Name)
                panelTitle = obj.PanelNamePrefix + ": " + model.Name;
            else
                panelTitle = obj.PanelNamePrefix;
            end

            % Update the panel name
            obj.OuterPanel.Title = panelTitle;

        end %function


        function requestUpdate(obj)
            % Request update to occur at next drawnow cycle

            obj.TriggerUpdate_BVC = ~obj.TriggerUpdate_BVC;

        end %function
        

        function onModelSet(obj)
            % Triggered when Model has been changed

            % Request an update
            obj.requestUpdate();

            % Call superclass method
            obj.onModelSet@wt.mixin.ModelObserver()

        end %function

        function onModelChanged(obj,evt)
            % Triggered when a property within the model has changed

            % Request an update
            obj.requestUpdate();

            % Call superclass method
            obj.onModelChanged@wt.mixin.ModelObserver(evt)

        end %function


        function onFieldEdited(obj,evt,fieldName,index)
            % This is a generic callback that simple controls may use. For
            % example, the ValueChangedFcn for an edit field may call this
            % directly with the Model's property name that should be
            % updated. Use this for callbacks of simple controls that can
            % set a field simply by name.

            arguments
                obj (1,1) wt.abstract.BaseViewController
                evt
                fieldName (1,1) string
                index (1,:) double {mustBeInteger,mustBePositive} = zeros(1,0)
            end

            if ~isscalar(obj.Model)
                warning("wt:BaseViewController:onFieldEdited:NonScalarModel",...
                    "The onFieldEdited method is unable to set new " + ...
                    "value to an empty or nonscalar model.")
                return
            end

            % Get the new value
            newValue = evt.Value;

            % Treat char as string
            if ischar(newValue)
                newValue = string(newValue);
            end

            % Handle array values with the index input indicating what
            % index of the newValue was changed
            if ~isscalar(newValue) && ~isempty(index) && ...
                    isscalar(obj.Model.(fieldName)(index))

                % We have one index of an array being set
                obj.Model.(fieldName)(index) = newValue(index);

            else

                % We are setting the entire array
                obj.Model.(fieldName) = newValue;

            end

            % Set the new value

        end %function

    end %methods

end %classdef