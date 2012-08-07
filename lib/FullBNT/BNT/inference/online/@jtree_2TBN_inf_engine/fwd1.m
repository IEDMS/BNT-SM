function [f, logscale] = fwd1(engine, ev, t)
% Forwards pass for slice 1.

bnet = bnet_from_engine(engine);
ss = bnet.nnodes_per_slice;

CPDpot = cell(1,ss);
for n=1:ss
  fam = family(bnet.dag, n, 1);
  e = bnet.equiv_class(n, 1);
  CPDpot{n} = convert_to_pot(bnet.CPD{e}, engine.pot_type, fam(:), ev);
end       
f.evidence = ev;
f.t = t;

pots = CPDpot;

% Kaimin - 1) f.pots stores parameters
f.pots = pots;

slice1 = 1:ss;
CPDclqs = engine.clq_ass_to_node1(slice1);

% Kaimin
[f.clpot, f.seppot] =  init_pot(engine.jtree_engine1, CPDclqs, CPDpot, engine.pot_type, get_onodes(ev, engine.observed1));
%[f.clpot, f.seppot] =  init_pot(engine.jtree_engine1, CPDclqs, CPDpot, engine.pot_type, engine.observed1);

% Kaimin - 2) f.clpot0 stores the raw joint prob
f.clpot0 = f.clpot;

[f.clpot, f.seppot] = collect_evidence(engine.jtree_engine1, f.clpot, f.seppot);

% Kaimin - 3) f.joint stores the joint prob given evidence
f.joint = f.clpot;

% Kaimin - 4) f.clpot stores the conditional prob
for c=1:length(f.clpot)
  [f.clpot{c}, ll(c)] = normalize_pot(f.clpot{c});
end
logscale = ll(engine.root1);

% Kaimin
f.ll = logscale;
