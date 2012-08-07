function order = best_first_elim_order(G, node_sizes, stage)
% BEST_FIRST_ELIM_ORDER Greedily search for an optimal elimination order.
% order = best_first_elim_order(moral_graph, node_sizes)
%
% Find an order in which to eliminate nodes from the graph in such a way as to try and minimize the
% weight of the resulting triangulated graph.  The weight of a graph is the sum of the weights of each
% of its cliques; the weight of a clique is the product of the weights of each of its members; the
% weight of a node is the number of values it can take on.
%
% Since this is an NP-hard problem, we use the following greedy heuristic:
% at each step, eliminate that node which will result in the addition of the least
% number of fill-in edges, breaking ties by choosing the node that induces the lighest clique.
% For details, see
% - Kjaerulff, "Triangulation of graphs -- algorithms giving small total state space",
%      Univ. Aalborg tech report, 1990 (www.cs.auc.dk/~uk)
% - C. Huang and A. Darwiche, "Inference in Belief Networks: A procedural guide",
%      Intl. J. Approx. Reasoning, 11, 1994
%

% Warning: This code is pretty old and could probably be made faster.

n = length(G);
if nargin < 3, stage = { 1:n }; end % no constraints

% For long DBNs, it may be useful to eliminate all the nodes in slice t before slice t+1.
% This will ensure that the jtree has a repeating structure (at least away from both edges).
% This is why we have stages.
% See the discussion of splicing jtrees on p68 of
% Geoff Zweig's PhD thesis, Dept. Comp. Sci., UC Berkeley, 1998.
% This constraint can increase the clique size significantly.

MG = G; % copy the original graph
uneliminated = ones(1,n);
order = zeros(1,n);
t = 1;  % Counts which time slice we are on        
for i=1:n
  U = find(uneliminated);
  valid = myintersect(U, stage{t});
  % Choose the best node from the set of valid candidates
  score1 = zeros(1,length(valid));
  score2 = zeros(1,length(valid));
  for j=1:length(valid)
    k = valid(j);
    ns = myintersect(neighbors(G, k), U);
    l = length(ns);
    M = MG(ns,ns);
    score1(j) = l^2 - sum(M(:)); % num. added edges
    score2(j) = prod(node_sizes([k ns])); % weight of clique
  end
  j1s = find(score1==min(score1));
  j = j1s(argmin(score2(j1s)));
  k = valid(j);
  uneliminated(k) = 0;
  order(i) = k;
  ns = myintersect(neighbors(G, k), U);
  if ~isempty(ns)
    G(ns,ns) = 1;
    G = setdiag(G,0);
  end
  if ~any(logical(uneliminated(stage{t}))) % are we allowed to the next slice?
    t = t + 1;
  end   
end

