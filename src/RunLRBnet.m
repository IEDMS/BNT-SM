% Author: Yanbo
% Date: 2011-11-05
% modify RunBnet.m to support LR-DBN

function [property evidence hash_bnet] = RunLRBnet(property_xml)

% 1. property

disp('1. property');
property = xml_load(property_xml);

output_setup_done = 0;

fid_log = fopen(property.output.log, 'w');

%xxxxxxxxxxxxxxx
if(~strcmpi(property.multi_subskill, 'yes')),
   log_message(fid_log, ['ERROR: This is for LR-DBN.\n']); 
   fclose(fid_log);
   return;
else
   log_message(fid_log, ['This is LR-DBN.\n']);
end
%xxxxxxxxxxxxxxxxx

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
        fclose(fid_log);
        return;
end

if (exist(property.input.evidence_test)),
        evidence_test_date = dir(property.input.evidence_test);
        evidence_test_date = datenum(evidence_test_date.date);
else
        evidence_test_date = 0;
        log_message(fid_log, [property.input.evidence_test ' not found\n']);
        fclose(fid_log);
        return;
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
                try
                    load([data_dir '/' skill '.mat']);
                    load('kc_names.mat');
                catch
                    err = lasterror;
                    log_message(fid_log, 'ERROR: %s(%d): %s\n', err.stack(1).file, err.stack(1).line, err.message);
                    fclose(fid_log);
                    return;
                end
        else
                previous_skill = skill;
                skill = '';
                %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
                try [evidence.train evidence.header skill position_train kc_train_names] = ...
                        table2LRevidence( fid_log, ...
                                        property.input.evidence_train, ...
                                        property.structure, ...
                                        position_train);
                catch
                    err = lasterror;
                    log_message(fid_log, 'ERROR: %s(%d): %s\n', err.stack(1).file, err.stack(1).line, err.message);
                    fclose(fid_log);
                    return;
                end  
                %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
                
                if (strcmp(skill, '')),
                  done = 1;
                  continue;
                end
                pass = 0;
                while (~pass),
                        test_skill ='';
                        try [evidence.test temp test_skill new_position_test kc_test_names] = ...
                            table2LRevidence( fid_log, ...
                                            property.input.evidence_test, ...
                                            property.structure, ...
                                            position_test);
                        catch
                            err = lasterror;
                            log_message(fid_log, 'ERROR: %s(%d): %s\n', err.stack(1).file, err.stack(1).line, err.message);
                            fclose(fid_log);
                            return;
                        end         
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
                save kc_names.mat kc_train_names;
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
                %xxxxxxxxxxxxxxxxxxxx
                k.bnet0 = make_LRbnet(k.structure);
                %xxxxxxxxxxxxxxxxxxxx

                log_message(fid_log, 'success\n');
        catch
                err = lasterror;
                log_message(fid_log, 'ERROR: %s(%d): %s\n', err.stack(1).file, err.stack(1).line, err.message);
                fclose(fid_log);
                return;
        end

        % train bnet
        log_message(fid_log, '\ttrain bnet... ');

        tic;
        try
                [users cases k.num_users k.num_cases] = get_evidence(evidence.train, skill);
                k.bnet = [];
                [k.bnet k.ll] = learn_bnet(k.bnet0, cases);
                log_message(fid_log, 'success\n');
        catch
                err = lasterror;
                log_message(fid_log, 'ERROR: %s(%d): %s\n', err.stack(1).file, err.stack(1).line, err.message);
        end
        training_elapsed = toc;
        log_message(fid_log, '\tTraining elapsed time %f s\n', training_elapsed);
        
        if isempty(k.bnet)
           log_message(fid_log, 'Skip fitting skill %s, because of Rank deficient\n', skill);
           done = 0;
           continue;
        end

        % setup the header of the output files
        % currently hard-wired script
        %xxxxxxxxxxxxxxx
        output_setup_done = setup_LRoutput(output_setup_done, property, ...
                                                       kc_train_names, evidence);
        %xxxxxxxxxxxxxxx
        
        % write param_table
        log_message(fid_log, '\twriting param_table...\n');

        try
                %xxxxxxxxxx
                k.param = extract_LRparam(fid_log, k);
                extract_LRbnet(k, property.output.param_table);
                %xxxxxxxxxx
                log_message(fid_log, '\twrite param_table success\n');
        catch
                err = lasterror;
                log_message(fid_log, 'ERROR: write param_table %s(%d): %s\n', err.stack(1).file, err.stack(1).line, err.message);
        end

        % write inference_result
        log_message(fid_log, '\tWriting inference_result...\n');

        inference_prior = 0;
        try
                if ~isempty(evidence.test(skill)),
                        try
                                % Hack
                                %if (strcmpi(property.output.inference_is_prior, 'yes')),
                                %        log_message(fid_log, ['Output inference will be prior\n']);
                                %        inference_prior = 1;
                                %else
                                %        inference_prior = 0;
                                %        log_message(fid_log, ['Output inference will be posterior\n']);
                                %end
                                
                                %if (strcmpi(property.inference, 'fast')),
                                %        log_message(fid_log, ...
                                %                    'Inference the fast way\n');
                                %        inference_LRbnet2(skill, ...
                                %                       k.bnet, k.structure, evidence.test, evidence.header, ...
                                %                       property.output.inference_result, ...
                                %                       inference_prior);
                                %else
                                %        log_message(fid_log, ...
                                %                    'Inference the slow way\n');
                                        inference_LRbnet(skill, ...
                                                       k.bnet, k.structure, evidence.test, evidence.header, ...
                                                       property.output.inference_result, ...
                                                       inference_prior);
                                %end 

                                log_message(fid_log, '\twrite inference_result success\n');
                        catch
                                err = lasterror;
                                log_message(fid_log, 'ERROR: %s\n', err.message);
                                for i = 1:size(err.stack),
                                  log_message(fid_log, 'STACK: %s(%d)\n', err.stack(i).file, err.stack(i).line);
                                end
                                fclose(fid_log);
                                return;
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
