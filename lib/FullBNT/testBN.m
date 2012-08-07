clear all;

seed = 0;
rand('state', seed);
randn('state', seed);

% #########################################
% 0. graphical model
% #########################################

N = 4;
C = 1; S = 2; R = 3; W = 4;

dag = zeros(N);
dag(C, [R S]) = 1;
dag(R, W) = 1;
dag(S, W) = 1;

node_sizes = 2 * ones(1,N);
dnodes = 1:N;
onodes = [];

bnet = mk_bnet(dag, node_sizes, ...
	'discrete', dnodes, ...
	'observed', onodes, ...
	'names', {'cloudy', 'sprinkler', 'rain', 'wetgrass'} );

% #########################################
% 1. CPD
% #########################################

bnet.CPD{C} = tabular_CPD(bnet, C, [0.5 0.5]);
bnet.CPD{R} = tabular_CPD(bnet, R, [0.8 0.2 0.2 0.8]);
bnet.CPD{S} = tabular_CPD(bnet, S, [0.5 0.9 0.5 0.1]);
bnet.CPD{W} = tabular_CPD(bnet, W, [1 0.1 0.1 0.01 0 0.9 0.9 0.99]);

% #########################################
% 2. inference
% #########################################

evidence = cell(1,N);
evidence{W} = 2;
%evidence{R} = 2;

soft_evidence = cell(1,N);

engine = jtree_inf_engine(bnet);
[engine, loglik] = enter_evidence(engine, evidence, ...
	'soft', soft_evidence);

% 2.1 marginal probability

marg = marginal_nodes(engine, S);
%marg = marginal_nodes(engine, W, 1);
%marg = marginal_nodes(engine, [S R W], 1);

marg.T
%bar(marg.T)

% 2.2 most probable explanation

[mpe, loglik] = calc_mpe(engine, evidence)

% #########################################
% 4 learn param
% #########################################

% create a random bnet

bnet2 = mk_bnet(dag, node_sizes);
bnet2.CPD{C} = tabular_CPD(bnet2, C);
bnet2.CPD{R} = tabular_CPD(bnet2, R);
bnet2.CPD{S} = tabular_CPD(bnet2, S);
bnet2.CPD{W} = tabular_CPD(bnet2, W);

% 4.1 MLE learn param (fully observable)

nsamples = 30;
samples = cell(N, nsamples);
for i = 1:nsamples,
	samples(:,i) = sample_bnet(bnet);
end

bnet_mle = learn_params(bnet2, samples);

% 4.2 learn param (partially observable)

samples2 = samples;
hide = rand(N, nsamples) > 0.5;
[I,J] = find(hide);
for k = 1:length(I),
	samples2{ I(k), J(k) } = [];
end

engine2 = jtree_inf_engine(bnet2);
max_iter = 10;
[bnet_em, LLtrace] = learn_params_em(engine2, samples2, max_iter);

% summary

peak( bnet.CPD{4} )
peak( bnet_mle.CPD{4} )
peak( bnet_em.CPD{4} )

% #########################################
% 5 learn structures
% #########################################

draw_graph(bnet.dag);
