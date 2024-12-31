classdef BaseSession < wt.model.BaseModel
    % Base session class for app sessions
    %
    % Create a subclass of wt.model.BaseSession to store your app's session
    % data. Any properties tagged with the "SetObservable" attribute will
    % trigger a public event "PropertyChanged" when value is set. The app
    % will listen for these changes.

    % Copyright 2020-2025 The MathWorks, Inc.


    %% Events
    events

        % Triggered when dirty flag toggles
        MarkedDirty

        % Triggered when dirty flag toggles
        MarkedClean

    end %events


    %% Properties
    properties (Dependent, SetAccess = private)

        % FileName of the session (dependent on FileName)
        FileName (1,1) string

    end %properties


    properties (AbortSet, SetObservable)

        % Path to store the session file
        FilePath (1,1) string

        % Description of the session (optional)
        Description (1,1) string

    end %properties


    properties (AbortSet, Transient)

        % Indicates modifications have not been saved
        Dirty (1,1) logical = false

    end %properties


    % Accessors
    methods
        function set.Dirty(obj,value)

            if obj.Debug
                disp("wt.model.BaseSession.set.Dirty = " + string(value));
            end

            obj.Dirty = value;
            if value
                obj.notify("MarkedDirty")
            else
                obj.notify("MarkedClean")
            end
        end
    end


    %% Public methods (subclass may override these)
    methods

        function save(session, filePath)
            % Save a session object into a MAT file

            % Define arguments
            arguments
                session (1,1) wt.model.BaseSession
                filePath (1,1) string = session.FilePath
            end

            if session.Debug
                disp("wt.model.BaseSession.save");
            end

            if ~strlength(filePath)
                error("Session FilePath is empty.");
            end

            session.FilePath = filePath;
            session.Dirty = false;
            save(filePath,'session');

        end %function

    end %methods


    %% Public static methods
    methods (Static, Sealed)

        function session = open(sessionPath)
            % Load a session object from a MAT file

            % Attempt to load
            try
                contents = load(sessionPath,"session");
            catch
                % Throw an error
                id = "wt:BaseSession:InvalidSessionFile";
                msg = "Invalid session file: %s";
                error(id, msg, sessionPath);
            end

            % Is it a valid file?
            if isfield(contents,'session') ...
                    && isa(contents.session, "wt.model.BaseSession") ...
                    && isscalar(contents.session)

                % Get the session
                session = contents.session;

                % Update file path if changed
                session.FilePath = sessionPath;
                session.Dirty = false;

            else

                % Throw an error
                id = "wt:BaseSession:InvalidSessionFile";
                msg = "Invalid session file: %s";
                error(id, msg, sessionPath);

            end

        end %function

    end %methods


    % %% Hidden methods
    % methods (Hidden)
    % 
    %     function setFilePathSilently(obj, filePath)
    %         % Set FilePath without triggering change notifications
    % 
    %         % Define arguments
    %         arguments
    %             obj (1,1) wt.model.BaseModel
    %             filePath (1,1) string
    %         end
    % 
    %         oldValue = obj.EnableChangeListeners;
    %         obj.EnableChangeListeners = false;
    %         obj.FilePath = filePath;
    %         obj.EnableChangeListeners = oldValue;
    % 
    %     end %function
    % 
    % end %methods


    %% Protected methods (subclass may override these)
    methods (Access = protected)

        function name = getDefaultName(obj)
            % Defines what the default name should be. A subclass may
            % override this to customize the default name.

            [~,name,~] = fileparts(obj.FileName);

        end %function

    end %methods


    %% Private methods
    methods (Access = ?wt.model.BaseSession)
        
        function onModelChanged(obj,evt)
            % Triggered when the Session or any aggregated BaseModel
            % classes have triggered a ModelChanged event (typically when
            % SetObservable properties have changed)

            if obj.Debug
                classStack = [class(obj), evt.ClassStack];
                disp("wt.model.BaseSession.onModelChanged " + ...
                    "    Model: " + class(evt.Model) + ...
                    "    Prop: " + evt.Property + ...
                    "    ClassStack: " + join(classStack, " <- ") + ...
                    "    (sets Session.Dirty = true)");
            end

            % Mark the session dirty
            obj.Dirty = true;

            % Call superclass method to notify PropertyChanged event
            obj.onModelChanged@wt.model.BaseModel(evt);

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
