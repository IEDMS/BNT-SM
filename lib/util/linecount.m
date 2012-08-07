function lc = linecount(file)

fid = fopen(file, 'r');

lc = 0;
while ~feof(fid),
	line = fgetl(fid);
	lc = lc + 1;
end

fclose(fid);
