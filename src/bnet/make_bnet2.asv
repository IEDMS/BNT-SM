function [bnet2 num_between_nodes] = make_bnet2(bnet)

% 1. Create the transition matrices, and declare latent/observed nodes

N = bnet.nnodes_per_slice;

dag1 = bnet.dag(1:N,1:N);
dag2 = bnet.dag(1:N,N+1:end);
[r c] = find( sum(dag2,2) ~= 0 ); % find rows that have between connections
num_between_nodes = length(r);
N2 = num_between_nodes + N;
dag = [ zeros(N2, num_between_nodes) [dag2(r,:); dag1] ];

node_sizes = [bnet.node_sizes_slice(r) bnet.node_sizes_slice];

names = bnet.names;

dnodes = bnet.dnodes_slice + num_between_nodes;
for i=1:num_between_nodes,
	if ~isempty( find(bnet.dnodes_slice == r(i)) ),
		dnodes = [i dnodes];
	end
end

onodes = bnet.observed + num_between_nodes;
for i=1:num_between_nodes,
	if ~isempty( find(bnet.observed == r(i)) ),
		onodes = [i onodes];
	end
end

% 2. Use the Bnet constructor

bnet2 = mk_bnet(dag, node_sizes, ...
	'names', names, ...
	'discrete', dnodes, ...
	'observed', onodes);

% 3. Acquire the conditional probability tables

X = sum(dag); % X is num of between connection into a node
for i=1:num_between_nodes,
    bnet2.CPD{i} = tabular_CPD(bnet2, i, zeros((X(i)+1)*2,1) );
end

for i=num_between_nodes+1:N2,
    bnet2.CPD{i} = bnet.CPD{i - num_between_nodes};
end

for i=1:num_between_nodes,
    bnet2.CPD{num_between_nodes+r(i)} = bnet.CPD{N+i};
end
