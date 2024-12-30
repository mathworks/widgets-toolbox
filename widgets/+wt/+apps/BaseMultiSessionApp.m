classdef BaseMultiSessionApp < wt.apps.AbstractSessionApp
    % Base class for Widgets Toolbox app with multiple managed sessions

    % Copyright 2024 The MathWorks Inc.


    %% Properties
    properties (AbortSet, SetObservable)

        % Session data for the app (must be subclass of wt.model.BaseSession)
        Session

    end %properties


    %% Read-Only Properties
    properties (AbortSet, SetAccess = private)

        % Index of currently selected session
        SelectedSessionIndex double ...
            {mustBeInteger, mustBePositive, mustBeScalarOrEmpty} = []

    end %properties


    properties (AbortSet, Dependent, SetAccess = private)

        % Number of sessions loaded
        NumSessions (1,1) double

        % Currently selected session
        SelectedSession wt.model.BaseSession

        % Name of the currently selected session
        SelectedSessionName

        % File path of the currently selected session
        SelectedSessionPath

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

        function value = get.SelectedSessionPath(app)
            session = app.SelectedSession;
            if ~isempty(session) && isvalid(session)
                value = session.FilePath;
            else
                value = "";
            end
        end

    end %methods


    %% Sealed Public methods
    methods (Sealed)

        function close(app)
            % Close the app

            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
            end

            % Show output if Debug is on
            app.displayDebugText();

            % Prompt to save existing sessions
            for session = app.Session
                isCancelled = promptToSaveSession(app, session);
                if isCancelled
                    return
                end %if
            end %for

            % Close the app
            app.close_Internal();

        end %function


        function session = newSession(app)
            % Start a new session

            % Show output if Debug is on
            app.displayDebugText();

            % Freeze the figure with a progress dialog
            dlg = app.showIndeterminateProgress();
            cleanupObj = onCleanup(@()delete(dlg));

            % Instantiate the new session
            session = app.createNewSession();

            % Store the session
            % This also triggers app.update(), app.updateTitle()
            if isempty(app.Session)
                app.Session = session;
            else
                app.Session(end+1) = session;
                % Don't select by default, but concrete app may do this
            end

        end %function


        function sessionPath = saveSession(app, useSaveAs, session)
            % Save the session to a file

            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
                useSaveAs (1,1) logical = false
                session wt.model.BaseSession = app.SelectedSession
            end

            % Show output if Debug is on
            app.displayDebugText();

            % Confirm scalar session
            if isscalar(session)

                % Call superclass method
                app.saveSession_Internal(useSaveAs, session);

                % Populate output
                sessionPath = session.FilePath;

            else

                % Throw an error
                title = "Save Session";
                message = "No session was selected.";
                app.throwError(message, title);

                sessionPath = "";

            end %if

        end %function


        function session = loadSession(app, sessionPath)
            % Load a session from a file

            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
                sessionPath (1,1) string = ""
            end

            % Show output if Debug is on
            app.displayDebugText();

            % Call superclass internal load method
            session = app.loadSession_Internal(sessionPath);

            % Store the session
            % This also triggers app.update(), app.updateTitle()
            if ~isscalar(session)
                % User cancelled
                return
            elseif isempty(app.Session)
                app.Session = session;
            else
                app.Session(end+1) = session;
                % Don't select by default, but concrete app may do this
            end

        end %function


        function closeSession(app, session)
            % Close the specified session

            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
                session wt.model.BaseSession = app.SelectedSession
            end

            % Show output if Debug is on
            app.displayDebugText();

            % Exit if session is empty
            if isempty(session) || ~isvalid(session)
                return
            end

            % Call superclass internal close method
            isCancelled = app.closeSession_Internal(session);

            % Deselect the closed session
            if ~isCancelled
                if isequal(app.SelectedSession, session)
                    emptySession = app.getEmptySession();
                    app.selectSession(emptySession)
                end
            end

        end %function


        function selectSession(app, session)
            % Select the specified session

            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
                session wt.model.BaseSession
            end

            % Was a scalar session given?
            if isscalar(session)

                % Which index is the session?
                selIdx = find(session == app.Session, 1);

                % Select it
                app.SelectedSessionIndex = selIdx;

            else

                % Empty selection
                app.SelectedSessionIndex = [];

            end

            % Update the title
            app.updateTitle()

        end %function

    end %methods


    %% Sealed Protected methods
    methods (Sealed, Access = protected)

        function setup_internal(app)
            % Preform internal pre-setup necessary

            % Show output if Debug is on
            app.displayDebugText();

            % Instantiate empty session to start
            session = app.createNewSession();
            app.Session = session(1,[]);

        end %function

    end %methods


    %% Protected Methods
    methods (Access = protected)

        function updateTitle(app)
            % Update the app title, showing the session name and dirty flag

            % Show output if Debug is on
            app.displayDebugText();

            % Decide on the figure title
            session = app.SelectedSession;
            if isempty(session) || ~isvalid(session)
                app.Figure.Name = app.Name;
            elseif session.Dirty
                app.Figure.Name = app.Name + " - " + session.FileName + " *";
            else
                app.Figure.Name = app.Name + " - " + session.FileName;
            end

        end %function

    end %methods


    %% Display Customization
    methods (Access = protected)

        function propGroups = getPropertyGroups(app)
            % Customize how the properties are displayed

            import matlab.mixin.util.PropertyGroup

            persistent pGroups
            if isempty(pGroups)

                % BaseApp properties
                baseAppTitle = "        ------ BaseApp Properties ------";
                baseAppProperties = properties("wt.apps.BaseApp");
                usedProps = baseAppProperties;

                % BaseMultiSessionApp Properties
                sessionTitle = "        ------ BaseMultiSessionApp Properties ------";
                sessionProperties = setdiff(...
                    properties("wt.apps.BaseMultiSessionApp"), usedProps);
                usedProps = [baseAppProperties; sessionProperties];

                % Get properties for concrete class
                mc = metaclass(app);
                propInfo = mc.PropertyList;

                % Filter out used properties
                [~,idxA] = setdiff({propInfo.Name}, usedProps, "stable");
                propInfo = propInfo(idxA);

                % Split out read-only properties
                getInfo = {propInfo.GetAccess};
                setInfo = {propInfo.SetAccess};
                isPublicGet = cellfun(@(x)isequal(x,'public'), getInfo);
                isPublicSet = cellfun(@(x)isequal(x,'public'), setInfo);
                concPublicSetProps = {propInfo(isPublicGet & isPublicSet).Name};
                concProtectedSetProps = {propInfo(isPublicGet & ~isPublicSet).Name};

                % Set titles
                concPublicTitle = "        ------ " + app.Name + " Public Properties ------";
                concProtectedTitle = "        ------ " + app.Name + " Read-Only Properties ------";

                pGroups = [
                    PropertyGroup(concProtectedSetProps, concProtectedTitle)
                    PropertyGroup(concPublicSetProps, concPublicTitle)
                    PropertyGroup(baseAppProperties, baseAppTitle)
                    PropertyGroup(sessionProperties, sessionTitle)
                    ];

            end %if

            propGroups = pGroups;

        end %function

    end %methods


end %classdef