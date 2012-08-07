function inference_bnet2(skill, bnet, structure, hash_evidence, header, inference_result, inference_prior)
% Do inference the fast way, by selecting a slice of the data
% containing data for the current time frame alone, as opposed to
% redoing the whole sequence of inferences for each new time frame.
if nargin < 7, 
   inference_prior = 0;
end
        
fid_inference_result = fopen(inference_result, 'a');

hash_evidence_skill = hash_evidence(skill);
[students cases] = get_evidence(hash_evidence, skill);


[bnet2 num_between_nodes] = make_bnet2(bnet);

[user_list idx] = sort(students);
for j = 1:length(user_list),
        user = user_list{j};

        hash_evidence_skill_user = hash_evidence_skill(user);
        casex = cases{ idx(j) };
        [M T] = size(casex);

        if inference_prior == 1,
                start_index = 0;
        else
                start_index = 1;
        end
        
        for t = 1:T,
                for posterior = start_index:1,
                        if t == 1,
                                if posterior == 0,
                                        casext = cell(size(casex(:,1))); % inference prior
                                else
                                        casext = casex(:,1);
                                end
                                engine = smoother_engine(jtree_2TBN_inf_engine(bnet));
                        else
                                casex_between = cell(1,num_between_nodes);
                                if posterior == 0,
                                        casext = {casex_between{:}, casex{:,t}}';
                                        casext = cell(size(casext)); % inference prior
                                else
                                        casext = {casex_between{:}, casex{:,t}}';
                                end

                                n = 1;
                                for m = 1:M,
                                        if length(structure.nodes(m).node.between) > 0,
                                                bnet2.CPD{n} = tabular_CPD(bnet2, n, margs{m}.T);
                                                n = n + 1;
                                        end
                                end
                                engine = jtree_inf_engine(bnet2);
                        end
                        
                        [engine, ll] = enter_evidence( engine, casext );

                        fields = tokenizer(hash_evidence_skill_user.R{t}, '     ');

                        for m = 1:M,
                                % the if statement is to only infer latent variables
                                if strcmp(structure.nodes(m).node.latent, 'yes'),
                                        if t == 1,
                                                marg = marginal_nodes(engine, m, t);
                                        else
                                                marg = marginal_nodes(engine, m + num_between_nodes);
                                        end   
                                        if posterior == 1,
                                          margs{m} = marg;
                                        end

                                        % Hack
                                        
                                        if strcmp(structure.nodes(m).node.values, '2'),
                                                % print only P(TRUE) for binary variables
                                                fields{ header( structure.nodes(m).node.field ) } = marg.T(2);
                                        else
                                                % print all values
                                                fields{ header( structure.nodes(m).node.field ) } = mat2str(marg.T);
                                        end
                                end
                        end
                        if posterior == start_index,
                                fprintf(fid_inference_result, '%s\n', ...
                                        cell2str(fields));
                        end
                end
        end
end

fclose(fid_inference_result);
