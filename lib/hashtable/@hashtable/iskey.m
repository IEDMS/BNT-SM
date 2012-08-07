function bool = iskey(hash,key)
%ISKEY Check to see if the hash is currently using a key
%   bool = iskey(hash,key)

% Copyright (c) 2004 Matthew Krauski (mkrauski@uci.edu), CNLM, UC Irvine

index = find(strcmp(hash.keys,key));
bool = ~isempty(index);

