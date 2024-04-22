classdef BaseViewController < ...
        matlab.ui.componentcontainer.ComponentContainer %& ...
    % wt.mixin.BackgroundColorable & ...
    % wt.mixin.PropertyViewable & ...
    % wt.mixin.ErrorHandling
    % Base class for views/controllers referencing a BaseModel class


    %% Public Properties
    properties (Abstract, AbortSet, SetObservable)

        % Model class containing data to display in the pane
        Model wt.model.BaseModel

    end %properties

    % methods
    %     function set.Model(obj,value)
    %         obj.Model = value;
    %         obj.attachModelListener();
    %     end
    % end


    %% Internal Properties
    properties (Hidden, SetAccess = protected)

        % Internal grid to place outer panel contents
        OuterGrid matlab.ui.container.GridLayout

        % Outer panel with optional title
        OuterPanel matlab.ui.container.Panel

        % The internal grid to manage contents
        Grid matlab.ui.container.GridLayout

    end %properties


    properties (Access = private)

        % Listener for a new model being attached
        ModelSetListener_BVC event.listener

        % Listener for property changes within the model
        ModelPropertyChangedListener_BVC event.listener

    end %properties


    properties (Transient, UsedInUpdate, Access = private)

        % Internal flag to trigger an update call
        Dirty (1,1) logical = false

    end %properties


    %% Constructor
    methods
        function obj = BaseViewController(varargin)
            % Constructor

            % Call superclass constructor
            obj = obj@matlab.ui.componentcontainer.ComponentContainer(varargin{:});

            % Listen to Model property being set
            obj.ModelSetListener_BVC = listener(obj,"Model","PostSet",...
                @(~,~)attachModelListener_BVC(obj));

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
            className = string(class(obj));
            panelName = extract(className,alphanumericsPattern + textBoundary);
            obj.OuterPanel.Title = panelName;

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

            % Do nothing - required for ComponentContainer

            disp("Updating BaseViewController: " + class(obj));

        end %function


        function requestUpdate(obj)
            % Request update method to run during next drawnow

            obj.Dirty = true;

        end %function


        function onFieldEdited(obj,evt,fieldName,index)
            % This is a generic callback that simple controls may use For
            % example, the ValueChangedFcn for an edit field may call this
            % directly with the Model's property name that should be
            % updated. Use this for callbacks of simple controls that can
            % set a field simply by name.

            arguments
                obj (1,1) wt.abstract.BaseViewController
                evt
                fieldName (1,1) string
                index (1,:) double {mustBeInteger,mustBePositive} = 1
            end

            newValue = evt.Value;
            obj.Model.(fieldName)(index) = newValue;

        end %function

    end %methods



    %% Private methods
    methods (Access = private)
        function attachModelListener_BVC(obj)
            obj.ModelPropertyChangedListener_BVC = listener(obj.Model,...
                "PropertyChanged", @(~,~)requestUpdate(obj));
        end
    end

end %classdef