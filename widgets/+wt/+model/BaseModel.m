classdef (Abstract) BaseModel < handle & ...
        matlab.mixin.SetGetExactNames & ...
        wt.mixin.DisplayNonScalarObjectAsTable
    % Base model class for apps that provides:
    %   PV pairs assignment on construction
    %   Display nonscalar arrays in table format
    %   Public PropertyChanged event for properties tagged as SetObservable
    %     to enable apps/widgets to listen to model changes
    %    

    % Copyright 2020-2023 The MathWorks, Inc.
    

    
    %% Events
    events
        
        % Triggered when SetObservable properties are changed
        PropertyChanged 

        % Triggered when an aggregated / nested model has changed
        ModelChanged
        
    end %events
    
    
    
    %% Internal Properties
    properties (Transient, NonCopyable, Hidden, SetAccess = private)
        
        % Listeners to public properties
        PropListeners

        % Listeners to any aggregated / nested handle class models
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


    methods (Access=protected)

        function attachModelListeners(obj,propNames)
            % Call this method to attach listeners to aggregated /
            % nested models that are handle class

            arguments
                obj (1,1) wt.model.BaseModel
                propNames (1,:) string
            end
                
            % Preallocate array of listeners
            newListeners = event.listener.empty(0,1);

            % Loop on each property requested, in case of multiple
            % properties having aggregated handle objects
            for thisProp = propNames

                % Get the model(s) to listen to
                aggregatedObjects = obj.(thisProp);

                % Skip this property if empty
                if isempty(aggregatedObjects)
                    continue
                end

                % These objects must be handle!
                allAreHandle = all(isa(aggregatedObjects,'handle'));
                assert(allAreHandle,...
                    "Expected %s to contain a handle class object.",...
                    thisProp);

                % Clear any invalid objects
                aggregatedObjects(~isvalid(aggregatedObjects)) = [];

                % Create listener to property changes within the model(s)
                newPropListeners = listener(aggregatedObjects,...
                'PropertyChanged',@(src,evt)onAggregatedPropertyChanged(obj,evt));

                % newPropListeners = listener(aggregatedObjects,...
                % 'PropertyChanged',@(src,evt)notify(obj,"PropertyChanged",evt));
                
                % Create listener to nested/aggregated models inside the
                % model(s)
                newModelListeners = listener(aggregatedObjects,...
                'ModelChanged',@(src,evt)onAggregatedModelChanged(obj,evt));

                % newModelListeners = listener(aggregatedObjects,...
                % 'ModelChanged',@(src,evt)notify(obj,"ModelChanged",evt));

                % Gather the new listeners together
                newListeners = vertcat(newPropListeners(:), newModelListeners(:));

            end %for

            % Store the results
            obj.AggregatedModelListeners = newListeners';

        end %function


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
                ParamNamesToSet = varargin(1:2:end);
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
            
            for idx = 1:numel(obj)
                mc = metaclass(obj(idx));
                isObservable = [mc.PropertyList.SetObservable];
                props = mc.PropertyList(isObservable);
                obj(idx).PropListeners = event.proplistener(obj(idx),props,...
                    'PostSet',@(h,e)onPropChanged(obj(idx),e) );
            end %for
            
        end %function
        
        
        function onPropChanged(obj,e)
            
            evt = wt.eventdata.PropertyChangedData(e.Source.Name, obj.(e.Source.Name));
            obj.notify('PropertyChanged',evt)
            
        end %function
        
        
        function onAggregatedPropertyChanged(obj,e)
            
            evt = wt.eventdata.ModelChangedData(...
                e.Source, e.Property, e.Value, {e.Source});
            obj.notify('ModelChanged',evt)
            
        end %function
        
        
        function onAggregatedModelChanged(obj,e)
            
            stack = horzcat({e.Source}, e.Stack);
            evt = wt.eventdata.ModelChangedData(...
                e.Model, e.Property, e.Value, stack);
            obj.notify('ModelChanged',evt)
            
        end %function
        
    end %methods
    
    
    
    %% Private methods
    methods (Access=private)
        
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
