% function x = logistic(a, y, w)
%
% Logistic regression.  Design matrix A, targets Y, optional
% instance weights W.  Model is E(Y) = 1 ./ (1+exp(-A*X)).
% Outputs are regression coefficients X.
%
% http://www-2.cs.cmu.edu/~ggordon/IRLS-example/

function x = logistic(a, y, w)

epsilon = 1e-10;
ridge = 1e-5;
maxiter = 200;
[n, m] = size(a);

if nargin < 3
  w = ones(n, 1);
end

x = zeros(m,1);
oldexpy = -ones(size(y));
for iter = 1:maxiter

  adjy = a * x;
  expy = 1 ./ (1 + exp(-adjy));
  deriv = max(epsilon*0.001, expy .* (1-expy));
  adjy = adjy + (y-expy) ./ deriv;
  weights = spdiags(deriv .* w, 0, n, n);

  x = inv(a' * weights * a + ridge*speye(m)) * a' * weights * adjy;

  %fprintf('%3d: [',iter);
  %fprintf(' %g', x);
  %fprintf(' ]\n');

  if (sum(abs(expy-oldexpy)) < n*epsilon)
    %fprintf('Converged.\n');
    break;
  end
  
  oldexpy = expy;

end

