function out = cleanPath(in)
% cleanPath - Utility to clean and standardize a file/folder path
%
% This function will clean and standardize a file or folder path. It
% removes leading/trailing whitespace and removes any file separator from
% the trailing end of the path.
%
% Syntax:
%       path = wt.utility.cleanPath(path)
%
% Inputs:
%       path - the path to a file or folder
%
% Outputs:
%       path - the cleaned path
%
% Examples:
%
%     >> path = "   C:\Program Files\MATLAB\" %Note leading space and trailing separator
%     >> path = wt.utility.cleanPath(path)
%
%     path =
%
%         "C:\Program Files\MATLAB"
%

%   Copyright 2020-2026 The MathWorks Inc.
% ---------------------------------------------------------------------

arguments
    in string    % accepts string arrays of any size
end

if isempty(in)
    out = in;
    return
end

fs = filesep;
sz = size(in);
out = strings(sz); % allocate same size

for idx = 1:numel(in)
    sIn = char(in(idx));
    if strlength(in(idx)) == 0
        out(idx) = in(idx);
        continue
    end

    % If URI-like (scheme://) then leave unchanged
    if ~isempty(regexp(sIn, '^[A-Za-z][A-Za-z0-9+.\-]*://', 'once'))
        out(idx) = in(idx);
        continue
    end

    % Detect UNC-style leading slashes
    isUNC = ~isempty(regexp(sIn, '^[\\/]{2,}', 'once'));

    % Collapse any run of slashes/backslashes to single platform filesep
    s = regexprep(sIn, '[\\/]+', fs);

    if isUNC
        % Remove any leading separators then ensure exactly two leading filesep
        s = regexprep(s, ['^' regexptranslate('escape', fs) '+'], '');
        s = [repmat(fs,1,2) s];
    else
        % Preserve drive-letter prefix like 'C:' and ensure at most one filesep after it
        m = regexp(sIn, '^([A-Za-z]:)[\\/]*', 'tokens', 'once');
        if ~isempty(m)
            drive = m{1};
            % Strip any leading drive+sep from s, then reapply drive and single filesep if needed
            s = regexprep(s, ['^' regexptranslate('escape', drive) regexptranslate('escape', fs) '?'], '');
            if isempty(s)
                s = drive;
            else
                s = [drive fs s];
            end
        end
    end

    out(idx) = string(s);
end
end