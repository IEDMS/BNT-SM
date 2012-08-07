% Author: Yanbo
% Date: 2011-11-05
% modify RunBnet.m to support LR-DBN

function [property evidence hash_bnet] = TestLRBnet(property_xml, test_evidence, inference_result)

% 1. property

if nargin < 3, 
   disp('Usage: [property evidence hash_bnet] = TestLRBnet(property_xml file name, test_evidence file name, inference_result file name)');
   return;
end

disp('1. property');
property = xml_load(property_xml);

output_setup_done = 0;

fid_log = fopen(property.output.log, 'w');

try
    load('hash_bnet.mat');
    load('kc_names.mat');
catch 
   err = lasterror;
   log_message(fid_log, 'ERROR: %s(%d): %s\n', err.stack(1).file, err.stack(1).line, err.message);
   fclose(fid_log);
   return;
end

% Reset the output file
if (exist(inference_result)),
    delete(inference_result);
end

% Save the header
%try
%    headers = keys(evidence.header);
%    fid_inference_header = fopen(inference_result, 'w');
%    for i = 1:length(headers),
%        fprintf(fid_inference_header, '%s\t', headers{i});
%    end
%    fprintf(fid_inference_header, '\n');
%    fclose(fid_inference_header);
%catch
%    err = lasterror;
%    log_message(fid_log, 'ERROR: %s(%d): %s\n', err.stack(1).file, err.stack(1).line, err.message);
%    fclose(fid_log);
%    return;
%end
    
position_test = 0;
skill = '';
mat_load_index = 0;
pass = 0;

log_message(fid_log, '2. evidence\n');
while (~pass),
    test_skill ='';
    try [evidence.test evidence.header test_skill new_position_test kc_test_names] = ...
            table2LRevidence( fid_log, ...
                              test_evidence, ...
                              property.structure, ...
                              position_test);
    catch
        err = lasterror;
        log_message(fid_log, 'ERROR: %s(%d): %s\n', err.stack(1).file, err.stack(1).line, err.message);
        fclose(fid_log);
        return;
    end         
    
    if(strcmp(test_skill,''))
        pass = 1;
        position_test = new_position_test;
        continue;
    end
    position_test = new_position_test;
    
    log_message(fid_log, '   2.2 test evidence: %s reading finished\n', test_skill);

    log_message(fid_log, '3. infer bnet\n');
    if isempty(hash_bnet(test_skill)),
        log_message(fid_log,'Warning: Discard %s, there are no matching parameters in hash_bnet.mat\n');
        continue;
    end

    k = hash_bnet(test_skill);
    
    % write inference_result
    log_message(fid_log, '\tWriting inference_result...\n');
    inference_prior = 0;

    try
                               
        inference_LRbnet(test_skill, ...
            k.bnet, k.structure, evidence.test, evidence.header, ...
            inference_result, inference_prior);

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

log_message(fid_log, 'Finished\n');

fclose(fid_log);
