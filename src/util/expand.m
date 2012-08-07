function equation = expand(equation)

[idx_start, idx_finish] = regexp(equation,'P[^ ]*');
for i = 1:length(idx_start),

	%Ordering is not immediately intuitive:  the 'given' variables must
	%come first, in eclass order, and the nongiven variable come last.
	%
	% e.g. replace P2(F|T) with P2(T,F)

	equation( idx_start(i):idx_finish(i) ) = regexprep( ...
			equation( idx_start(i):idx_finish(i) ), ...
			'([^\(]*)(([^\|]*)\|([^\)]*)\)', '$1\($3,$2\)' );
			%-P2-----(-F-------|-T-------)    P2-(T-,F--)
end
