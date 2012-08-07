function hash_param = extract_LRparam(fid_log, k)

% Given a trained bnet, extract_param will acquire all desired parameters,
% as specified in the xml input file.

bnet = k.bnet;
s = k.structure;
eval(s.var);

% process the parameters

hash_param = hashtable;
hash_glim = hashtable;

for i=1:length(s.eclasses),
	eclass = s.eclasses(i).eclass;
	e = str2num( eclass.id );

    if strcmp(eclass.type,'softmax'),
        ss = struct(bnet.CPD{i});
        if (length(ss.glim) == 1),
            w = ss.glim{1}.w1;
            b = ss.glim{1}.b1;
            hash_glim(['P' num2str(e) '(F)']) = num2cell([b(1) w(:,1)']);
            hash_glim(['P' num2str(e) '(T)']) = num2cell([b(2) w(:,2)']);
        elseif (length(ss.glim) == 2),
            w1 = ss.glim{1}.w1;
            w2 = ss.glim{2}.w1;
            b1 = ss.glim{1}.b1;
            b2 = ss.glim{2}.b1;
            hash_glim(['P' num2str(e) '(F,F)']) = num2cell([b1(1) w1(:,1)']);
            hash_glim(['P' num2str(e) '(F,T)']) = num2cell([b1(2) w1(:,2)']);
            hash_glim(['P' num2str(e) '(T,F)']) = num2cell([b2(1) w2(:,1)']);
            hash_glim(['P' num2str(e) '(T,T)']) = num2cell([b2(2) w2(:,2)']);
        else
            error('ERROR: So far BNT-SM only support Logistic Regression for CPDs dimension less than [2 x 2]\n');
        end
        
        for j=1:length(eclass.cpd),
            if strcmp(eclass.cpd(j).param, 'null'), continue; end;
            param = eclass.cpd(j).param;
            eq = expand(eclass.cpd(j).eq);
            value = hash_glim(eq);
            hash_param(param) = value;
        end
        
    end;
    
	if strcmp(eclass.type, 'discrete'),
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
end
