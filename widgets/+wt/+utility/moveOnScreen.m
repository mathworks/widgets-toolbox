function moveOnScreen(fig)
% Ensure the figure is placed on screen

% Copyright 2025 The MathWorks, Inc.

% Define arguments
arguments
    fig (1,1) matlab.ui.Figure
end

% Figure must be in pixel units
if ~strcmp(fig.Units,'pixels')
    oldUnits = fig.Units;
    cleanupObj = onCleanup(@()set(fig,"Units",oldUnits));
    fig.Units = 'pixels';
end

% Get screen positions
g = groot;
screenPos = g.MonitorPositions;

% Buffer for title bar
titleBarHeight = 30;

% Get the corners of the figure (bottom left and top right)
figPos = fig.OuterPosition;
figCornerA = figPos(1:2);
figCornerB = figPos(1:2) + figPos(:,3:4) - 1;

% Calculate the figure's area shown on each screen
overlapAreas = zeros(size(screenPos, 1), 1);
for i = 1:size(screenPos, 1)
    thisScreen = screenPos(i, :);
    overlapWidth = max(0, min(figPos(1) + figPos(3), thisScreen(1) + thisScreen(3)) - max(figPos(1), thisScreen(1)));
    overlapHeight = max(0, min(figPos(2) + figPos(4), thisScreen(2) + thisScreen(4)) - max(figPos(2), thisScreen(2)));
    overlapAreas(i) = overlapWidth * overlapHeight;
end

% Determine the screen with the largest overlap
[~, screenIdx] = max(overlapAreas);

% Get the corners of the screen
screenCornerA = screenPos(screenIdx, 1:2);
screenCornerB = screenCornerA + screenPos(screenIdx, 3:4) - 1;

% Are the corners on the screen?
aIsOnScreen = all( figCornerA >= screenCornerA & ...
    figCornerA <= screenCornerB, 2 );
bIsOnScreen = all( figCornerB >= screenCornerA & ...
    figCornerB <= screenCornerB, 2);


% Are both corners fully on one screen?
if aIsOnScreen && bIsOnScreen
    % Yes - do nothing

elseif bIsOnScreen
    % Upper right corner is on a screen
    % Adjust so the entire figure is on that screen

    % Calculate the adjustment needed, and make it
    figAdjust = max(figCornerA, screenCornerA) - figCornerA;
    figPos(1:2) = figPos(1:2) + figAdjust;

    % Ensure the upper right corner still fits
    requestedSize = screenCornerB - figPos(1:2) - [0 titleBarHeight] + 1;
    figPos(3:4) = min(figPos(3:4), requestedSize);

    % Move the figure
    fig.Position = figPos;

else
    % Lower left corner is on a screen
    % Adjust so the entire figure is on that screen

    % Calculate the adjustment needed, and make it
    figAdjust = min(figCornerB, screenCornerB) - figCornerB;
    figPos(1:2) = max(screenCornerA, figPos(1:2) + figAdjust);

    % Ensure the upper right corner still fits
    requestedSize = screenCornerB - figPos(1:2) - [0 titleBarHeight] + 1;
    figPos(3:4) = min(figPos(3:4), requestedSize);

    % Move the figure
    fig.Position = figPos;

end %if
