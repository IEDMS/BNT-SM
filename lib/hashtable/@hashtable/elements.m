function data = elements(hash)
%ELEMENTS Get all hash table elements
%   data = values(hash)
%
% Get all hash table elements in a N-by-2 cell matrix where N is the number of
% elements, first column contains the element keys, and second column contains
% the element values.

% Copyright (c) 2004 Matthew Krauski (mkrauski@uci.edu), CNLM, UC Irvine

data(:,1) = hash.keys;
data(:,2) = hash.data;

