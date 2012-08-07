function data = get(hash,key)
%GET Get data from the hash table
%   data = get(hash,key)

% Copyright (c) 2004 Matthew Krauski (mkrauski@uci.edu), CNLM, UC Irvine

index = find(strcmp(hash.keys,key));
if isempty(index)
    data = {};
else
    data = hash.data{index};
end
