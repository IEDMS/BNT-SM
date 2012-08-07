function inference_bnet(skill, bnet, structure, hash_evidence, header, inference_result, inference_prior)
% Do inference the slow way, by redoing the whole sequence of
% inferences for each new time frame, as opposed to selecting a
% slice of the data containing data for the current time frame alone.
if nargin < 7, 
   inference_prior = 0;
end
	
fid_inference_result = fopen(inference_result, 'a');

hash_evidence_skill = hash_evidence(skill);
[students cases] = get_evidence(hash_evidence, skill);

[user_list idx] = sort(students);
for j = 1:length(user_list),
	user = user_list{j};

	hash_evidence_skill_user = hash_evidence_skill(user);
	casex = cases{ idx(j) };
	[M T] = size(casex);

	for t = 1:T,
		casext = casex(:,1:t);          % default inference posterior

		% Hack

		if inference_prior == 1,
			casext(:,t) = cell(size(casext(:,t)));  % inference prior
		end
		engine = smoother_engine(jtree_2TBN_inf_engine(bnet));


		[engine, ll] = enter_evidence( engine, casext );

		fields = tokenizer(hash_evidence_skill_user.R{t}, '	');

		for m = 1:M,
			% the if statement is to only inference latent variables
			if strcmp(structure.nodes(m).node.latent, 'yes'),
				marg = marginal_nodes(engine, m, t);

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

		fprintf(fid_inference_result, '%s\n', cell2str(fields));
	end
end

fclose(fid_inference_result);
