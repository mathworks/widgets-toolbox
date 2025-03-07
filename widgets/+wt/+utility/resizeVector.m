function y = resizeVector(x,n,val)
% Resizes the vector x to match the size n using val to pad
%   Copyright 2025 The MathWorks Inc.

arguments
    x {mustBeVector}
    n (1,1) {mustBeInteger}
    val (1,1) = 0
end

nX = length(x);
if nX > n
    y = x(1:n);
elseif nX < n
    y = x;
    y(end+1:n) = val;
else
    y = x;
end

