function hash = hashtable(varargin)
%HASHTABLE Constructor for HashTable class
%   hash = hashtable - Default constructor, empty hash table
%   hash = hashtable(keys,data) - keys and data are N-by-1 lists

% Copyright (c) 2004 Matthew Krauski (mkrauski@uci.edu), CNLM, UC Irvine

if nargin == 1 && isa(keys,'HashTable')
    hash = varargin{1};
elseif nargin == 0
    h.keys = {};
    h.data = {};
elseif nargin == 2
    h.keys = varargin{1};
    h.data = varargin{2};
else
    error('HashTable:hashtable', 'Invalid arguments.');
end
    
hash = class(h,'hashtable');
