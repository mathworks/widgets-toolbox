classdef AppDesignerMetadata < matlab.unittest.TestCase
    % Verify App Designer component metadata.

%   Copyright 2026 The MathWorks, Inc.

    methods (Test)

        function testRequiredComponentFields(testCase)

            metadataText = fileread(testCase.getMetadataFile());
            testCase.assertNotEmpty(metadataText)

            % R2025b's registration framework rejects this resource when
            % appDesigner.json has a final line terminator.
            finalChar = double(metadataText(end));
            testCase.verifyNotEqual(finalChar, double(newline))
            testCase.verifyNotEqual(finalChar, double(sprintf('\r')))

            metadata = jsondecode(metadataText);
            testCase.assertTrue(isfield(metadata, "components"))

            components = testCase.toCell(metadata.components);
            requiredFields = [
                "componentName"
                "version"
                "description"
                "category"
                "icon"
                "authorName"
                "authorEmail"
                "className"
                "avatar"
                "avatarDark"
                "defaultPosition"
                ];

            classNames = strings(numel(components), 1);
            for idx = 1:numel(components)
                component = components{idx};
                classNames(idx) = string(component.className);
                missingFields = setdiff(requiredFields, string(fieldnames(component)));
                testCase.verifyEmpty(missingFields, ...
                    "Missing App Designer metadata field(s) for " + classNames(idx))
            end

            testCase.verifyComponentName(components, "wt.DateSlider", ...
                "Date Slider (R2023b+)")
            testCase.verifyComponentDefaultWidth(components, ...
                "wt.DateSlider", 600)
            testCase.verifyComponentName(components, "wt.DateRangeSlider", ...
                "Date Range Slider (R2024b+)")
            testCase.verifyComponentDefaultWidth(components, ...
                "wt.DateRangeSlider", 600)

        end %function

        function testRegistrationFrameworkCanParseMetadata(testCase)

            testCase.assumeNotEmpty( ...
                meta.class.fromName('matlab.internal.regfwk.ResourceSpecification'), ...
                "MATLAB registration framework is not available.")

            metadataRoot = testCase.getMetadataRoot();
            metadataFile = testCase.getMetadataFile();

            spec = matlab.internal.regfwk.ResourceSpecification( ...
                struct('ResourceName', 'appDesigner', 'ResourceType', 'json'));

            matlab.internal.regfwk.enableResources(metadataRoot);
            resourceInfo = matlab.internal.regfwk.getResourceList(spec, 'enabled');

            resourceFiles = string({resourceInfo.resourcesFile});
            metadataIdx = find(strcmpi(resourceFiles, metadataFile), 1);
            testCase.assertNotEmpty(metadataIdx, ...
                "App Designer metadata was not registered.")

            contents = resourceInfo(metadataIdx).resourcesFileContents;
            testCase.assertTrue(isstruct(contents), ...
                "App Designer metadata did not parse through the registration framework.")

            components = testCase.toCell(contents.components);
            classNames = string(cellfun(@(component) component.className, ...
                components, 'UniformOutput', false));
            testCase.verifyTrue(any(classNames == "wt.DateSlider"), ...
                "wt.DateSlider was not present in registered metadata.")
            testCase.verifyTrue(any(classNames == "wt.DateRangeSlider"), ...
                "wt.DateRangeSlider was not present in registered metadata.")

        end %function

    end %methods

    methods (Access = private)

        function metadataRoot = getMetadataRoot(testCase)

            metadataRoot = fullfile(testCase.getProjectRoot(), "widgets");

        end %function

        function metadataFile = getMetadataFile(testCase)

            metadataFile = fullfile(testCase.getMetadataRoot(), ...
                "resources", "appDesigner.json");

        end %function

        function verifyComponentName(testCase, components, className, ...
                componentName)

            component = testCase.getComponent(components, className);
            testCase.verifyEqual( ...
                string(component.componentName), ...
                componentName)

        end %function

        function verifyComponentDefaultWidth(testCase, components, className, ...
                defaultWidth)

            component = testCase.getComponent(components, className);
            defaultPosition = reshape(component.defaultPosition, 1, []);
            testCase.verifyEqual(defaultPosition(3), defaultWidth)

        end %function

        function component = getComponent(testCase, components, className)

            classNames = string(cellfun(@(component) component.className, ...
                components, 'UniformOutput', false));
            componentIdx = find(classNames == className, 1);
            testCase.assertNotEmpty(componentIdx, ...
                className + " is missing from App Designer metadata.")
            component = components{componentIdx};

        end %function

    end %methods

    methods (Static, Access = private)

        function projectRoot = getProjectRoot()

            projectRoot = fileparts(fileparts(fileparts( ...
                fileparts(mfilename('fullpath')))));

        end %function

        function components = toCell(components)

            if isstruct(components)
                components = num2cell(components);
            end

        end %function

    end %methods

end %classdef
