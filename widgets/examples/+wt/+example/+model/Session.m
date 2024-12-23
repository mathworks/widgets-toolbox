classdef Session < wt.model.BaseSession
    % Implements the session class for the app


    %% Public Properties
    properties (SetObservable)

        % The array of all exhibits
        Exhibit (1,:) wt.example.model.Exhibit

        % Selected indices
        % SelectedIndices (1,3) {mustBeInteger}

    end %properties


    %% Protected methods
    methods (Access = protected)

        function props = getAggregatedModelProperties(~)
            % Returns a list of aggregated model property names

            % If a listed property is also a wt.model.BaseModel, property
            % changes that trigger the ModelChanged event will be passed up
            % the hierarchy to this object.

            props = "Exhibit";

        end %function

    end %methods


    %% Public Methods
    methods

        function importManifest(session, filePath)

            arguments
                session (1,1) wt.example.model.Session
                filePath (1,1) string {mustBeFile}
            end

            % Import data
            animalTable = readtable(filePath,"Sheet","Animals","TextType","string");
            enclosureTable = readtable(filePath,"Sheet","Enclosures","TextType","string");
            exhibitTable = readtable(filePath,"Sheet","Exhibits","TextType","string");


            % === Parse Animals into objects ===

            % Get data
            thisTable = animalTable;
            numRows = height(thisTable);

            % Preallocate output
            animal(numRows,1) = wt.example.model.Animal;

            for idx = 1:numRows

                % Create a new instance
                newItem = wt.example.model.Animal;

                % Populate data
                newItem.Name = thisTable.Name(idx);
                newItem.Species = thisTable.Species(idx);
                newItem.BirthDate = thisTable.BirthDate(idx);
                try
                    newItem.Sex = thisTable.Sex(idx);
                catch
                    newItem.Sex = 'unspecified';
                end

                % Place in the list
                animal(idx) = newItem;

            end %for


            % === Parse Enclosures into objects ===

            % Get data
            thisTable = enclosureTable;
            numRows = height(thisTable);

            % Preallocate output
            enclosure(numRows,1) = wt.example.model.Enclosure;

            for idx = 1:numRows

                % Create a new instance
                newItem = wt.example.model.Enclosure;

                % Populate data
                newItem.Name = thisTable.Name(idx);
                newItem.Location = [thisTable.LocationX(idx), thisTable.LocationY(idx)];

                % Attach animals belonging to this enclosure
                isMatch = matches(animalTable.Enclosure, newItem.Name);
                newItem.Animal = animal(isMatch);

                % Place in the list
                enclosure(idx) = newItem;

            end %for


            % === Parse Exhibits into objects ===

            % Get data
            thisTable = exhibitTable;
            numRows = height(thisTable);

            % Preallocate output
            exhibit(numRows,1) = wt.example.model.Exhibit;

            for idx = 1:numRows

                % Create a new instance
                newItem = wt.example.model.Exhibit;

                % Populate data
                newItem.Name = thisTable.Name(idx);
                newItem.Location = [thisTable.LocationX(idx), thisTable.LocationY(idx)];

                % Attach enclosures belonging to this exhibit
                isMatch = matches(enclosureTable.Exhibit, newItem.Name);
                newItem.Enclosure = enclosure(isMatch);

                % Place in the list
                exhibit(idx) = newItem;

            end %for

            % Add to session
            session.Exhibit = vertcat(session.Exhibit, exhibit);

        end %function

    end %methods

end %classdef