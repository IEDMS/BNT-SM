function CPD = update_ess(CPD, fmarginal, evidence, ns, cnodes, hidden_bitv)
% UPDATE_ESS Update the Expected Sufficient Statistics of a Gaussian node
% function CPD = update_ess(CPD, fmarginal, evidence, ns, cnodes, hidden_bitv)

%if nargin < 6
%  hidden_bitv = zeros(1, max(fmarginal.domain));
%  hidden_bitv(find(isempty(evidence)))=1;
%end

dom = fmarginal.domain;
self = dom(end);
ps = dom(1:end-1);
cps = myintersect(ps, cnodes);
dps = mysetdiff(ps, cps);

CPD.nsamples = CPD.nsamples + 1;            
[ss cpsz dpsz] = size(CPD.weights); % ss = self size
[ss dpsz] = size(CPD.mean);

% Let X be the cts parent (if any), Y be the cts child (self).

if ~hidden_bitv(self) & ~any(hidden_bitv(cps)) & all(hidden_bitv(dps))
  % Speedup for the common case that all cts nodes are observed, all discrete nodes are hidden
  % Since X and Y are observed, SYY = 0, SXX = 0, SXY = 0
  % Since discrete parents are hidden, we do not need to add evidence to w.
  w = fmarginal.T(:);
  CPD.Wsum = CPD.Wsum + w;
  y = evidence{self};
  Cyy = y*y';
  if ~CPD.useC
     WY = repmat(w(:)',ss,1); % WY(y,i) = w(i)
     WYY = repmat(reshape(WY, [ss 1 dpsz]), [1 ss 1]); % WYY(y,y',i) = w(i)
     %CPD.WYsum = CPD.WYsum +  WY .* repmat(y(:), 1, dpsz);
     CPD.WYsum = CPD.WYsum +  y(:) * w(:)';
     CPD.WYYsum = CPD.WYYsum + WYY  .* repmat(reshape(Cyy, [ss ss 1]), [1 1 dpsz]);
  else
     W = w(:)';
     W2 = reshape(W, [1 1 dpsz]);
     CPD.WYsum = CPD.WYsum +  rep_mult(W, y(:), size(CPD.WYsum)); 
     CPD.WYYsum = CPD.WYYsum + rep_mult(W2, Cyy, size(CPD.WYYsum));
  end
  if cpsz > 0 % X exists
    x = cat(1, evidence{cps}); x = x(:);
    Cxx = x*x';
    Cxy = x*y';
    WX = repmat(w(:)',cpsz,1); % WX(x,i) = w(i)
    WXX = repmat(reshape(WX, [cpsz 1 dpsz]), [1 cpsz 1]); % WXX(x,x',i) = w(i)
    WXY = repmat(reshape(WX, [cpsz 1 dpsz]), [1 ss 1]); % WXY(x,y,i) = w(i)
    if ~CPD.useC
      CPD.WXsum = CPD.WXsum + WX .* repmat(x(:), 1, dpsz);
      CPD.WXXsum = CPD.WXXsum + WXX .* repmat(reshape(Cxx, [cpsz cpsz 1]), [1 1 dpsz]);
      CPD.WXYsum = CPD.WXYsum + WXY .* repmat(reshape(Cxy, [cpsz ss 1]), [1 1 dpsz]);
    else
      CPD.WXsum = CPD.WXsum + rep_mult(W, x(:), size(CPD.WXsum));
      CPD.WXXsum = CPD.WXXsum + rep_mult(W2, Cxx, size(CPD.WXXsum));
      CPD.WXYsum = CPD.WXYsum + rep_mult(W2, Cxy, size(CPD.WXYsum));
    end
  end
  return;
end

% general (non-vectorized) case
fullm = add_evidence_to_gmarginal(fmarginal, evidence, ns, cnodes); % slow!

if dpsz == 1 % no discrete parents
  w = 1;
else
  w = fullm.T(:);
end

CPD.Wsum = CPD.Wsum + w;
xi = 1:cpsz;
yi = (cpsz+1):(cpsz+ss);
for i=1:dpsz
  muY = fullm.mu(yi, i);
  SYY = fullm.Sigma(yi, yi, i);
  CPD.WYsum(:,i) = CPD.WYsum(:,i) + w(i)*muY;
  CPD.WYYsum(:,:,i) = CPD.WYYsum(:,:,i) + w(i)*(SYY + muY*muY'); % E[X Y] = Cov[X,Y] + E[X] E[Y]
  if cpsz > 0
    muX = fullm.mu(xi, i);
    SXX = fullm.Sigma(xi, xi, i);
    SXY = fullm.Sigma(xi, yi, i);
    CPD.WXsum(:,i) = CPD.WXsum(:,i) + w(i)*muX;
    CPD.WXXsum(:,:,i) = CPD.WXXsum(:,:,i) + w(i)*(SXX + muX*muX');
    CPD.WXYsum(:,:,i) = CPD.WXYsum(:,:,i) + w(i)*(SXY + muX*muY');
  end
end                

