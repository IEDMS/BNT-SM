function [M H C R skill_out last_position] = tablescan(fid_log, file, ...
                                                  position)

        % M is table converted to a numeric matrix
        % H is header of the table
        % C is a column view of the table
        % R is a row view of the table
        % skill_out is the current skill
        % last_position is the last byte position read from the file
        
% lc = linecount(file);

d = dir(file);
fid = fopen(file);

delimiter = sprintf('\t');

% 1. H

H = hashtable;

header = fgetl(fid);
headers = tokenizer(header, delimiter);
for i=1:length(headers),
        H(headers{i}) = i;
end

% 2. M, C, R

M = zeros(0, length(headers));
C = cell(length(headers), 0); 
R = cell(0,0);

skill_out = '';
last_position = position;

if (d.bytes == last_position),
  fclose(fid);
  return;
end

if (position > 0),
  fseek(fid, position, 'bof');
end

i = 0;
tic;
while ~feof(fid),
        fline = fgetl(fid);
        tokens = tokenizer(fline, delimiter);
        this_skill = ['skill_' tokens{H('skill')}];
        if (strcmp(skill_out, '')),
                skill_out = this_skill;
        elseif (~strcmp(this_skill, skill_out))
                if (~issorted({skill_out, this_skill})),
                        log_message(fid_log, ['Data not sorted at skill ' ...
                                            this_skill ' \n']);
                end
                break;
        end
        i = i + 1;
        last_position = ftell(fid);
        for j=1:length(tokens),
                M(i,j) = str2double(tokens{j});
                C{j}{i} = tokens{j};
        end

        R{i} = fline;
        if mod(i, 10000) == 0
                timing = toc;
                log_message(fid_log, 'Processed %d entries, elapsed additional %f s.\n', i, timing);
                tic;
        end
end

timing = toc;
%log_message(fid_log, 'Processed total of %d entries\n', i);
log_message(fid_log, 'Processed total of %d entries, elapsed additional %f s.\n', i, timing);


fclose(fid);
