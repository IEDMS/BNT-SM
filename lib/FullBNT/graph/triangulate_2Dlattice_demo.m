% Consider a 3x3 lattice with 4-nearest neighbor connectivity

% 1 - 2 - 3
% |   |   |
% 4 - 5 - 6
% |   |   |
% 7 - 8 - 9

N = 3;
G = mk_2D_lattice(N,N,4);


% Now add in the diagonal edges

% 1 - 2 - 3
% | x | x |
% 4 - 5 - 6
% | x | x |
% 7 - 8 - 9

G(1,5)=1; G(5,1)=1;
G(2,6)=1; G(6,2)=1;
G(4,2)=1; G(2,4)=1;
G(5,3)=1; G(3,5)=1;

G(4,8)=1; G(8,4)=1;
G(5,9)=1; G(9,5)=1;
G(7,5)=1; G(5,7)=1;
G(8,6)=1; G(6,8)=1;

% Is this a chordal (triangulated) graph? No!

assert(~check_triangulated(G))

% The reason is that there is a chordless cycle around the outside nodes.
% To see this, imagine "picking up" node 5, leaving the rest on the plane
% (like a hoop skirt, or a tent), as shown below

% 1 - 2 - 3
% | /   \ |
% 4       6
% | \   / |
% 7 - 8 - 9


% However, if we add in the 4-6 arc, it will be chordal.

G2 = G;
G2(4,6)=1; G2(6,4)=1;
assert(check_triangulated(G2))

% Or we can add in the 2-8 arc
G2 = G;
G2(2,8)=1; G2(8,2)=1;
assert(check_triangulated(G2))


% Here is how we can discover which edges to fill in automatically 
% (although possibly sub-optimally)
weights = 2*ones(1,N*N); % all nodes are binary
greedy_order = best_first_elim_order(G, weights);
[GT, cliques, fill_ins] = triangulate(G, greedy_order)
assert(check_triangulated(GT))

% fill-ins = [4 6]

% Cliques are the overlapping squares  [1,2,4,5], [2 3 5 6], [4 5 7 8], [5 6 8 9]
% and the following caused by the fill-in: [2 4 5 6], [4 5 6 8]

% Connect the maximal cliques of the triangulate graph into a junction tree
[jtree, root, B, clq_weights] = cliques_to_jtree(cliques, weights);

% In this case, all cliques have weight 2^4 = 16


% Now consider size of max clique as a function of grid size
% Note: this is not necessarily the optimal triangulation

% N  5  10 15 16 17 18
% m  6  15 23 25 28 28
Ns = [5 10 15 16 17 18]; 
for i=1:length(Ns)
  N = Ns(i)
  G = mk_2D_lattice(N,N,4);
  weights = 2*ones(1,N*N); % all nodes are binary
  greedy_order = best_first_elim_order(G, weights); % slow!
  [GT, cliques, fill_ins] = triangulate(G, greedy_order);
  %assert(check_triangulated(GT))
  [jtree, root, B, clq_weights] = cliques_to_jtree(cliques, weights);
  m(i) = log2(max(clq_weights));
end

% plot distribution of clique sizes for fixed N
for c=1:length(cliques)
  l(c) = length(cliques{c});
end
hist(l)
