% Lawn sprinker example from Russell and Norvig p454
% For a picture, see http://www.cs.berkeley.edu/~murphyk/Bayes/usage.html#basics

N = 4; 
dag = zeros(N,N);
C = 1; S = 2; R = 3; W = 4;
dag(C,[R S]) = 1;
dag(R,W) = 1;
dag(S,W)=1;

false = 1; true = 2;
ns = 2*ones(1,N); % binary nodes

%bnet = mk_bnet(dag, ns);
bnet = mk_bnet(dag, ns, 'names', {'cloudy','S','R','W'}, 'discrete', 1:4);
names = bnet.names;
%C = names{'cloudy'};
bnet.CPD{C} = tabular_CPD(bnet, C, [0.5 0.5]);
bnet.CPD{R} = tabular_CPD(bnet, R, [0.8 0.2 0.2 0.8]);
bnet.CPD{S} = tabular_CPD(bnet, S, [0.5 0.9 0.5 0.1]);
bnet.CPD{W} = tabular_CPD(bnet, W, [1 0.1 0.1 0.01 0 0.9 0.9 0.99]);


engine = jtree_inf_engine(bnet);

evidence = cell(1,N);
evidence{W} = true;

[engine, ll] = enter_evidence(engine, evidence);

m = marginal_nodes(engine, S);
p1 = m.T(true) % P(S=true|W=true) = 0.4298
lik1 = exp(ll); % P(W=true) = 0.6471
assert(approxeq(p1, 0.4298));
assert(approxeq(lik1, 0.6471));


m = marginal_nodes(engine, R);
p2 = m.T(true)  % P(R=true|W=true) =  0.7079     


% Add extra evidence that R=true
evidence{R} = true;

[engine, ll] = enter_evidence(engine, evidence);

m = marginal_nodes(engine, S);
p3 = m.T(true) % P(S=true|W=true,R=true) = 0.1945 
assert(approxeq(p3, 0.1945))

% So the sprinkler is less likely to be on if we know that
% it is raining, since the rain can "explain away" the fact
% that the grass is wet.

lik3 = exp(ll); % P(W=true, R=true) = 0.4581
% So the combined evidence is less likely (of course)




% Joint distributions

evidence = cell(1,N);
[engine, ll] = enter_evidence(engine, evidence);
m = marginal_nodes(engine, [S R W]);

evidence{R} = 2;
[engine, ll] = enter_evidence(engine, evidence);
m = marginal_nodes(engine, [S R W]);



