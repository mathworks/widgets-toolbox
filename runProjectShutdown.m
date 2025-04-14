% Run project startup tasks

%   Copyright 2019-2025 The MathWorks Inc.


%% Close any open components first

close all
warning('off','MATLAB:ClassInstanceExists');
clear classes %#ok<CLCLS>
warning('on','MATLAB:ClassInstanceExists');


%% Re-enable any installed version

% Get installed addons
addonInfo = matlab.addons.installedAddons();

% Addon ID
addonId = "78895307-cc36-4970-8b66-0697da8f9352"; % Widgets Toolbox 2.x

% Enable
if ismember(addonId, addonInfo.Identifier)
    matlab.addons.enableAddon(addonId);
end
