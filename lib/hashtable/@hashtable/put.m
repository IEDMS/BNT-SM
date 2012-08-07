function hash = put(hash,key,data)
%PUT Put data in the hash table
%   hash = put(hash,key,data)

% Copyright (c) 2004 Matthew Krauski (mkrauski@uci.edu), CNLM, UC Irvine

index = find(strcmp(hash.keys,key));
if isempty(index)
    if isempty(hash.keys)
        hash.keys{1} = key;
        hash.data{1} = data;
    else
        hash.keys{end+1} = key;
        hash.data{end+1} = data;
    end
else
    hash.data{index} = data;
end
