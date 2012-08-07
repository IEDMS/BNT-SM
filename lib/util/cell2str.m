function str = cell2str(cells)
str = '';
for j=1:length(cells)
	if isstr(cells{j}),
		str = sprintf('%s%s\t', str, cells{j});
	else
		str = sprintf('%s%f\t', str, cells{j});
	end
end
str = str(1:end-1);
if isempty(str)
  str = [];   % overcoming matlab's "feature"
end
return
