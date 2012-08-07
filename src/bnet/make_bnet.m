% Given the structure for the bnet specified in the initialization file,
% make_bnet will construct the corresponding network, including all
% transitions and equivalence classes.

function [bnet] = make_bnet(structure)

s = structure;
eval(s.var);

% 0. Get the number of nodes per time slice, and the associated names with
%    each node

N = length(s.nodes);

hash_id2name = hashtable;
hash_name2id = hashtable;

for i=1:length(s.nodes),
        hash_id2name( str2num(s.nodes(i).node.id) ) = s.nodes(i).node.name;
        hash_name2id( s.nodes(i).node.name ) = str2num(s.nodes(i).node.id);
end

% 1. Create the transition matrices, and declare latent/observed nodes

names = cell(N,1);
node_sizes = zeros(N,1);
dnodes = [];
cnodes = [];
onodes = [];
lnodes = [];
dag = zeros(N);
inter_dag = zeros(N);

for i=1:length(s.nodes),
        node = s.nodes(i).node;
        id = str2num(node.id);

        names{id} = node.name;

        node_sizes(id) = str2num( node.values );

        if strcmpi( node.type, 'discrete' ),
        dnodes = [dnodes id];
        else
                cnodes = [cnodes id];
    end

        if strcmpi( node.latent, 'no' ),
        onodes = [onodes id];
        else
                lnodes = [lnodes id];
    end

        for j=1:length(node.within),
                dest = hash_name2id(node.within(j).transition);
                dag(id, dest) = 1;
        end

        for j=1:length(s.nodes(i).node.between),
                dest = hash_name2id(node.between(j).transition);
                inter_dag(id, dest) = 1;
        end
end

% 2. Equivalence classes

eclass1 = 1:N;  % each node in a time slice is unique

eclass2 = 1:N;
num_equiv = N;

for i=1:N,
        if sum(inter_dag(:,i)) > 0
                num_equiv = num_equiv + 1;
                eclass2(i) = num_equiv;
        end
end

% 3. Use the DBN constructor

bnet = mk_dbn(dag, inter_dag, node_sizes, ...
        'names', names, ...
        'discrete', dnodes, ...
        'observed', onodes, ...
        'eclass1', eclass1, ...
        'eclass2', eclass2);

% 4. Acquire the conditional probability tables

for i=1:length(s.eclasses),
        eclass = s.eclasses(i).eclass;
        e = str2num( eclass.id );

        [tok] = regexp(eclass.formula, '(P[0-9]+)\(([^\|]+).*\)', 'tokens');
        P = tok{:}{1};
        name = tok{:}{2};


        if strcmpi(eclass.clamp, 'yes'),
                clamp = 1;
        else,
                clamp = 0;
        end

        if strcmpi(eclass.type, 'discrete'),

                for j=1:length(eclass.cpd)
                        eq = expand(eclass.cpd(j).eq);
                        init = expand(eclass.cpd(j).init);

                        eval( [eq ' = ' init ';'] );
                end

                P = eclass.formula(1:findstr(eclass.formula, '(')-1);
                if (isfield(eclass, 'dirichlet')),
                        for j=1:length(eclass.dirichlet)
                                eq = expand(eclass.dirichlet(j).eq);
                                init = expand(eclass.dirichlet(j).init);

                                eval( [eq ' = ' init ';'] );
                        end
                        bnet.CPD{e} = tabular_CPD( bnet, bnet.rep_of_eclass(e), ...
                                                   'CPT', eval(P), ...
                                                   'clamped', clamp, ...
                                                   'prior_type', 'dirichlet', ...
                                                   'dirichlet_type', 'unif', ...
                                                   'dirichlet_weight', eval([P '_dir']));
                else
                % P2CPD
                
                        bnet.CPD{e} = tabular_CPD( bnet, bnet.rep_of_eclass(e), ...
                                                   'CPT', eval(P), ...
                                                   'clamped', clamp );
                end
       
        elseif strcmpi(eclass.type, 'gaussian'),

                bnet.CPD{e} = gaussian_CPD( bnet, bnet.rep_of_eclass(e) );

                %bnet.CPD{e} = gaussian_CPD( bnet, bnet.rep_of_eclass(e), ...
                                %'mean', eval(eclass.cpd.mean), ...
                                %'cov', eval(eclass.cpd.cov) );
                                %'weights', eval(eclass.cpd.weights) );

        end
end
