%Get the next meaningful line of code in a file.
%Ignores comments as '#' characters

%Issues:  All lines at the end of a file that are comments or blanks will
%be left as blank lines.
function line = fgetline(fid)

line = '';
while strcmp(line, '') && ~feof(fid) 
	line = fgetl(fid);
	line = regexprep(line, '#[^\n]*', '');
	line = strtrim(line);
end
