function [setup_done] = setup_LRoutput(done, property, kc_names, evidence)

if done == 0,
        setup_done = 1;
else
        setup_done = done;
        return;
end

% set up the tables;

fid_param_table = fopen(property.output.param_table, 'w');
fprintf(fid_param_table, 'skill\tnum_users\tnum_cases\tll');
for i = 1:length(property.structure.eclasses),
        eclass = property.structure.eclasses(i).eclass;
        if strcmp(eclass.type,'softmax'),
            for j=1:length(eclass.cpd),
                if strcmp(eclass.cpd(j).param, 'null'), continue; end;
                param = eclass.cpd(j).param;
                fprintf(fid_param_table, ['\t' param '_intercept']);
                for l=1:length(kc_names),
                    fprintf(fid_param_table, ['\t' param '_' kc_names{l}]);
                end
            end
        end
        if strcmp(eclass.type, 'discrete'),
            for j = 1:length(eclass.cpd),
                if strcmp(eclass.cpd(j).param, 'null'), continue; end;
                fprintf(fid_param_table, ['\t' eclass.cpd(j).param]);
            end
        end
end
fprintf(fid_param_table, '\n');
fclose(fid_param_table);

% Reset the output file
if (exist(property.output.inference_result)),
        delete(property.output.inference_result);
end

% Save the header for the user's benefit, if the header file was 
% defined in the configuration xml
try
        headers = keys(evidence.header);
        fid_inference_header = fopen(property.output.inference_result_header, 'w');
        for i = 1:length(headers),
                fprintf(fid_inference_header, '%s\t', headers{i});
        end
        fprintf(fid_inference_header, '\n');
        fclose(fid_inference_header);
catch
        disp('Will not generate header file for inference results');
end
