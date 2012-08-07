%
% ROCDEMO - demonstrate use of ROC tools
%
%    An ROC (receiver operator characteristic) curve is a plot of the true
%    positive rate as a function of the false positive rate of a classifier
%    system.  The area under the ROC curve is a reasonable performance
%    statistic for classifier systems assuming no knowledge of the true ratio
%    of misclassification costs.
%
%    [1] Fawcett, T., "ROC graphs : Notes and practical
%        considerations for researchers", Technical report, HP
%        Laboratories, MS 1143, 1501 Page Mill Road, Palo Alto
%        CA 94304, USA, April 2004.
%
%    See also : AUROC, ROC, ROCCH

%
% File        : rocdemo.m
%
% Date        : Wednesdaay 11th November 2004 
%
% Author      : Dr Gavin C. Cawley
%
% Description : Demonstration program/minimal test harness for a small
%               collection of tools for generating Receiver Operating
%               Characteristic (ROC) curves.  See [1] for further details.
%
% References  : [1] Fawcett, T., "ROC graphs : Notes and practical
%                   considerations for researchers", Technical report, HP
%                   Laboratories, MS 1143, 1501 Page Mill Road, Palo Alto
%                   CA 94304, USA, April 2004.
%
% History     : 10/11/2004 - v1.00
%
% Copyright   : (c) G. C. Cawley, November 2004.
%
%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
%

% start from a clean slate

clear all

% generate test data from Fawcett [1] (fig 3)

fprintf(1, 'generating test data...\n');

t = [1 1 0 1 1 1 0 0 1 0 1 0 1 0 0 0 1 0 1 0]';
y = [.9  .8  .7  .6  .55 .54 .53 .52 .51 .505 ...
     .4  .39 .38 .37 .36 .35 .34 .33 .3 .1]';

% generate an ROC curve and plot it

fprintf(1, 'plotting ROC curve...\n');

[tp,fp] = roc(t,y);

figure(1);
clf;
plot(fp,tp);
xlabel('false positive rate');
ylabel('true positive rate');
title('ROC curve');

% compute the area under the ROC

fprintf(1, 'AUROC   = %f\n', auroc(tp,fp));

% compute the ROC convex hull (ROCCH) curve

if 1

   fprintf(1, 'plotting ROCCH curve...\n');

   [tp,fp] = rocch(t,y);

   hold on
   plot(fp, tp, 'r--');
   hold off
   xlabel('false positive rate');
   ylabel('true positive rate');
   title('ROC and ROCCH curve');

   % compute the area under the ROCCH

   fprintf(1, 'AUROCCH = %f\n', auroc(tp,fp));

end

% bye bye...


