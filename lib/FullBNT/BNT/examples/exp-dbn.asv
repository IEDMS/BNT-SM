% KCt  KCt+1 
% |     |
% St   St+1
% |     |
% Kt - Kt+1
% |     |
% Ft   Ft+1
T = 3;

KC = 1:T;
K = T+1:2*T;
F = 2*T+1:3*T;

N = 3*T;
dag = zeros(N);

for i = 1:T-1
    dag(K(i),K(i+1)) = 1;
    dag(KC(i),K(i)) = 1;
    dag(K(i),F(i)) = 1;
end
dag(KC(T),K(T)) = 1;
dag(K(T),F(T)) = 1;

hnodes = T+1:2*T;
onodes = [1:T [2*T+1:3*T]];
dnodes = T+1:3*T;

ns = [3 2 2];

O1class = 1;
O2class = 2;
O3class = 3;
Hclass = 4;

eclass = ones(1,N);
eclass(onodes(1)) = O1class;
eclass(onodes(2:T)) = O2class;
eclass(onodes(T+1:end)) = O3class;
eclass(hnodes(1:end)) = Hclass;


bnet = mk_bnet(dag, ns, 'observed', onodes, 'discrete', dnodes, 'equiv_class', eclass);

IRLS_iter = 10;
clamped = 0;

bnet.CPD{O1class} = root_CPD(bnet,onodes(1));
bnet.CPD{O2class} = root_CPD(bnet,onodes(2));
rand('state', 0);
randn('state', 0);
bnet.CPD{O3class} = softmax_CPD(bnet, onodes(T+1:end), 'clamped', clamped, 'max_iter', IRLS_iter);

