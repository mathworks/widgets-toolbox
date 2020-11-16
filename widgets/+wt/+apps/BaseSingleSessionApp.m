classdef (Abstract) BaseSingleSessionApp < wt.apps.BaseApp
    % Base class for Widgets Toolbox app with a managed single session
    
    % Copyright 2020 The MathWorks Inc.
    
    
    %% Properties
    
    properties (AbortSet)
        
        % Session data for the app (must be subclass of wt.model.BaseSession)
        Session (1,1) wt.model.BaseSession {mustBeScalarOrEmpty} ...
            = wt.model.BaseSession;
        
    end %properties
    
    
    
    %% Internal properties
    properties (Dependent, SetAccess = immutable)
        
        % Indicates if any session is dirty
        Dirty (1,1) logical
        
        % Last used folder (for file operations)
        HasValidSession (1,1) logical
        
    end %properties
    
    
    properties (Access = private)
        
        % Listener to changes within Session object
        SessionChangedListener event.listener
        
    end %properties
    
    
    
    %% Abstract Methods (subclass must implement these)
    methods(Abstract, Access = protected)
        
        % Creates a new session object for the app. It must return a
        % subclass of wt.model.BaseSession
        sessionObj = createNewSession(app)
        
    end %methods
    
    
    
    %% Public methods
    methods (Sealed)
        
        function newSession(app)
            % Start a new session
            
            % If an existing session is dirty, give the user a chance to
            % save before loading another session
            if app.Dirty
                isCancelled = promptToSaveFirst(app);
                if isCancelled
                    return;
                end
            end %if app.Dirty
            
            % Instantiate the new session
            sessionObj = app.createNewSession();
            app.Session = sessionObj;
            app.updateTitle();
            
        end %function
        
        
        function sessionPath = saveSession(app, useSaveAs)
            % Save the session to a file
            
            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
                useSaveAs (1,1) logical = false
            end
            
            % We must have a session to save!
            if ~app.HasValidSession
                error("Session does not exist.");
            end
            
            % Get the session info
            sessionPath = app.Session.FilePath;
            sessionName = app.Session.FileName;
            lastFolder  = app.LastFolder;
            
            % Does the session file already exist?
            fileExists = exist(sessionPath,"file");
            if ~fileExists
                % It doesn't exist - prompt with a default path
                useSaveAs = true;
                sessionPath = fullfile(lastFolder,sessionName);
            end
            
            % Prompt for "save as" if needed
            if useSaveAs
                sessionPath = app.promptToSaveAs(sessionPath);
                if ~isempty( sessionPath )
                    app.Session.FilePath = sessionPath;
                end
            end
            
            % Save the file
            if strlength(sessionPath)
                app.Session.save();
                app.Session.FilePath = sessionPath;
                app.Session.Dirty = false;
                app.updateTitle();
            end
            
        end %function
        
        
        function loadSession(app, sessionPath)
            % Load a session from a file
            
            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
                sessionPath (1,1) string = ""
            end
            
            % If an existing session is dirty, give the user a chance to
            % save before loading another session
            if app.Dirty
                isCancelled = promptToSaveFirst(app);
                if isCancelled
                    return;
                end
            end %if app.Dirty
            
            % Unless a file was already specified, prompt to load
            if ~exist(sessionPath,"file")
                sessionPath = app.promptToLoad();
            end
            
            % Load the file
            if strlength(sessionPath)
                sessionObj = wt.model.BaseSession.open(sessionPath);
                sessionObj.FilePath = sessionPath;
                app.Session = sessionObj;
                app.updateTitle();
            end
            
        end %function
        
        
        function isCancelled = promptToSaveFirst(app)
            % Prompt the user to save a file
            
            % Default output
            isCancelled = false;
            
            % Prompt whether to save
            message = sprintf("Save changes to '%s'?",app.Session.FileName);
            title = "Load Session";
            selection = app.promptYesNoCancel(message, title);
            
            % If Yes, prompt to save the existing session first
            if selection == "Yes"
                sessionSavePath = app.saveSession();
                if ~strlength(sessionSavePath)
                    isCancelled = true;
                end
            elseif selection == "Cancel"
                isCancelled = true;
            end
            
        end %function
        
        
        function close(app)
            % Triggered on figure closed
            
            % If an existing session is dirty, give the user a chance to
            % save before loading another session
            if app.Dirty
                isCancelled = promptToSaveFirst(app);
                if isCancelled
                    return;
                end
            end %if app.Dirty
            
            app.delete();
            
        end %function
        
    end %methods
    
    
    
    %% Protected Methods
    methods (Access=protected)
        
        function setup_internal(app)
            % Preform internal pre-setup necessary
            
            % Instantiate initial session
            app.Session = createNewSession(app);
            
        end %function
        
        
        function updateTitle(app)
            % Update the app title, showing the session name and dirty flag
            
            if ~app.HasValidSession
                app.Figure.Name = app.Name;
            elseif app.Session.Dirty
                app.Figure.Name = app.Name + " - " + app.Session.FileName + " *";
            else
                app.Figure.Name = app.Name + " - " + app.Session.FileName;
            end
            
        end %function
        
    end %methods
    
    
    
    %% Private Methods
    methods (Access = private)
        
        function onSessionChanged(app,~)
            % Triggered when a SetObservable property in the session has
            % changed. May be overridden for custom behavior using incoming
            % event data.
            
            % Trigger an update
            app.update();
            
        end %function
        
        
        function onSessionChanged_private(app,e)
        
            % Update the app title
            app.updateTitle();
            
            % Call the app's session changed method
            app.onSessionChanged(e);
            
        end %function
        
        
        function attachSessionListeners(app)
            
            app.SessionChangedListener = event.listener(app.Session,...
                'PropertyChanged',@(h,e)onSessionChanged_private(app,e));
            
        end %function
        
    end %methods
    
    
    
    %% Accessors
    methods
        
        function set.Session(app,value)
            app.Session = value;
            app.attachSessionListeners();
            if app.SetupComplete
                app.update();
            end
        end
        
        function value = get.HasValidSession(app)
            value = ~isempty(app.Session) && isvalid(app.Session);
        end
        
        function value = get.Dirty(app)
            value = app.HasValidSession && app.Session.Dirty;
        end
        
    end %methods
    
    
end %classdef
