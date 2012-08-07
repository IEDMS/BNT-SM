function bool = isempty(hash)
%ISEMPTY Check to see if the hash is empty
%   bool = isempty(hash)

% Copyright (c) 2004 Matthew Krauski (mkrauski@uci.edu), CNLM, UC Irvine

bool = isempty(hash.keys);

