function setStylePropsInPriority(comps, propNames, value)
% For each given component, set the specified value to the first identified
% property. Properties specified in prioritized order.

%   Copyright 2023-2025 The MathWorks Inc.


% Define arguments
arguments
    comps matlab.graphics.Graphics
    propNames (1,:) string
    value
end

% Convert enumerate value
value = wt.utility.convertEnumToValue(value);

% Filter any invalid components
comps(~isvalid(comps)) = [];

% Track components that have been set
isDone = false(size(comps));

% Loop on each property
for thisProp = propNames

    % Does the current property exist in each component?
    needsSet = ~isDone & isprop(comps, thisProp);

    % Set as needed
    if any(needsSet)
        set(comps(needsSet), thisProp, value);
        isDone(needsSet) = true;
    end

    %RJ - Tried this but still the default componentcontainer has wuite
    %background color. Need to investigate more.
    % Also need to change BackgroundColorableComponents (:,1) to row vector
    % Set as needed
    % for thisComp = comps(needsSet)
    %     if ~isequal(thisComp.(thisProp), value)
    %         thisComp.(thisProp) = value;
    %     end
    % end
    % isDone(needsSet) = true;

    % Return early if complete
    if all(isDone)
        return;
    end

end %for
