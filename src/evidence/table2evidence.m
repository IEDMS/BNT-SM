%Takes a table generated from the observed data and converts it into a hash
%table of all relevant information.

function [hash_evidence H skill position_out] = table2evidence(fid_log, ...
                                                  table, structure, ...
                                                  position_in)

% 1. pre-fetch format of evidence from structure

   [M H C R skill position_out] = tablescan(fid_log, table, position_in);
[num_record num_field] = size(M);

% 2. count

hash_evidence_count = hashtable;
for i=1:num_record,

	user_skill = [C{ H('user') }{i} C{ H('skill') }{i}];

	if ~iskey(hash_evidence_count, user_skill),
		hash_evidence_count(user_skill) = 0;
	end

	c = hash_evidence_count(user_skill);

	hash_evidence_count(user_skill) = c + 1;
end

% 3. construct evidence

hash_evidence = hashtable; 
for i=1:num_record,
	user = C{ H('user') }{i};
	if (~strcmp(skill, ['skill_' C{ H('skill') }{i}])),
          log_message(fid_log, ['Slipped in: skill_' C{ H('skill') ...
                   }{i}]);
        end

	user_skill = [C{ H('user') }{i} C{ H('skill') }{i}];

	% 1. get skill

	if ~iskey(hash_evidence, skill),
		hash_evidence(skill) = hashtable;
	end

	hash_evidence_skill = hash_evidence(skill);

	% 2. get user

	if ~iskey(hash_evidence_skill, user),
		k.ev = cell( length(structure.nodes), hash_evidence_count(user_skill) );
		k.R = {};
		hash_evidence_skill(user) = k;
		hash_evidence_count(user_skill) = 0;
	end

	k = hash_evidence_skill(user);

	% 3. get evidence

	c = hash_evidence_count(user_skill) + 1;
	hash_evidence_count(user_skill) = c;

	for j=1:length(structure.nodes),
		k.ev{j, c} = M( i, H(structure.nodes(j).node.field) );
		if isnan(k.ev{j, c}), k.ev{j, c} = []; end
	end
	
 	% 4. cache evidence file

	k.R{ length(k.R) + 1 } = R{i};

	% 5. add to hash_evidence

	hash_evidence_skill(user) = k;

	hash_evidence(skill) = hash_evidence_skill;

end
