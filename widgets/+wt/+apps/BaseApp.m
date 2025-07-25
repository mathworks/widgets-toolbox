classdef BaseApp < matlab.apps.AppBase & ...
        matlab.mixin.SetGetExactNames & ...
        matlab.mixin.CustomDisplay & ...
        wt.mixin.ErrorHandling
    % Base class for Widgets Toolbox apps

    % Copyright 2020-2025 The MathWorks, Inc.


    %% Properties
    properties (AbortSet)

        % Name of the app
        Name (1,1) string = "My App"

    end %properties


    properties (SetAccess = protected)

        % Model class for App preferences
        %(may subclass wt.model.Preferences to add more prefs)
        Preferences (1,1) wt.model.Preferences

        % Name of group to store preferences (defaults to class name)
        PreferenceGroup (1,1) string

    end %properties


    properties (AbortSet, Dependent)

        % Position of the app window
        Position

        % Visibility of the app window
        Visible

        % State of the app window
        WindowState

    end %properties


    % Accessors
    methods

        function set.Name(app,value)
            app.Name = value;
            app.updateTitle();
        end


        function value = get.PreferenceGroup(app)
            value = app.PreferenceGroup;
            if ~strlength(value)
                value = class(app);
            end
            value = matlab.lang.makeValidName(value);
        end


        function value = get.Position(app)
            value = app.Figure.Position;
        end

        function set.Position(app,value)
            app.Figure.Position = value;
        end


        function value = get.Visible(app)
            value = app.Figure.Visible;
        end

        function set.Visible(app,value)
            app.Figure.Visible = value;
        end


        function value = get.WindowState(app)
            value = app.Figure.WindowState;
        end

        function set.WindowState(app,value)
            app.Figure.WindowState = value;
        end

    end %methods



    %% Internal properties
    properties (Transient, NonCopyable, SetAccess = immutable)

        % Figure window of the app
        Figure matlab.ui.Figure

        % Primary grid to place contents
        Grid matlab.ui.container.GridLayout

    end %properties


    properties (Transient, NonCopyable, SetAccess = protected)

        % Last used folder (for file operations)
        LastFolder (1,1) string = pwd

        % Is setup complete?
        SetupComplete (1,1) logical = false;

    end %properties



    %% Abstract methods (subclass must implement these)
    methods (Abstract, Access = protected)

        setup(app)
        update(app)

    end %methods



    %% Debugging
    properties (Transient)

        % Toggle true to enable debugging display
        Debug (1,1) logical = false

    end %methods


    methods

        function forceUpdate(app)
            % Forces update to run (For debugging only!)

            app.update();

            drawnow

        end %function

    end %methods



    %% Constructor / destructor
    methods (Access = public)

        function app = BaseApp(varargin)
            % Constructor
            
            % Create the figure and hide until components are created
            app.Figure = uifigure( ...
                'AutoResizeChildren','off',...
                'Units','pixels', ...
                'DeleteFcn',@(h,e)delete(app), ...
                'CloseRequestFcn',@(h,e)close(app), ...
                'Visible','off');

            % Create MainGridLayout
            app.Grid = uigridlayout(app.Figure,[1 1]);
            app.Grid.Padding = [0 0 0 0];

            % Check for preference input and assign it first, in case
            % Preferences was subclassed. Can also set Visible here if
            % desired to do earlier.
            [prefArgs, remArgs] = app.splitArgs(...
                ["Visible", "PreferenceGroup", "Preferences"], varargin{:});
            if ~isempty(prefArgs)
                set(app, prefArgs{:});
            end

            % Retrieve preferences
            app.loadPreferences();

            % Load last figure position
            % Note app.Figure.Position is inner position, where
            % app.Position is outer position. Inner position is the same
            % regardless of any menubar or toolbar, while outer position
            % changes if either is added. Use inner position for this
            % purpose so it does not depend on if/when any menubar or
            % toolbar is added to the figure.
            app.Figure.Position = app.getPreference('Position',[100 100 1000 700]);

            % Ensure it's on screen
            app.moveOnScreen();

            % Set up components
            app.preSetup(); % for pre-setup customization, like a splash screen
            app.setup_internal(); % sealed, for session subclasses
            app.setup(); % create the components
            app.postSetup(); % for post-setup customization

            % Set any P-V pairs
            if ~isempty(remArgs)
                set(app, remArgs{:});
            end

            % Show output if Debug is on
            app.displayDebugText();

            % Register the app with App Designer
            registerApp(app, app.Figure)

            % Ensure it's on screen
            app.moveOnScreen();

            % Mark the setup complete
            app.SetupComplete = true;

            % Update the app
            app.update();

            % Update the title
            app.updateTitle();

            % Force drawing to finish now
            drawnow('limitrate')

            % Now, make it visible
            app.Figure.Visible = 'on';

        end %function


        function delete(app)
            % Destructor

            % Show output if Debug is on
            app.displayDebugText();

            % Store last position in preferences

            % Note: Use isprop instead of isvalid. 
            % If a user deletes the figure instead of the app, 
            % this delete method is still triggered. Although
            % not yet fully deleted (prop values still available), 
            % the app and figure are not valid at this point. 
            if isscalar(app.Figure) && isprop(app.Figure, "Position")
                app.setPreference('Position',app.Figure.Position)
            end

            % Save preferences
            app.savePreferences();

            % Now, delete the figure
            delete(app.Figure)

        end %function

    end %methods



    %% Public Methods
    methods
        
        function close(app)
            % Triggered on figure closed
            
            app.delete();
            
        end %function


        function selection = promptYesNoCancel(app, message, title, default, icon)
            % Prompt the user with a yes/no/cancel selection

            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
                message (1,1) string = "Are you sure?"
                title (1,1) string = ""
                default (1,1) string = "Cancel"
                icon (1,1) string = "question"
            end

            % Show output if Debug is on
            app.displayDebugText();

            % Launch the prompt
            selection = uiconfirm(app.Figure, message, title,...
                "Options",["Yes","No","Cancel"],...
                "DefaultOption",default,...
                "CancelOption","Cancel",...
                "Icon",icon);

        end %function


        function filePath = promptToSaveAs(app, filePath, filter, title)
            % Prompt the user to save a file

            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
                filePath (1,1) string = pwd
                filter = ["*.mat","MATLAB MAT File"];
                title (1,1) string = "Save as"
            end

            % Show output if Debug is on
            app.displayDebugText();

            % Prompt for the file
            [fileName,pathName] = uiputfile(filter, title, filePath);

            % Did the user cancel?
            if isequal(fileName,0)
                filePath = string.empty(0);
            else
                filePath = fullfile(pathName,fileName);
                app.LastFolder = pathName;
            end %if isequal(fileName,0)

        end %function


        function filePath = promptToLoad(app, filter, title, startPath)
            % Prompt the user to load a file

            % Define arguments
            arguments
                app (1,1) wt.apps.BaseApp
                filter = ["*.mat","MATLAB MAT File"];
                title (1,1) string = "Open"
                startPath (1,1) string = app.LastFolder
            end

            % Show output if Debug is on
            app.displayDebugText();

            % Prompt for the file
            [fileName,pathName] = uigetfile(filter, title, startPath);

            % Did the user cancel?
            if isequal(fileName,0)
                filePath = string.empty(0);
            else
                filePath = string( fullfile(pathName,fileName) );
                app.LastFolder = pathName;
            end %if isequal(fileName,0)

        end %function

    end %methods



    %% Sealed Public methods
    methods (Sealed)

        function value = getPreference(app, propName, defaultValue)
            % Get an app preference from the Preferences object

            if isprop(app.Preferences, propName)
                value = app.Preferences.(propName);
            elseif nargin>2
                value = defaultValue;
            else
                value = [];
            end

        end %function


        function setPreference(app, propName, value)
            % Set an app preference in the Preferences object

            if ~isprop(app.Preferences,propName)
                addprop(app.Preferences,propName);
            end
            app.Preferences.(propName) = value;

        end %function


        function moveOnScreen(app)
            % Ensure the figure is placed on screen

            % Show output if Debug is on
            app.displayDebugText();

            % Move it on screen
            wt.utility.moveOnScreen(app.Figure);

        end %function

    end %methods



    %% Protected Methods
    methods (Access = protected)

        function preSetup(~)
            % Customize behavior between figure creation and setup
            
            % Format: 
            %   function preSetup(app)
            %       % code here
            %   end

        end %function


        function postSetup(~)
            % Customize behavior between setup and update
            
            % Format: 
            %   function postSetup(app)
            %       % code here
            %   end

        end %function

        
        function displayDebugText(app, evt)
            % Display the path to the caller function in the command window

            if app.Debug

                stackInfo = dbstack(1,'-completenames');
                fcnName = string(stackInfo(1).name);
                filePath = string( stackInfo(1).file );
                namespaces = extractBetween(filePath, "+", "\");
                classname = extractBetween(filePath, "@", "\");
                pathParts = vertcat(namespaces, classname, fcnName);
                dispPath = join(pathParts, ".");
                appClass = class(app);

                formatStr = '  [%s]  <a href="matlab: edit(''%s'');">%s</a>\n';
                fprintf(formatStr, appClass, filePath, dispPath);

                if nargin >= 2
                    fprintf('    --------------------\n    Event Data:\n\n');
                    disp(evt);
                    fprintf('    --------------------\n')
                end

            end %if

        end %function


        function setup_internal(app)
            % Preform internal pre-setup necessary

            % Show output if Debug is on
            app.displayDebugText();

            % This is used for session managed apps

        end %function


        function loadPreferences(app)
            % Load stored preferences

            % Show output if Debug is on
            app.displayDebugText();

            app.Preferences.load(app.PreferenceGroup);

        end %function


        function savePreferences(app)
            % Save preferences

            % Show output if Debug is on
            app.displayDebugText();

            app.Preferences.save(app.PreferenceGroup);

        end %function


        function updateTitle(app)
            % Update the figure title

            % Show output if Debug is on
            app.displayDebugText();

            app.Figure.Name = app.Name;

        end %function

    end %methods


    %% Private methods
    methods (Access = private)
        
        function  [splitArgs, remArgs] = splitArgs(~,argnames,varargin)
            % Separate specified P-V arguments from the rest of P-V pairs
            
            narginchk(1,inf) ;
            splitArgs = {};
            remArgs = {};
            
            if nargin>1
                props = cellstr( varargin(1:2:end) );
                values = varargin(2:2:end);
                if ( numel( props ) ~= numel( values ) ) || ...
                        any( ~cellfun( @(x)ischar(x)||isStringScalar(x), props ) )
                    error( 'wt:baseApp:splitArgs:BadSyntax', ...
                        'Arguments must be supplied as property-value pairs' );
                end
                ToSplit = ismember(props,argnames);
                ToSplit = reshape([ToSplit; ToSplit],1,[]);
                splitArgs = varargin(ToSplit);
                remArgs = varargin(~ToSplit);
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
                    ];

            end %if

            propGroups = pGroups;

        end %function

    end %methods


end % classdef