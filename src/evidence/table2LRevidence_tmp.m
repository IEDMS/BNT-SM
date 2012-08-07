%Takes a table generated from the observed data and converts it into a hash
%table of all relevant information.

function [hash_evidence H C skill position_out kc_names] = table2LRevidence(fid_log, ...
                                                  table, structure, ...
                                                  position_in)

% 1. pre-fetch format of evidence from structure

[M H C R skill position_out] = tablescan(fid_log, table, position_in);
if strcmp(skill,''),
    hash_evidence = [];
    kc_names = [];
    return; 
end
[num_record num_field] = size(M);

% 2. count

hash_evidence_count = hashtable;
for i=1:num_record,

	%user_skill = [C{ H('user') }{i} C{ H('skill') }{i}];
    user_skill = ['xx' C{ H('skill') }{i}];

	if ~iskey(hash_evidence_count, user_skill),
		hash_evidence_count(user_skill) = 0;
	end

	c = hash_evidence_count(user_skill);

	hash_evidence_count(user_skill) = c + 1;
end

% 3. construct evidence

%xxxxxxxxxxxxxxxxxxxxxxxxxx
%There can only be one single multi-subskills node
nodes = structure.nodes;
kc_id = 0;
for i=1:length(nodes),
   type = nodes(i).node.type;
   if (strcmpi(type, 'multi')),
      if (kc_id ~= 0),
        error('ERROR: There can only be one single multi-subskills node');  
      else
        kc_id = i; 
      end
   end
end
%xxxxxxxxxxxxxxxxxxxxxxxxxxxx

hash_evidence = hashtable; 
for i=1:num_record,
	%user = C{ H('user') }{i};
    user = 'xx';
	if (~strcmp(skill, ['skill_' C{ H('skill') }{i}])),
          log_message(fid_log, ['Slipped in: skill_' C{ H('skill') ...
                   }{i}]);
        end

	user_skill = [user C{ H('skill') }{i}];

	% 1. get skill

	if ~iskey(hash_evidence, skill),
		hash_evidence(skill) = hashtable;
	end

	hash_evidence_skill = hash_evidence(skill);

	% 2. get user

	if ~iskey(hash_evidence_skill, user),
        %xxxxxxxxxxx
        %len = length(structure.nodes)-1 + nodes(kc_id).node.values;
        %xxxxxxxxx
		k.ev = cell( length(structure.nodes) , hash_evidence_count(user_skill) );
		k.R = {};
		hash_evidence_skill(user) = k;
		hash_evidence_count(user_skill) = 0;
	end

	k = hash_evidence_skill(user);

	% 3. get evidence

	c = hash_evidence_count(user_skill) + 1;
	hash_evidence_count(user_skill) = c;

	for j=1:length(structure.nodes),
        %xxxxxxxxxxxxxxxxxx M_kc =[]]]]]
        if (j == kc_id),
            kc_head = nodes(kc_id).node.field;
            Hkeys = keys(H);            
            kc_pos = find(strncmp(strcat(kc_head,'_'),Hkeys,length(kc_head)+1));
            if length(kc_pos) ~= str2num(nodes(kc_id).node.values),
               error('ERROR: Node %s should have [%d] values but field %s has [%d] columns in %s',... 
                        nodes(kc_id).node.name, str2num(nodes(kc_id).node.values), nodes(kc_id).node.field, length(kc_pos), table); 
            end
            kc_names = cell(1,length(kc_pos));
            M_kc = [];
            for jj = 1:length(kc_pos),
               M_kc = [M_kc,M(i,H(Hkeys{kc_pos(jj)}))]; 
               kc_names{jj} = Hkeys{kc_pos(jj)};
            end
            k.ev{j,c} = M_kc;
        else
            k.ev{j, c} = M( i, H(structure.nodes(j).node.field) );
        end
        %xxxxxxxxxxxxxxxxxx
		if isnan(k.ev{j, c}), k.ev{j, c} = []; end
	end
	
 	% 4. cache evidence file

	k.R{ length(k.R) + 1 } = R{i};

	% 5. add to hash_evidence

	hash_evidence_skill(user) = k;

	hash_evidence(skill) = hash_evidence_skill;

end
