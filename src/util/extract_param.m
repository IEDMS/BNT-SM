function hash_param = extract_param(fid_log, k)

% Given a trained bnet, extract_param will acquire all desired parameters,
% as specified in the xml input file.

bnet = k.bnet;
s = k.structure;
eval(s.var);

% process the parameters

hash_param = hashtable;

for i=1:length(s.eclasses),
	eclass = s.eclasses(i).eclass;
	e = str2num( eclass.id );

	if ~strcmp(eclass.type, 'discrete'), continue; end;

	for j=1:length(eclass.cpd),
		if strcmp(eclass.cpd(j).param, 'null'), continue; end;

		% read the param from the file
		param = eclass.cpd(j).param;

		% read the equation from the file and eval actual value

		% CPD2P
		eval([ 'P' num2str(e) ' = peek(bnet.CPD{' num2str(e) '});' ]);

		value = eval(expand(eclass.cpd(j).eq));

		% cap the value to account for FP and rounding errors
		if value < 0.000001,
		     log_message(fid_log, 'WARNING: underflow %f for skill %s, variable %s\n', value, k.name, param);
                elseif value > 0.999999,
  		     log_message(fid_log, 'WARNING: overflow %f for skill %s, variable %s\n', value, k.name, param);
		end

		hash_param(param) = value;
	end
end
