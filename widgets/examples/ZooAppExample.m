function varargout = ZooAppExample(varargin)
% Launch app

% Default
varargout{1} = [];


%% Check dependencies
if ~exist("wt.apps.BaseApp","class")
    error("Widgets Toolbox is required to run this app. " + ...
        "Install from Add-Ons browser.");
end


%% Bugfixes



%% Instantiate the application
app = wtexample.app.ContextualViewExample(varargin{:});


%% Load default session
app.loadSession(which("robyn_session.mat"))


%% Collect output
if nargout
    varargout{1} = app;
end
