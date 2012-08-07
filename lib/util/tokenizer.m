function [tokens] = tokenizer(str, delimiter)

k = 1;

if nargin < 2,
  delimiter = sprintf('\t ');
end

while true
	[token, str] = strtok(str, delimiter);
	if isempty(token),  break;  end
	tokens{k} = token;
	k = k + 1;
end
