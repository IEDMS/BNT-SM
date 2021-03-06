function [property evidence hash_bnet] = RunBnet(property_xml)

% 1. property

disp('1. property');
property = xml_load(property_xml);

%xxxxxxxxxxxxxxx
if(strcmpi(property.multi_subskill, 'yes')),
   [property evidence hash_bnet] = RunLRBnet(property_xml);   
   return;
end
%xxxxxxxxxxxxxxxxx

output_setup_done = 0;

fid_log = fopen(property.output.log, 'w');


% 2. evidence

log_message(fid_log, '2. evidence\n');

% Set up the output directory
try 
        data_dir = property.output.dir;
catch
        data_dir = 'skills';
end

if (~exist(data_dir)),
  mkdir(data_dir);
end


% Get file list already in data directory
d_data = dir([data_dir '/*.mat']);

oldest = now;
for i=1:length(d_data),
        current_date = datenum(d_data(i).date);
        if (current_date < oldest),
                oldest = current_date;
        end
end

if (exist(property.input.evidence_train)),
        evidence_train_date = dir(property.input.evidence_train);
        evidence_train_date = datenum(evidence_train_date.date);
else
        evidence_train_date = 0;
        log_message(fid_log, [property.input.evidence_train ' not found\n']);
end

if (exist(property.input.evidence_test)),
        evidence_test_date = dir(property.input.evidence_test);
        evidence_test_date = datenum(evidence_test_date.date);
else
        evidence_test_date = 0;
        log_message(fid_log, [property.input.evidence_test ' not found\n']);
end

if ((length(d_data) > 0) && ...
    (oldest > evidence_train_date) && ... 
    (oldest > evidence_test_date)),
        log_message(fid_log, ['2.1 Loading binary evidence from ' data_dir '\n']);
        mat_load_skills = 1;
else
        log_message(fid_log, ['2.1 Reading text evidence from ' ...
                            property.input.evidence_train ' and ' ...
                            property.input.evidence_test '\n']);
        mat_load_skills = 0;
end


hash_bnet = hashtable;

position_train = 0;
position_test = 0;
skill = '';
mat_load_index = 0;
done = 0;
while (~done),
        if (mat_load_skills),
                mat_load_index = mat_load_index + 1;
                               
                if (mat_load_index > length(d_data)),
                  done = 1;
                  continue;
                end
                skill_file = d_data(mat_load_index);
                skill = strrep(skill_file.name, '.mat', '');
                load([data_dir '/' skill '.mat']);
        else
                previous_skill = skill;
                [evidence.train evidence.header skill position_train] = ...
                        table2evidence( fid_log, ...
                                        property.input.evidence_train, ...
                                        property.structure, ...
                                        position_train);
                if (strcmp(skill, '')),
                  done = 1;
                  continue;
                end
                pass = 0;
                while (~pass),
                        [evidence.test temp test_skill new_position_test] = ...
                            table2evidence( fid_log, ...
                                            property.input.evidence_test, ...
                                            property.structure, ...
                                            position_test);
                        %xxxxxxxxxxxxxxxxxxxxxxxxxxx
                        % Yanbo 10-04-2010
                        % Stop when reading blank rows in evidence.test.xls
                        if(strcmp(test_skill,''))
                            pass = 1;
                            position_test = new_position_test;
                            continue;
                        end
                        %xxxxxxxxxxxxxxxxxxxxxxxxxxx
                        if (~strcmp(skill, test_skill)),
                                if (issorted({skill, test_skill})),
                                        log_message(fid_log, ...
                                        ['   test skill ' ...
                                         test_skill ...
                                         ' does not match ' ...
                                         'training skill ' ...
                                         skill '\n']);
                                        log_message(fid_log, ...
                                         ['   test evidence discarded' ...
                                         ', will not infer ' ...
                                         skill ...
                                         '\n']);
                                        evidence.test = hashtable;
                                        pass = 1;
                                else
                                        log_message(fid_log, ...
                                        ['   test skill ' ...
                                         test_skill ...
                                         ' does not match ' ...
                                         'training skill ' ...
                                         skill ...
                                         ', trying again.\n']);
                                        position_test = ...
                                            new_position_test;
                                        pass = 0;
                                end
                        else
                                position_test = new_position_test;
                                pass = 1;
                        end
                end
                save([data_dir '/' skill '.mat'], 'evidence');
        end

        log_message(fid_log, '   2.2 evidence reading finished\n');

        % 3. hash_bnet

        log_message(fid_log, '3. train and infer bnet\n');


        k.name = skill;

        log_message(fid_log, '\n\t\t\t\t%s\n', skill);
   
        % initialize bnet0
        log_message(fid_log, '\tinitialize bnet... ');

        try
                k.structure = property.structure;
                k.bnet0 = make_bnet(k.structure);

                log_message(fid_log, 'success\n');
        catch
                err = lasterror;
                log_message(fid_log, 'ERROR: %s(%d): %s\n', err.stack(1).file, err.stack(1).line, err.message);
        end

        % train bnet
        log_message(fid_log, '\ttrain bnet... ');

        tic;
        try
                [users cases k.num_users k.num_cases] = get_evidence(evidence.train, skill);
                [k.bnet k.ll] = learn_bnet(k.bnet0, cases);
                log_message(fid_log, 'success\n');
        catch
                err = lasterror;
                log_message(fid_log, 'ERROR: %s(%d): %s\n', err.stack(1).file, err.stack(1).line, err.message);
        end
        training_elapsed = toc;
        log_message(fid_log, '\tTraining elapsed time %f s\n', training_elapsed);

        % setup the header of the output files
        % currently hard-wired script
        output_setup_done = setup_output(output_setup_done, property, ...
                                                       evidence);
        
        % write param_table
        log_message(fid_log, '\twriting param_table...\n');

        try
        %               k.param = extract_param(k.bnet, k,structure);
                k.param = extract_param(fid_log, k);
                extract_bnet(k, property.output.param_table);

                log_message(fid_log, '\twrite param_table success\n');
        catch
                err = lasterror;
                log_message(fid_log, 'ERROR: write param_table %s(%d): %s\n', err.stack(1).file, err.stack(1).line, err.message);
        end

        % write inference_result
        log_message(fid_log, '\tWriting inference_result...\n');

        try
                if ~isempty(evidence.test(skill)),
                        try
                                % Hack
                                if (strcmpi(property.output.inference_is_prior, 'yes')),
                                        log_message(fid_log, ['Output inference will be prior\n']);
                                        inference_prior = 1;
                                else
                                        inference_prior = 0;
                                        log_message(fid_log, ['Output inference will be posterior\n']);
                                end
                                
                                if (strcmpi(property.inference, 'fast')),
                                        log_message(fid_log, ...
                                                    'Inference the fast way\n');
                                        inference_bnet2(skill, ...
                                                       k.bnet, k.structure, evidence.test, evidence.header, ...
                                                       property.output.inference_result, ...
                                                       inference_prior);
                                else
                                        log_message(fid_log, ...
                                                    'Inference the slow way\n');
                                        inference_bnet(skill, ...
                                                       k.bnet, k.structure, evidence.test, evidence.header, ...
                                                       property.output.inference_result, ...
                                                       inference_prior);
                                end 

                                log_message(fid_log, '\twrite inference_result success\n');
                        catch
                                err = lasterror;
                                log_message(fid_log, 'ERROR: %s\n', err.message);
                                for i = 1:size(err.stack),
                                  log_message(fid_log, 'STACK: %s(%d)\n', err.stack(i).file, err.stack(i).line);
                                end
                        end

                end;

        catch
                        log_message(fid_log, 'Test data not available for inference\n');
        end

        % store hash_bnet

        hash_bnet(skill) = k;

        drawnow
end

save hash_bnet.mat hash_bnet;


log_message(fid_log, 'Finished\n');

fclose(fid_log);
