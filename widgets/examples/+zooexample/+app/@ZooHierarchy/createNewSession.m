function session = createNewSession(app)
% Called by the app when a new session must be created
% This is required by the superclass AbstractSessionApp and
% called from methods of BaseMultiSessionApp

% Copyright 2025 The MathWorks Inc.

% Show output if Debug is on
app.displayDebugText();

% Create a new session
session = zooexample.model.Session;