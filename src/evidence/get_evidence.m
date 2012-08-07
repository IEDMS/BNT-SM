function [users cases num_users num_cases] = get_evidence(hash_evidence, skill)

hash_evidence_skill = hash_evidence(skill);

users = keys( hash_evidence_skill );
num_users = length(users);

cases = cell(1, num_users);
num_cases = 0;

for i=1:num_users,
    k = hash_evidence_skill(users{i});
    cases{i} = k.ev;

    [m T] = size( cases{i} );
    num_cases = num_cases + T;
end

