classdef (Abstract) BaseModel < handle & ...
        matlab.mixin.SetGetExactNames & ...
        matlab.mixin.Copyable & ...
        wt.mixin.DisplayNonScalarObjectAsTable
    % Base model class for apps that provides:
    %   PV pairs assignment on construction
    %
    %   Display nonscalar arrays in table format
    %
    %   Public PropertyChanged event for properties tagged as SetObservable
    %     to enable apps/widgets to listen to model changes
    %
    %   Public ModelChanged event for recursive property change
    %   notifications in a hierarchy of BaseWidget classes
    %

    % Copyright 2020-2024 The MathWorks, Inc.



    %% Events
    events

        % Triggered when SetObservable properties are changed
        PropertyChanged

        % Triggered when an aggregated / nested model has changed
        ModelChanged

    end %events



    %% Internal Properties
    properties (Transient, Hidden)

        % Toggle true in each instance to enable debugging display
        Debug (1,1) logical = false

        % List of properties containing aggregated BaseModel classes to
        % listen for hierarchical ModelChanged events. Use this cautiously
        % if model class references are used repeatedly. The intended
        % purpose is to pass notifications up the hierarchy to the top
        % level, so the session can be marked dirty.
        AggregatedModelProperties (1,:) string

    end %properties


    properties (Transient, NonCopyable, Hidden, SetAccess = private)

        % Listeners to public properties
        PropListeners

    end %properties


    properties (Transient, NonCopyable, Access = private)

        % Listeners to any aggregated / nested handle class models
        AggregatedModelListeners

    end %properties


    properties (Hidden, AbortSet)

        % Enables nested model listeners to trigger onModelChanged event
        EnableAggregatedModelListeners (1,1) logical = true

    end %properties


    % Accessors
    methods
        function set.EnableAggregatedModelListeners(obj,value)
            obj.EnableAggregatedModelListeners = value;
            if value
                obj.attachModelListeners()
            else
                obj.clearModelListeners()
            end
        end
    end %methods


    %% Constructor
    methods
        function obj = BaseModel(varargin)
            % Constructor

            % Populate public properties from P-V input pairs
            if nargin
                obj.assignPVPairs(varargin{:});
            end

            % Create listeners to public properties
            obj.createPropListeners();

            % Create listeners to aggregated model classes that may have
            % property change events
            for idx = 1:numel(obj)
                if obj(idx).EnableAggregatedModelListeners
                    obj(idx).attachModelListeners();
                end
            end

        end %function
    end %methods



    %% Static methods
    methods (Static)

        function obj = loadobj(obj)
            % Customize loading from file

            if isstruct(obj)
                error('Unable to load object.');
            end

            % Need to recreate listeners
            obj.createPropListeners();

            for idx = 1:numel(obj)
                if obj(idx).EnableAggregatedModelListeners
                    obj(idx).attachModelListeners();
                end
            end

        end %function

    end %methods



    %% Public methods
    methods

        function debugAggregatedModels(obj, value)
            % Recursively set debug on AggregatedModelProperties models in the hierarchy

            arguments
                obj (1,1) wt.model.BaseModel
                value (1,1) logical = true;
            end

            % Debug this model
            obj.Debug = value;

            % Loop on aggregated models and set debug
            for thisProp = obj.AggregatedModelProperties
                thisModel = obj.(thisProp);
                if ~isempty(thisModel) && all(isa(thisModel,"handle"))
                    thisModel(~isvalid(thisModel)) = [];
                    for idx = 1:numel(thisModel)
                        thisModel(idx).debugAggregatedModels(value);
                    end
                end
            end

        end %function

    end %methods



    %% Protected Methods
    methods (Access = protected)

        % Override copyElement method:
        function cpObj = copyElement(obj)

            if obj.Debug
                disp("wt.model.BaseModel.copyElement " + class(obj));
            end

            % Call superclass method
            cpObj = copyElement@matlab.mixin.Copyable(obj);

            % Create listeners
            cpObj.createPropListeners();
            cpObj.attachModelListeners();

        end %function


        function varargout = assignPVPairs(obj,varargin)
            % Assign the specified property-value pairs

            % This method is similar to
            % matlab.io.internal.mixin.HasPropertiesAsNVPairs, but this one
            % generally performs faster.

            if nargin > 1

                % Get a singleton parser for this class
                keepUnmatched = nargout > 0;
                p = getParser(obj, keepUnmatched);

                % Parse the P-V pairs
                p.parse(varargin{:});

                % Set just the parameters the user passed in
                ParamNamesToSet = p.Parameters;
                ParamsInResults = fieldnames(p.Results);

                % Assign properties
                for ThisName = ParamNamesToSet
                    isSettable = any(strcmpi(ThisName,ParamsInResults));
                    if isSettable && ~any(strcmpi(ThisName,p.UsingDefaults))
                        obj.(ThisName{1}) = p.Results.(ThisName{1});
                    end
                end

                % Return unmatched pairs
                if nargout
                    varargout{1} = p.Unmatched;
                end

            elseif nargout

                varargout{1} = struct;

            end %if nargin > 1

        end %function


        function createPropListeners(obj)
            % Create listeners to SetObservable properties in this class

            if obj.Debug
                disp("wt.model.BaseModel.createPropListeners " + class(obj));
            end

            % Loop on each instance (typically scalar though)
            for idx = 1:numel(obj)

                % Get one instance
                thisObj = obj(idx);

                % Which properties are observable?
                mc = metaclass(thisObj);
                isObservable = [mc.PropertyList.SetObservable];
                propInfo = mc.PropertyList(isObservable);

                % Attach listeners to observable properties
                thisObj.PropListeners = event.proplistener(thisObj, propInfo,...
                    'PostSet',@(~,e)onPropChanged(thisObj,e) );


                %RJ - Move this somewhere for efficiency - only needed if
                %we're using these!
                % Which properties are aggregated BaseModel classes?
                if isempty(thisObj.AggregatedModelProperties)
                    propNames = string({propInfo.Name});
                    fcn = @(p)isa(thisObj.(p),"wt.model.BaseModel");
                    isAggModel = arrayfun(fcn, propNames);
                    thisObj.AggregatedModelProperties = propNames(isAggModel);
                end

            end %for

        end %function


        function onPropChanged(obj,evt)

            arguments
                obj (1,1) wt.model.BaseModel
                evt (1,1) event.PropertyEvent
            end

            if obj.Debug
                disp("wt.model.BaseModel.onPropChanged " + ...
                    "    Model: " + class(evt.AffectedObject) + ...
                    "    Prop: " + evt.Source.Name + ...
                    "    Class: " + class(obj));
            end

            % Notify listeners
            evtOutP = wt.eventdata.PropertyChangedData(...
                evt.Source.Name, obj.(evt.Source.Name));
            obj.notify("PropertyChanged",evtOutP)

            % Prepare model change eventdata
            evtOutM = wt.eventdata.ModelChangedData;
            evtOutM.Property = evt.Source.Name;
            evtOutM.Model = evt.AffectedObject;
            evtOutM.Value = evtOutM.Model.(evtOutM.Property);
            % evtOutM.Stack = {obj};
            % evtOutM.ClassStack = class(obj);

            % Revise listeners for model changes given the new value
            if isa(evtOutM.Value, "wt.model.BaseModel")
                evtOutM.Model.attachModelListeners();
            end

            % Call onModelChanged method
            obj.onModelChanged(evtOutM);

        end %function


        function onModelChanged(obj,evt)
            % Runs on property changes to this class or an aggregated BaseModel
            % class

            arguments
                obj (1,1) wt.model.BaseModel
                evt (1,1) wt.eventdata.ModelChangedData
            end

            % Prepare eventdata
            % evtOut = wt.eventdata.ModelChangedData;
            % evtOut.Model = evt.Model;
            % evtOut.Property = evt.Property;
            % evtOut.Value = evt.Value;
            % evtOut.Stack = [{evt.Source}, evt.Stack];
            % evtOut.ClassStack = [class(obj), evt.ClassStack];
            
            % Prepare event data
            evtOut = copy(evt);            
            evtOut.Stack = [{obj}, evtOut.Stack];
            evtOut.ClassStack = [class(obj), evtOut.ClassStack];

            if obj.Debug
                disp("wt.model.BaseModel.onModelChanged   " + ...
                    "    Model: " + evtOut.ClassStack(end) + ...
                    "    Prop: " + evtOut.Property + ...
                    "    ClassStack: " + join(evtOut.ClassStack, " <- ") );
            end

            % Notify listeners
            obj.notify("ModelChanged",evtOut)

        end %function

    end %methods



    %% Private methods
    methods (Access = private)

        function attachModelListeners(obj,propNames)
            % Attach listeners to aggregated BaseModel changes

            arguments
                obj (1,1) wt.model.BaseModel
                propNames (1,:) string = obj.AggregatedModelProperties
            end

            if obj.Debug
                if isempty(propNames)
                    propDisp = "<none>";
                else
                    propDisp = join(propNames, ", ");
                end
                disp("wt.model.BaseModel.attachModelListeners " + ...
                    class(obj) + "  Prop: " + propDisp);
            end

            % Preallocate array of listeners
            numProps = numel(propNames);
            newPropListeners = repmat({event.listener.empty(0,1)}, numProps, 1);

            % Loop on each property requested, in case of multiple
            % properties having aggregated handle objects
            for idx = 1:numProps

                % Get the current property
                thisProp = propNames(idx);

                % Get the model(s) to listen to
                aggregatedObjects = obj.(thisProp);

                % Skip this property if empty
                if isempty(aggregatedObjects)
                    continue
                end

                % These objects must be handle!
                allAreHandle = all(isa(aggregatedObjects, "wt.model.BaseModel"));
                assert(allAreHandle,...
                    "Expected %s to contain a handle class object.",...
                    thisProp);

                % Clear any invalid objects
                aggregatedObjects(~isvalid(aggregatedObjects)) = [];

                % Create listener to property changes within the model(s)
                fcnModelChange = @(src,evt)onModelChanged(obj,evt);
                newPropListeners{idx} = event.listener(aggregatedObjects,...
                    'ModelChanged',fcnModelChange);

            end %for

            % Flatten the lists
            newPropListeners = vertcat(newPropListeners{:});

            % Store the results
            obj.AggregatedModelListeners = newPropListeners;

        end %function


        function clearModelListeners(obj)
            % Removes aggregated model listeners

            delete(obj.AggregatedModelListeners);
            obj.AggregatedModelListeners(:) = [];

        end %function


        function thisParser = getParser(obj,keepUnmatched)

            % What class is this?
            className = class(obj);

            % Keep a list of reusable parsers for each class
            persistent allParsers
            if isempty(allParsers)
                allParsers = containers.Map('KeyType','char','ValueType','any');
            end

            % Get or make a custom parser for this class
            try

                thisParser = allParsers(className);

            catch

                % Get a list of public properties
                metaObj = metaclass(obj);
                isSettableProp = strcmp({metaObj.PropertyList.SetAccess}','public');
                settableProps = metaObj.PropertyList(isSettableProp);
                publicPropNames = {settableProps.Name}';
                hasDefault = [settableProps.HasDefault]';
                defaultValues = repmat({[]},size(hasDefault));
                defaultValues(hasDefault) = {settableProps(hasDefault).DefaultValue};

                % Create custom parser for this class
                thisParser = inputParser;
                thisParser.KeepUnmatched = keepUnmatched;
                thisParser.FunctionName = className;

                % Add each public property to the parser
                for pIdx = 1:numel(publicPropNames)
                    thisParser.addParameter(publicPropNames{pIdx}, defaultValues{pIdx});
                end

                % Add this parser to the map
                allParsers(className) = thisParser;

            end %if allParsers.isKey(className)

        end %function

    end %methods


end %classdef