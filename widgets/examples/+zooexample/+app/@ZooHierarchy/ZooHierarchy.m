classdef ZooHierarchy < wt.apps.BaseMultiSessionApp
    % Example app showing a tree with contextual views

    % Copyright 2025 The MathWorks Inc.


    %% Internal properties
    properties (SetAccess = private)

        % Toolbar at top of the app window
        Toolbar wt.Toolbar

        % Navigation tree on the left of the app
        Tree matlab.ui.container.Tree

        % Contextual pane to show view/controller for selected tree node
        ContextualView wt.ContextualView

        % Toolbar buttons
        SessionNewButton matlab.ui.control.Button
        SessionOpenButton matlab.ui.control.Button
        SessionImportButton matlab.ui.control.Button
        SessionSaveButton matlab.ui.control.Button
        SessionSaveAsButton matlab.ui.control.Button
        SessionCloseButton matlab.ui.control.Button
        ExhibitAddButton matlab.ui.control.Button
        ExhibitDeleteButton matlab.ui.control.Button
        EnclosureAddButton matlab.ui.control.Button
        EnclosureDeleteButton matlab.ui.control.Button
        AnimalAddButton matlab.ui.control.Button
        AnimalDeleteButton matlab.ui.control.Button

        % Tree selection data
        TreeSelectionData (1,1) wt.eventdata.TreeModelSingleSelectionData

    end %properties


    %% Methods implemented in separate files
    methods (Access = protected)

        setup(app)
        update(app)
        updateTreeHierarchy(app)
        onTreeSelection(app,evt)
        onToolbarButtonPushed(app,evt)

    end %methods


    %% Protected methods
    methods (Access = protected)

        function session = createNewSession(app)
            % Called by the app when a new session must be created
            % This is required by the superclass AbstractSessionApp and
            % called from methods of BaseMultiSessionApp

            % Show output if Debug is on
            app.displayDebugText();

            % Create a new session
            session = zooexample.model.Session;

        end %function

    end %methods

end %classdef