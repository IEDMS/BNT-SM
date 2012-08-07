% Compare various inference engines on the following network (from Jensen (1996) p84 fig 4.17)
%    1
%  / | \
% 2  3  4
% |  |  |
% 5  6  7
%  \/ \/
%  8   9
% where all arcs point downwards
seed = 0;
rand('state', seed);
randn('state', seed);

N = 9;
dag = zeros(N,N);
dag(1,2)=1; dag(1,3)=1; dag(1,4)=1;
dag(2,5)=1; dag(3,6)=1; dag(4,7)=1;
dag(5,8)=1; dag(6,8)=1; dag(6,9)=1; dag(7,9) = 1;

dnodes = 1:N;
false = 1; true = 2;
ns = 2*ones(1,N); % binary nodes

onodes = [2 4];
bnet = mk_bnet(dag, ns, 'observed', onodes);
% use random params
for i=1:N
  bnet.CPD{i} = tabular_CPD(bnet, i);
end

%USEC = exist('@jtree_C_inf_engine/collect_evidence','file');
query = [3];
engine = {};
engine{end+1} = jtree_inf_engine(bnet);
engine{end+1} = jtree_sparse_inf_engine(bnet);
%engine{end+1} = jtree_ndx_inf_engine(bnet, 'ndx_type', 'SD');
%engine{end+1} = jtree_ndx_inf_engine(bnet, 'ndx_type', 'B');
%engine{end+1} = jtree_ndx_inf_engine(bnet, 'ndx_type', 'D');
%if USEC, engine{end+1} = jtree_C_inf_engine(bnet); end
%engine{end+1} = var_elim_inf_engine(bnet);
%engine{end+1} = enumerative_inf_engine(bnet);
%engine{end+1} = jtree_onepass_inf_engine(bnet, query, onodes);

maximize = 0;  % jtree_ndx crashes on max-prop
[err, time] = cmp_inference_static(bnet, engine, 'maximize', maximize);

