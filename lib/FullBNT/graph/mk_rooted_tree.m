function [T, pre, post, cycle] = mk_rooted_tree(G, root)
% MK_ROOTED_TREE Make a directed, rooted tree out of an undirected tree.
% [T, pre, post, cycle] = mk_rooted_tree(G, root)

n = length(G);
T = sparse(n,n); % not the same as T = sparse(n) !
directed = 0;
[d, pre, post, cycle, f, pred] = dfs(G, root, directed);
%[d, pre, post, cycle, f, pred] = dfs(G, [], directed);
for i=1:length(pred)
  if pred(i)>0
    T(pred(i),i)=1;
  end
end

