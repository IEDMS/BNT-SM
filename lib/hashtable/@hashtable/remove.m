function hash = remove(hash,key)
%REMOVE Remove element from the hash
%   hash = remove(hash,key)

% Copyright (c) 2004 Matthew Krauski (mkrauski@uci.edu), CNLM, UC Irvine

index = find(strcmp(hash.keys,key));
if ~isempty(index)
    hash.keys = {hash.keys{1:index-1} hash.keys{index+1:end}};
    hash.data = {hash.data{1:index-1} hash.data{index+1:end}};
end
