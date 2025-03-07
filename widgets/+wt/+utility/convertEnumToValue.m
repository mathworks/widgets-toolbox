function value = convertEnumToValue(value)
% Convert enumaration value to its double or string associated value
%   Copyright 2025 The MathWorks Inc.

valueClass = class(value);

% Is the value enumerate?
if startsWith(valueClass, 'wt.enum')
    % Can value be converted?
    if ismethod(value, 'double')
        value = double(value);
    elseif ismethod(value, 'string')
        value = string(value);
    elseif ismethod(value, 'char')
        value = char(value);
    end
end %if
end %function