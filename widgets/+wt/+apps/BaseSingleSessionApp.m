classdef (Abstract) BaseSingleSessionApp < wt.apps.AbstractSessionApp
    % Base class for Widgets Toolbox app with a managed single session

%   Copyright 2020-2025 The MathWorks Inc.


    %% Properties
    properties (AbortSet, SetObservable)

        % Session data for the app (must be subclass of wt.model.BaseSession)
        Session

    end %properties


    % Accessors
    methods

        function set.Session(app,value)
            mustBeScalarOrEmpty(value); % Single Session only
            app.Session = value;
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

            % Prompt to save existing session
            isCancelled = promptToSaveSession(app, app.Session);
            if isCancelled
                return
            end %if

            % Close the app
            app.close_Internal();

        end %function


        function session = newSession(app)
            % Start a new session

            % Show output if Debug is on
            app.displayDebugText();

            % Prompt to save existing session
            isCancelled = promptToSaveSession(app, app.Session);
            if isCancelled
                session = app.getEmptySession();
                return
            end %if

            % Freeze the figure with a progress dialog
            dlg = app.showIndeterminateProgress();
            cleanupObj = onCleanup(@()delete(dlg));

            % Instantiate the new session
            session = app.createNewSession();

            % Store the session
            % This also triggers app.update(), app.updateTitle()
            app.Session = session;

        end %function


        function sessionPath = saveSession(app, useSaveAs)
            % Save the session to a file

            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
                useSaveAs (1,1) logical = false
                %session wt.model.BaseSession = app.Session
            end

            % Show output if Debug is on
            app.displayDebugText();

            % Use the stored sessoin
            session = app.Session;

            % Call superclass internal save method
            app.saveSession_Internal(useSaveAs, session);

            % Populate output
            sessionPath = session.FilePath;

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

            % Prompt to save existing session
            isCancelled = promptToSaveSession(app, app.Session);
            if isCancelled
                session = app.getEmptySession();
                return
            end %if

            % Call superclass internal load method
            session = app.loadSession_Internal(sessionPath);

            % If successful, store the session
            % This also triggers app.update(), app.updateTitle()
            if isscalar(session) && isvalid(session)
                app.Session = session;
            end

        end %function

    end %methods


    %% Sealed Protected methods
    methods (Sealed, Access = protected)

        function setup_internal(app)
            % Preform internal pre-setup necessary

            % Call superclass method
            app.setup_internal@wt.apps.AbstractSessionApp();

            % Show output if Debug is on
            app.displayDebugText();

            % Instantiate initial session
            app.Session = app.createNewSession();

        end %function

    end %methods


    %% Protected Methods
    methods (Access = protected)

        function updateTitle(app)
            % Update the app title, showing the session name and dirty flag

            % Show output if Debug is on
            app.displayDebugText();

            % Decide on the figure title
            if ~app.HasValidSession
                app.Figure.Name = app.Name;
            elseif app.Session.Dirty
                app.Figure.Name = app.Name + " - " + app.Session.FileName + " *";
            else
                app.Figure.Name = app.Name + " - " + app.Session.FileName;
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

                % BaseSingleSessionApp Properties
                sessionTitle = "        ------ BaseSingleSessionApp Properties ------";
                sessionProperties = setdiff(...
                    properties("wt.apps.BaseSingleSessionApp"), usedProps);
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