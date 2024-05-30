classdef (Abstract) BaseModel < handle & ...
        matlab.mixin.SetGetExactNames & ...
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
    properties (Transient, NonCopyable, Hidden)

        % Toggle true in each instance to enable debugging display
        Debug (1,1) logical = false

        % Listing of properties containing aggregated BaseModel classes to
        % listen for hierarchical ModelChanged events
        AggregatedModelProperties (1,:) string

    end %properties

    properties (Transient, NonCopyable, Hidden, SetAccess = private)

        % Listeners to public properties
        PropListeners


        % Listeners to any aggregated / nested handle class models
        % AggregatedModelListeners
        AggregatedModelListeners

    end %properties


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

        end %function

    end %methods



    %% Protected Methods
    methods (Access = protected)

        % This method is similar to
        % matlab.io.internal.mixin.HasPropertiesAsNVPairs, but this one
        % generally performs faster.

        function varargout = assignPVPairs(obj,varargin)
            % Assign the specified property-value pairs

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

                % Which properties are aggregated BaseModel classes?
                if isempty(thisObj.AggregatedModelProperties)
                    propNames = string({propInfo.Name});
                    fcn = @(p)isa(thisObj.(p),"wt.model.BaseModel");
                    isAggModel = arrayfun(fcn, propNames);
                    thisObj.AggregatedModelProperties = propNames(isAggModel);
                end

                % Create listeners to aggregated model classes that may have
                % property change events
                thisObj.attachModelListeners();

            end %for

        end %function


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
            % newModelListeners = repmat({event.listener.empty(0,1)}, numProps, 1);
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
                newPropListeners{idx} = event.listener(aggregatedObjects,...
                    'ModelChanged',@(src,evt)onModelChanged(obj,evt));

            end %for

            % Flatten the lists
            newPropListeners = vertcat(newPropListeners{:});

            % Store the results
            obj.AggregatedModelListeners = newPropListeners;

        end %function


        function onPropChanged(obj,evt)

            arguments
                obj (1,1) wt.model.BaseModel
                evt (1,1) event.PropertyEvent
            end

            if obj.Debug
                disp("wt.model.BaseModel.onPropChanged " + ...
                    class(obj) + "  Model: " + class(evt.AffectedObject) + ...
                    " Prop: " + evt.Source.Name);
            end

            % Prepare eventdata
            evtOut = wt.eventdata.ModelChangedData;
            evtOut.Property = evt.Source.Name;
            evtOut.Model = evt.AffectedObject;
            evtOut.Value = evtOut.Model.(evtOut.Property);
            evtOut.Stack = {evt.Source};

            % Revise listeners for model changes given the new value
            if isa(evtOut.Value, "wt.model.BaseModel")
                evtOut.Model.attachModelListeners();
            end

            % Notify listeners
            obj.notify('PropertyChanged',evtOut)

            % Call onModelChanged method
            obj.onModelChanged(evtOut);

        end %function


        function onModelChanged(obj,evt)
        % Runs on property changes to this class or an aggregated BaseModel
        % class

            arguments
                obj (1,1) wt.model.BaseModel
                evt (1,1) wt.eventdata.ModelChangedData
            end

            % if ~isa(evt, "wt.eventdata.ModelChangedData")
            %     if obj.Debug()
            %         disp("wt.model.BaseModel.onModelChanged " + ...
            %             class(obj) + "  evt is not of type 'wt.eventdata.ModelChangedData'. Skipping...");
            %     end
            %     return
            % end

            if obj.Debug
                disp("wt.model.BaseModel.onModelChanged " + ...
                    class(obj) + "  Model: " + class(evt.Model) + " Prop: " + evt.Property);
            end

            % Prepare eventdata
            evtOut = wt.eventdata.ModelChangedData;
            evtOut.Model = evt.Model;
            evtOut.Property = evt.Property;
            evtOut.Value = evt.Value;
            evtOut.Stack = horzcat({evt.Source}, evt.Stack);

            % Notify listeners
            obj.notify('ModelChanged',evtOut)

        end %function

    end %methods



    %% Private methods
    methods (Access = private)


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