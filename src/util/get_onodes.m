function onodes = get_onodes(ev, engine_onodes)

onodes = [];
for i = 1:length(ev),
	if ~isempty(ev{i}),
		onodes = [onodes i];
	end
end

if length(engine_onodes) > length(onodes),
   onodes = [onodes onodes+length(ev)];
end
