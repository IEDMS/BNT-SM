function display(hash)
%DISPLAY Display a hash table object
%   display(hash)

% Copyright (c) 2004 Matthew Krauski (mkrauski@uci.edu), CNLM, UC Irvine

isLoose = strcmp(get(0,'FormatSpacing'),'loose');

if(length(inputname(1)) ~= 0)
    if isLoose, disp(' '), end
    disp( sprintf('%s =', inputname(1)) );
end

if isLoose, disp(' '), end

fprintf('\tHashTable\n' );
if isempty(hash)
    fprintf('\tEmpty\n\n' );
else
    disp( sprintf('\tElements:') );
    display( elements(hash) );
end

