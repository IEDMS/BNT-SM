function extract_bnet(k, param_table)

fid_param_table = fopen(param_table, 'a');

fprintf(fid_param_table, '%s\t%d\t%d\t%f', ...
		k.name, k.num_users, k.num_cases, k.ll(end));

param = k.param;

param_names = keys(param);
for j = 1:length(param_names),
	param_name = param_names{j};
	param_value = param(param_name);

	fprintf(fid_param_table, '\t%f', param_value);
end

fprintf(fid_param_table, '\n');

fclose(fid_param_table);
