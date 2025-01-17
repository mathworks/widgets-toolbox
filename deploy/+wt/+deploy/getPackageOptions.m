function opts = getPackageOptions(projectRoot, toolboxVersion)
% Returns the toolbox packaging options

% Copyright 2025 The MathWorks, Inc.

arguments (Input)
    projectRoot (1,1) string {mustBeFolder}
    toolboxVersion (1,1) string
end

arguments (Output)
    opts (1,1) matlab.addons.toolbox.ToolboxOptions
end


%% Define paths


% Get the root folder
toolboxFolder = fullfile(projectRoot,"widgets");

% UUID for Widgets Toolbox 2.x on File Exchange
identifier = "78895307-cc36-4970-8b66-0697da8f9352"; 


%% Prepare options

opts = matlab.addons.toolbox.ToolboxOptions(toolboxFolder, identifier);


%% Requirements

opts.MinimumMatlabRelease = "R2020b";

opts.MaximumMatlabRelease = "";

opts.SupportedPlatforms.Win64 = true;
opts.SupportedPlatforms.Glnxa64 = true;
opts.SupportedPlatforms.Maci64 = true;
opts.SupportedPlatforms.MatlabOnline = true;

% opts.RequiredAddons

% opts.RequiredAdditionalSoftware


%% Output

opts.ToolboxVersion = toolboxVersion;

outFileName = sprintf("Widgets Toolbox %s.mltbx", toolboxVersion);
opts.OutputFile = fullfile(projectRoot,"release",outFileName);


%% Define file contents / paths

% Toolbox file contents paths - This should be set automatically
% opts.ToolboxFiles

% Folders to add to the MATLAB path
relativePaths = [
    ""
    "doc"
    "examples"
    "icons"
    ];
opts.ToolboxMatlabPath = fullfile(toolboxFolder, relativePaths);
% opts.ToolboxMatlabPath = [
%     ""
%     "doc"
%     "examples"
%     "icons"
%     ];

% Java path for toolbox
% opts.ToolboxJavaPath

% Files to add to the app gallery
opts.AppGalleryFiles = [
    fullfile(toolboxFolder, "examples","WidgetsExampleApp.mlapp")
    ];

% Path to the getting started guide
opts.ToolboxGettingStartedGuide = fullfile(toolboxFolder,...
    "doc","GettingStarted.mlx");


%% Metadata
opts.ToolboxName = "Widgets Toolbox - MATLAB App Designer Components";

opts.Summary = "Additional app building components to efficiently " + ...
    "develop advanced user interfaces in MATLAB";

opts.Description = join([
    "Widgets Toolbox helps you efficiently develop advanced user interfaces in MATLAB and App Designer. Widgets combine existing control functionalities together into larger, reusable, common functionality to accelerate development of graphical user interfaces."
    ""
    "Components include:"
    ""
    " - Grid of buttons grouped together"
    " - List of checkboxes and labels grouped together"
    " - Color selector control"
    " - Date and time selector"
    " - File selection control, consisting of a label, edit field, and browse button"
    " - Listbox control combined with a label and a set of buttons for managing the list composition and ordering"
    " - Password field with hidden text"
    " - Progress bar indicator with time remaining and cancel button"
    " - Slider control group with labels and enable/disable checkboxes"
    " - Slider control linked to a numeric spinner and edit field"
    " - List of tasks with icons indicating status (pass, fail, running, complete, etc.)"
    " - Toolbar with advanced layout functionality that can appear like a toolstrip"
    ""
    "This version of Widgets Toolbox is intended for NEW development of uifigure or App Designer apps starting from R2020b or newer releases."
    ""
    "If you have an existing MATLAB app using Widgets Toolbox 1.x content, you may also need 'Widgets Toolbox (Compatibility Support)'."
    "https://www.mathworks.com/matlabcentral/fileexchange/66235-widgets-toolbox"
    ""
    "Planning a complex or business-critical app? MathWorks Consulting can advise you on design and architecture: https://www.mathworks.com/services/consulting/proven-solutions/software-development-with-matlab.html"
    ], newline);

opts.AuthorName = "Robyn Jackey (MathWorks Consulting)";

opts.AuthorEmail = "";

opts.AuthorCompany = "MathWorks Consulting";

opts.ToolboxImageFile = fullfile(projectRoot,"deploy","wtLogo.png");