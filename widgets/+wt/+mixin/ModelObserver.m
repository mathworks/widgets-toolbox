classdef (Abstract) ModelObserver < handle
    % Mixin for components using a model that observe changes

    
    %% Abstract Properties
    % Subclass must define these
    properties (Abstract, AbortSet, SetObservable)

        % Model class containing data to display in the pane
        Model wt.model.BaseModel

    end %properties


    %% Events
    events (NotifyAccess = protected)

        % Triggered when the Model has changed
        ModelSet

        % Triggered when a property within the model has changed
        ModelChanged

    end %events


    %% Internal Properties
    properties (SetAccess = protected)

        % Listener for a new model being attached
        ModelSetListener event.listener

        % Listener for property changes within the model
        ModelChangedListener event.listener

    end %properties


    %% Constructor
    methods
        function obj = ModelObserver()
            % Constructor

            % Listen to Model property being set
            obj.ModelSetListener = listener(obj,"Model","PostSet",@(~,~)onModelSet(obj));

            % Listen to model changes
            obj.attachModelListeners();

        end %function
    end %methods



    %% Protected Methods
    methods (Access = protected)
        
        function onModelSet(obj)
            % Triggered when Model has been changed

            % Listen to model property changes
            obj.attachModelListeners();

            % Prepare event data
            evtOut = wt.eventdata.ModelSetData();
            evtOut.Model = obj.Model;
            evtOut.Controller = obj;

            % Notify listeners
            notify(obj,"ModelSet",evtOut)

        end %function


        function attachModelListeners(obj)
            % Triggered when Model has been changed

            % Listen to model property changes
            obj.ModelChangedListener = listener(obj.Model,...
                "ModelChanged", @(~,evt)onModelChanged(obj,evt));

        end %function


        function onModelChanged(obj,evt)
            % Triggered when a property within the model has changed

            arguments
                obj (1,1) wt.mixin.ModelObserver
                evt (1,1) wt.eventdata.ModelChangedData
            end

            % Prepare eventdata
            evtOut = wt.eventdata.ModelChangedData;
            evtOut.Model = evt.Model;
            evtOut.Property = evt.Property;
            evtOut.Value = evt.Value;
            evtOut.Stack = [{obj}, evt.Stack];
            evtOut.ClassStack = [class(obj), evt.ClassStack];

            % Notify listeners
            notify(obj,"ModelChanged",evtOut)

        end %function


        function className = getModelClassName(obj)
            % Returns the class name of the Model property contents

            arguments
                obj (1,1) wt.mixin.ModelObserver
            end

            % Get the class of the Model array
            className = string( class( obj.Model ) );

        end %function


        function newModel = constructDefaultModel(obj)
            % Generates a scalar object instance of the class name used in
            % the Model property. The model must be instantiated with no
            % input arguments

            arguments
                obj (1,1) wt.mixin.ModelObserver
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