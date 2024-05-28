classdef BaseSession < wt.model.BaseModel
    % Base session class for app sessions
    %
    % Create a subclass of wt.model.BaseSession to store your app's session
    % data. Any properties tagged with the "SetObservable" attribute will
    % trigger a public event "PropertyChanged" when value is set. The app
    % will listen for these changes.
    
    % Copyright 2020-2024 The MathWorks, Inc.
    

    %% Events
    events
        
        % Triggered when dirty flag toggles
        SessionMarkedDirty 

        % Triggered when dirty flag toggles
        SessionMarkedClean 
        
    end %events

    
    %% Properties
    properties (Dependent, SetAccess = immutable)
        
        % FileName of the session (dependent on FileName)
        FileName (1,1) string
        
    end %properties
    
    
    properties (AbortSet, Transient, SetObservable)
        
        % Path to store the session file
        FilePath (1,1) string
        
        % Indicates modifications have not been saved
        Dirty (1,1) logical = false
        
    end %properties
    
    
    properties (AbortSet, SetObservable)
        
        % Description of the session (optional)
        Description (1,1) string
        
    end %properties

    
    % Accessors
    methods
        function set.Dirty(obj,value)
            obj.Dirty = value;
            if value
                obj.notify("SessionMarkedDirty")
            else
                obj.notify("SessionMarkedClean")
            end
        end
    end
    
    
    %% Public methods (subclass may override these)
    methods
               
        function save(session)
            % Save a session object into a MAT file
            
            if ~strlength(session.FilePath)
                error('Session FilePath is empty.');
            end
            save(session.FilePath,'session');
            
        end %function
        
    end %methods
    
    
    %% Public static methods
    methods (Static, Sealed)
        
        function sessionObj = open(sessionPath)
            % Load a session object from a MAT file - subclass may override
            
            contents = load(sessionPath,"session");
            sessionObj = contents.session;
            
        end %function
        
    end %methods
    

    %% Protected methods (subclass may override these)
    methods (Access = protected)

        function onPropChanged(obj,e)
            % Triggered when SetObservable properties have changed
            
            disp("wt.model.BaseSession.onPropChanged");
            disp(evt);

            % Mark the session dirty
            obj.Dirty = true;
            
            % Call superclass method to notify PropertyChanged event
            obj.onPropChanged@wt.model.BaseModel(e);
            
        end %function


        function onAggregatedModelChanged(obj,e)
            % Triggered when nested models' SetObservable properties have changed
            
            disp("wt.model.BaseSession.onAggregatedPropertyChanged");
            disp(evt);

            % Mark the session dirty
            obj.Dirty = true;
            
            % Call superclass method to notify PropertyChanged event
            obj.onAggregatedModelChanged@wt.model.BaseModel(e);
            
        end %function
        
    end %methods
    
    
    %% Accessors
    methods
        
        function value = get.FileName(obj)
            if strlength(obj.FilePath)
                [~,name,ext] = fileparts(obj.FilePath);
                value = string(name) +  ext;
            else
                value = "untitled";
            end
        end %function
        
    end %methods
    
    
end % classdef
