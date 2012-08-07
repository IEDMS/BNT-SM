%Convert the structure used in the bnet to a conditional probability table.
%Extraction can be done on the resulting table.
function p = peek(x, field)

	if nargin < 2, 
       field = 'CPT'; 
    end;

s = struct(x);

p = eval( ['s.' field] );
