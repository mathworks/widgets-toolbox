classdef BaseMultiSessionApp < wt.apps.AbstractSessionApp
    % Base class for Widgets Toolbox app with multiple managed sessions
    
    % Copyright 2024 The MathWorks Inc.
    
    
    %% Properties
    properties (AbortSet, SetObservable)
        
        % Session data for the app (must be subclass of wt.model.BaseSession)
        Session
        
    end %properties


    %% Read-Only Properties
    properties (AbortSet, SetAccess=private)

        % Index of currently selected session
        SelectedSessionIndex double ...
            {mustBeInteger, mustBePositive, mustBeScalarOrEmpty} = []

    end %properties
    

    properties (AbortSet, Dependent, SetAccess=private)
        
        % Number of sessions loaded
        NumSessions (1,1) double

        % Currently selected session
        SelectedSession wt.model.BaseSession

        % Name of the currently selected session
        SelectedSessionName

        % File path of the 
        % SelectedSessionPath

    end %properties


    % Accessors
    methods
        
        function value = get.SelectedSessionIndex(app)
            value = app.SelectedSessionIndex;
            numSessions = app.NumSessions;
            if numSessions == 0
                value = [];
            elseif value > numSessions
                value = app.NumSessions;
            end
        end
        
        function value = get.NumSessions(app)
            value = numel(app.Session);
        end
        
        function value = get.SelectedSession(app)
            value = app.Session( app.SelectedSessionIndex );
        end
        
        function value = get.SelectedSessionName(app)
            session = app.SelectedSession;
            if ~isempty(session) && isvalid(session)
                value = session.FileName;
            else
                value = "";
            end
        end
        
        % function value = get.SelectedSessionPath(app)
        %     session = app.SelectedSession;
        %     if ~isempty(session) && isvalid(session)
        %         value = session.FilePath;
        %     else
        %         value = "";
        %     end
        % end
        
    end %methods


    %% Sealed Public methods
    methods (Sealed)
        
        function close(app)
            % Close the app

            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
            end

            if app.Debug
                disp("wt.apps.BaseMultiSessionApp.close " + class(app));
            end
            
            % Prompt to save existing sessions
            for session = app.Session
                isCancelled = promptToSaveSession(app, session);
                if isCancelled
                    return
                end %if
            end %for

        end %function

        
        function newSession(app)
            % Start a new session

            if app.Debug
                disp("wt.apps.BaseMultiSessionApp.newSession " + class(app));
            end
            
            % Freeze the figure with a progress dialog
            dlg = app.showIndeterminateProgress();
            cleanupObj = onCleanup(@()delete(dlg));
            
            % Instantiate the new session
            sessionObj = app.createNewSession();
            app.Session(end+1) = sessionObj;
            
            % Force an update prior to the progress dialog closing
            drawnow
            
        end %function
        
        
        function sessionPath = saveSession(app, useSaveAs, session)
            % Save the session to a file
            
            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
                useSaveAs (1,1) logical = false
                session wt.model.BaseSession = app.SelectedSession
            end

            if app.Debug
                disp("wt.apps.BaseMultiSessionApp.saveSession " + class(app));
            end

            % Call superclass method
            app.saveSession_Internal(app, useSaveAs, session);

            % Populate output
            sessionPath = session.FilePath;

        end %function


        function loadSession(app, sessionPath)
            % Load a session from a file

            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
                sessionPath (1,1) string = ""
            end

            if app.Debug
                disp("wt.apps.BaseMultiSessionApp.loadSession " + class(app));
            end

            % Call superclass internal load method
            session = app.loadSession_Internal(sessionPath);

            % Store the session
            % This also triggers app.update(), app.updateTitle()
            app.Session(end+1) = session;

        end %function

    end %methods


    %% Protected Methods
    methods (Access = protected)

        function updateTitle(app)
            % Update the app title, showing the session name and dirty flag

            if app.Debug
                disp("wt.apps.BaseMultiSessionApp.updateTitle " + class(app));
            end
            
            % Decide on the figure title
            if ~app.HasValidSession
                app.Figure.Name = app.Name;
            elseif app.SelectedSession.Dirty
                app.Figure.Name = app.Name + " - " + app.SelectedSessionName + " *";
            else
                app.Figure.Name = app.Name + " - " + app.SelectedSessionName;
            end
            
        end %function

    end %methods

end %classdef