classdef (Abstract, AllowedSubclasses = {?wt.apps.BaseSingleSessionApp, ...
        ?wt.apps.BaseMultiSessionApp}) AbstractSessionApp < wt.apps.BaseApp
    % Abstract base class for Widgets Toolbox app with 1+ sessions

    % Copyright 2024-2025 The MathWorks Inc.


    %% Abstract Public Properties
    properties (Abstract, AbortSet, SetObservable)

        % Session data for the app (must be subclass of wt.model.BaseSession)
        Session (1,:) wt.model.BaseSession

    end %properties


    %% Read-Only properties
    properties (Dependent, SetAccess = private)

        % Indicates a valid session is present
        HasValidSession (1,1) logical

        % Indicates if session is dirty
        Dirty (1,1) logical

    end %properties


    % Accessors
    methods

        function value = get.HasValidSession(app)
            value = ~isempty(app.Session) && any(isvalid(app.Session));
        end

        function value = get.Dirty(app)
            value = ~isempty(app.Session) && ...
                any( [app.Session(isvalid(app.Session)).Dirty] );
        end

    end %methods



    %% Internal properties
    properties (Transient, NonCopyable, Access = private)

        % Listener to Session property being set
        SessionSetListener event.listener

        % Listener to changes within Session object
        SessionChangedListener event.listener

        % Listeners to session marked clean/dirty
        SessionDirtyListener event.listener

    end %properties



    %% Abstract Methods (subclass must implement these)
    methods (Abstract)

        % Saves a session to a file, prompting the user if necessary
        sessionPath = saveSession(app, useSaveAs, session)

        % Loads a session from a file, prompting the user if necessary
        session = loadSession(app, sessionPath)

    end %methods

    methods (Abstract, Access = protected)

        % Creates a new session object for the app. It must return a
        % subclass of wt.model.BaseSession
        sessionObj = createNewSession(app)

    end %methods


    %% Constructor
    methods (Access = public)

        function app = AbstractSessionApp(varargin)
            % Constructor

            % Call superclass constructor
            app@wt.apps.BaseApp(varargin{:});

            % Attach listeners to Session being set
            app.SessionSetListener = listener(app,"Session","PostSet",...
                @(~,~)app.onSessionSet_Private());

        end %function

    end %methods


    %% Protected Methods
    methods (Access = protected)

        function onSessionSet(app)
            % This method is called when the Session property has changed,
            % such as a session being added or removed from the app. The
            % method may be overridden by the app's concrete class if
            % custom functionality is needed.

            % Show output if Debug is on
            app.displayDebugText();

            % Trigger updates
            if app.SetupComplete
                app.update();
                app.updateTitle();
            end

        end %function

        function onSessionChanged(app,~)
            % Triggered when a SetObservable property in the session has
            % changed. May be overridden for custom behavior using incoming
            % event data.

            % Show output if Debug is on
            app.displayDebugText();

            % Update the app
            if app.SetupComplete
                app.update();
                app.updateTitle();
            end

        end %function


        function onSessionDirty(app,~)
            % Triggered when the session's MarkedDirty event fires

            % Show output if Debug is on
            app.displayDebugText();

            % Update the title only
            % (prop change should have triggered update already)
            if app.SetupComplete
                app.updateTitle();
            end

        end %function


        function onSessionClean(app,~)
            % Triggered when the session's MarkedClean event fires

            % Show output if Debug is on
            app.displayDebugText();

            % Update the app
            if app.SetupComplete
                app.update();
                app.updateTitle();
            end

        end %function

    end %methods


    %% Protected Methods - Only for BaseSingleSessionApp & BaseMultiSessionApp
    methods (Access = {?wt.apps.BaseSingleSessionApp, ?wt.apps.BaseMultiSessionApp})

        function close_Internal(app)
            % Close the app

            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
            end

            % Show output if Debug is on
            app.displayDebugText();

            % Freeze the figure with a progress dialog
            dlg = app.showIndeterminateProgress("Closing");
            cleanupObj = onCleanup(@()delete(dlg));

            % Delete the app
            app.delete();

        end %function


        function isCancelled = closeSession_Internal(app, session)
            % Close a session

            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
                session wt.model.BaseSession
            end

            % Show output if Debug is on
            app.displayDebugText();

            % Prompt to save existing session if dirty
            isCancelled = promptToSaveSession(app, session);

            % Close the session
            if ~isCancelled

                % Remove session from the app
                isMatch = app.Session == session;
                app.Session(isMatch) = [];

                % Delete the session
                delete(session);

            end %if

        end %function


        function saveSession_Internal(app, useSaveAs, session)
            % Save the session to a file

            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
                useSaveAs (1,1) logical
                session wt.model.BaseSession
            end

            % Show output if Debug is on
            app.displayDebugText();

            % Check/prep the session path
            sessionPath = app.checkSessionPath_Internal(session);

            % Prompt for "save as" if needed
            if useSaveAs || ~isfile(sessionPath)
                sessionPath = app.promptToSaveAs(sessionPath);
            end

            % Save the file (unless path is empty indicating cancel)
            if strlength(sessionPath)

                % Freeze the figure with a progress dialog
                dlg = app.showIndeterminateProgress("Saving Session");
                cleanupObj = onCleanup(@()delete(dlg));

                % Save the session
                % This will trigger update if path updates and/or session
                % is no longer dirty
                session.save(sessionPath);

                % Update the title
                app.updateTitle()

            end %if strlength(sessionPath)

        end %function


        function sessionPath = checkSessionPath_Internal(app, session)
            % Check / prepare the session path

            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
                session wt.model.BaseSession
            end

            % Get the session info
            sessionPath = session.FilePath;
            sessionFolder = fileparts(sessionPath);
            sessionName = session.FileName;
            lastFolder  = app.LastFolder;

            % If file does not already exist, make default path
            if isfile(sessionPath)
                % Do nothing special
            elseif isfolder(sessionFolder)
                % File not found but folder was
                sessionPath = fullfile(sessionFolder,sessionName);
            else
                % Neither file nor folder give, so use defaults
                sessionPath = fullfile(lastFolder,sessionName);
            end

        end %function


        function session = loadSession_Internal(app, sessionPath)
            % Load a session from a file

            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
                sessionPath (1,1) string = ""
            end

            % Show output if Debug is on
            app.displayDebugText();

            % Unless a file was already specified, prompt to load
            if ~isfile(sessionPath)
                sessionPath = app.promptToLoad();
            end

            % Check the file name of this session
            [~,sessionFileName,sessionFileExt] = fileparts(sessionPath);
            sessionFileName = sessionFileName + sessionFileExt;
            if isempty(app.Session)
                isAlreadyOpen = false;
            else
                existingSessionFiles = vertcat( app.Session.FileName );
                isAlreadyOpen = any( matches(sessionFileName, ...
                    existingSessionFiles, "IgnoreCase", true) );
            end

            % How should we proceed?
            if isAlreadyOpen

                % Return an empty session of correct type
                session = app.getEmptySession();

                % Throw an error
                title = "Load Session";
                message = sprintf("""%s"" is already open.", ...
                    sessionFileName);
                app.throwError(message, title);

            elseif isfile(sessionPath)
                % Load the file

                % Freeze the figure with a progress dialog
                dlg = app.showIndeterminateProgress("Loading Session");
                cleanupObj = onCleanup(@()delete(dlg));

                % Load the session
                try
                    session = wt.model.BaseSession.open(sessionPath);
                catch err
                    session = app.getEmptySession();
                    app.throwError(err)
                end

            else

                % Return an empty session of correct type
                session = app.getEmptySession();

            end %if

        end %function


        function isCancelled = promptToSaveSession(app, session)
            % Prompt the user to save their session before losing it

            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
                session wt.model.BaseSession = app.Session
            end

            % Show output if Debug is on
            app.displayDebugText();

            % Default output
            isCancelled = false;

            % Don't save and return now if session is invalid or clean
            if ~isscalar(session) || ~isvalid(session) || ~session.Dirty
                return
            end

            % Prompt whether to save
            message = sprintf("Save changes to '%s'?",session.FileName);
            title = "Save Session";
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

    end %methods


    %% Sealed Protected Methods
    methods (Sealed, Access = protected)

        function session = getEmptySession(app)
            % Returns an empty session of the same type as Session property

            session = app.Session(1,[]);

        end %function

    end %methods


    %% Private Methods
    methods (Access = private)

        function onSessionChanged_Private(app,evt)
            % Triggered when attached Session has a ModelChanged event

            % Show output if Debug is on
            app.displayDebugText(evt);

            % Call the app's session changed method
            app.onSessionChanged(evt);

        end %function


        function onSessionSet_Private(app)
            % Triggered after Session property is set

            % Show output if Debug is on
            app.displayDebugText();

            app.SessionChangedListener = listener(app.Session,...
                'ModelChanged',@(~,evt)app.onSessionChanged_Private(evt));

            app.SessionDirtyListener = [
                listener(app.Session,'MarkedDirty',@(~,evt)app.onSessionDirty(evt))
                listener(app.Session,'MarkedClean',@(~,evt)app.onSessionClean(evt))
                ];

            % Call the app's session set method
            app.onSessionSet();

        end %function

    end %methods

end %classdef