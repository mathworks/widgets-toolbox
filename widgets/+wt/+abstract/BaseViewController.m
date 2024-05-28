classdef BaseViewController < ...
        matlab.ui.componentcontainer.ComponentContainer
    % Base class for views/controllers referencing a BaseModel class

    % Copyright 2024 The MathWorks Inc.


    %% Events
    events (HasCallbackProperty, NotifyAccess = protected)

        % Triggered when the Model has changed
        ModelSet

        % Triggered when a property within the model has changed
        ModelChanged

    end %events


    %% Public Properties
    properties (Abstract, AbortSet, SetObservable)

        % Model class containing data to display in the pane
        Model wt.model.BaseModel

    end %properties


    %% Internal Properties
    properties (Hidden, SetAccess = protected)

        % Internal grid to place outer panel contents
        OuterGrid matlab.ui.container.GridLayout

        % Outer panel with optional title
        OuterPanel matlab.ui.container.Panel

        % The internal grid to manage contents
        Grid matlab.ui.container.GridLayout

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
                @(~,~)onModelSet(obj));

        end %function
    end %methods

    
    %% Debugging Methods
    methods
        
        function forceUpdate(obj)
            % Forces update to run (For debugging only!)

            disp("DEBUG: Forcing update for " + class(obj));
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


        function update(~)

            % Do nothing - required for ComponentContainer

        end %function


        function onModelChanged(obj,evt)
            % Triggered when a property within theModel has changed

            % Request update method to run during next drawnow
            obj.Dirty = true;

            % Notify listeners
            notify(obj,"ModelChanged",evt)

        end %function


        function onModelSet(obj)
            % Triggered when Model has been changed

            % Listen to model property changes
            obj.ModelPropertyChangedListener_BVC = listener(obj.Model,...
                "PropertyChanged", @(~,evt)onModelChanged(obj,evt));

            % Prepare event data
            evtOut = wt.eventdata.ModelSetData();
            evtOut.Model = obj.Model;
            evtOut.Controller = obj;

            % Notify listeners
            notify(obj,"ModelSet",evtOut)

        end


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
                index (1,:) double {mustBeInteger,mustBePositive} = 1
            end

            if ~isscalar(obj.Model)
                warning("wt:BaseViewController:onFieldEdited:NonScalarModel",...
                    "The onFieldEdited method is unable to set new value to an empty or nonscalar model.")
                return
            end

            newValue = evt.Value;
            if ~isscalar(newValue) && isscalar(obj.Model.(fieldName)(index))
                newValue = newValue(index);
            end
            obj.Model.(fieldName)(index) = newValue;

        end %function


        function className = getModelClassName(obj)
            % Returns the class name of the Model property contents

            arguments (Input)
                obj (1,1) wt.abstract.BaseViewController
            end

            arguments (Output)
                className (1,1) string
            end

            % Get the class of the Model array
            className = class( obj.Model );

        end %function


        function newModel = constructDefaultModel(obj)
            % Generates a scalar object instance of the class name used in
            % the Model property. The model must be instantiated with no
            % input arguments

            arguments
                obj (1,1) wt.abstract.BaseViewController
            end

            % Construct a new object
            className = getModelClassName(obj);
            fcnConstruct = str2func(className);
            newModel = fcnConstruct();

        end %function


        function [model, validToDisplay] = getScalarModelToDisplay(obj)
            
            % Get a single instance of the correct model type and indicate
            % if it's found and valid. This is useful in case obj.Model is
            % empty, it will still return a scalar instance to show default
            % values and the modelValid flag will be false, indicating to
            % disable the fields.
            model = obj.Model;
            validToDisplay = isscalar(model) && isvalid(model);
            if ~validToDisplay
                model = obj.constructDefaultModel();
            end
            validToDisplay = matlab.lang.OnOffSwitchState(validToDisplay);

        end %function

    end %methods

end %classdef